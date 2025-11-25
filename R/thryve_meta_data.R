# Script for scraping biomarker codes from Thryve API documentation
scrape_thryve_codes <- function(
  url = c(
    "https://thryve.health/api-doc/biomarkers.php",
    "https://thryve.health/api-doc/analytics.php"
  )
) {
  check_suggested("rvest")

  # Get the h1 (category), h3 (subcategory), table elements (containing the actual codes), and
  # blockquotes (containing which devices it applies to) from the API documentation
  elements <- rvest::read_html(url) |>
    rvest::html_elements("table, h1, h3, blockquote")

  # Unpack h1 and h3 using `html_text2()`, but make sure we can separate them later by adding a prefix
  # Unpack tables (being of class xml_node) by using `html_table()`
  # And put everything into a tibble of one column
  elements <- elements |>
    map(\(x) if (grepl("<h1", x)) paste0("h1_", rvest::html_text2(x)) else x) |>
    map(\(x) if (grepl("<h3", x)) paste0("h3_", rvest::html_text2(x)) else x) |>
    map(\(x) {
      if (grepl("<blockquote", x)) paste0("bq_", rvest::html_text2(x)) else x
    }) |>
    map(\(x) if (inherits(x, "xml_node")) rvest::html_table(x) else x) |>
    tibble(data = _)

  # Next, duplicate h1 (category) and h3 (subcategory) into their own columns. Because we will then
  # have columns consisting only of category and subcategory (and missings), we can use `fill()` to
  # add the category and subcategory to the rows where they are missing.
  elements <- elements |>
    mutate(
      category = if_else(
        map_lgl(.data$data, \(x) any(grepl("h1_", x))),
        .data$data,
        NA
      ),
      .before = 1
    ) |>
    mutate(
      subcategory = if_else(
        map_lgl(.data$data, \(x) any(grepl("h3_", x))),
        .data$data,
        NA
      ),
      .after = "category"
    ) |>
    mutate(
      blockquote = if_else(
        map_lgl(.data$data, \(x) any(grepl("bq_", x))),
        .data$data,
        NA
      ),
      .after = "subcategory"
    ) |>
    fill("category", .direction = "down") |>
    fill("subcategory", .direction = "downup") |>
    fill("blockquote", .direction = "downup")

  # We can then unnest the category and subcategory (list columns with character vectors of length 1)
  # and filter out rows where data was a duplicated category or subcategory (these are no longer
  # needed).
  elements <- elements |>
    unnest(c("category", "subcategory", "blockquote"), keep_empty = TRUE) |>
    filter(!map_lgl(.data$data, is.character))

  # Also, we can remove the prefixes we added earlier, as we no longer need them
  elements <- elements |>
    mutate(
      category = str_remove(.data$category, "h1_"),
      subcategory = str_remove(.data$subcategory, "h3_"),
      blockquote = str_remove(.data$blockquote, "bq_")
    )

  # Finally, retain only tables that contain some data type and unnest the tables
  codebook <- elements |>
    filter(map_lgl(.data$data, \(tab) any(grepl("DataType", tab)))) |>
    unnest("data")

  # For a page where Daily and Intraday are displayed directly below the variable name (and are thus
  # suffixed to the name). If Daily and Intraday are in a separate column, `X1` should be all Daily
  # and Intraday.
  if (!all(codebook$X1 %in% c("Daily", "Intraday"))) {
    # Correct if daily or intraday were not formatted properly
    code_five_col <- codebook |>
      filter(.data$X1 == "Daily" | .data$X1 == "Intraday") |>
      mutate(X1 = .data$X2, X2 = .data$X3, X3 = .data$X4, X4 = .data$X5) |>
      select(-"X5")

    codebook <- codebook |>
      filter(!(.data$X1 == "Daily" | .data$X1 == "Intraday")) |>
      bind_rows(code_five_col) |>
      select(-"X5")

    # Separate Daily and Intraday from variable name
    codebook <- codebook |>
      rename(
        X3 = "X2",
        X4 = "X3",
        X5 = "X4"
      ) |>
      separate_wider_regex(
        cols = "X1",
        patterns = c(X2 = "^.+?(?=Daily|Intraday|$)", X1 = ".*"),
        too_few = "align_start"
      ) |>
      mutate(X1 = ifelse(.data$X1 == "", NA, .data$X1)) |>
      dplyr::relocate("X1", .before = "X2")
  }

  # Set more logical column names
  codebook <- codebook |>
    rename(
      level = "X1",
      variable = "X2",
      description = "X3",
      code = "X4",
      unit = "X5"
    )

  # Remove data type ID
  codebook <- codebook |>
    mutate(code = str_extract(.data$code, "\\d+")) |>
    mutate(code = as.integer(.data$code))

  # Remove whitespace from all character columns
  codebook <- codebook |>
    mutate(across(
      .cols = dplyr::where(is.character),
      .fns = trimws
    )) |>
    mutate(across(
      .cols = dplyr::where(is.character),
      .fns = \(x) str_replace_all(x, "\\n|\\r", "")
    ))

  # Clean up the blockquote so that it contains only the relevant data sources
  # Get the data sources
  source_list <- str_replace_all(
    string = mpathwear::data_sources$data_source,
    pattern = "(\\(.*\\)|\\*)",
    ""
  ) |>
    trimws() |>
    str_replace_all("GoogleFit", "Google Fit") |>
    str_replace_all("HuaweiHealth", "Huawei Health") |>
    str_replace_all(" ", "\\\\s*")

  # Define some regexes to get the list of sources that are available for daily and intraday data
  # respectively.
  daily_regex <- "(?<=Daily data available for: )(.*?)(?=\\s*,?\\s*Intra|$|\\n|\\s*,?\\s*Daily)"
  intra_regex <- "(?<=Intraday data available for: )(.*?)(?=\\s*,?\\s*Intra|$|\\n|\\s*,?\\s*Daily)"
  codebook <- codebook |>
    mutate(
      available_sources = case_when(
        level == "Daily" ~ str_extract(.data$blockquote, daily_regex),
        level == "Intraday" ~ str_extract(.data$blockquote, intra_regex),
        .default = NA
      )
    ) |>
    mutate(
      available_sources = str_extract_all(
        .data$available_sources,
        paste(.data$source_list, collapse = "|")
      )
    ) |>
    mutate(available_sources = map(.data$available_sources, trimws)) |>
    mutate(
      available_sources = map(
        .x = .data$available_sources,
        .f = \(x) str_replace_all(x, "[:blank:]{2,}", " ")
      )
    ) |>
    select(-"blockquote")

  codebook
}


.update_codebook <- function() {
  codebook <- bind_rows(
    scrape_thryve_codes(
      system.file("extdata", "biomarkers.htm", package = "mpathwear")
    ),
    scrape_thryve_codes(system.file(
      "extdata",
      "analytics.htm",
      package = "mpathwear"
    ))
  ) |>
    distinct(.data$level, .data$code, .data$unit, .keep_all = TRUE)
  check_suggested("usethis")
  usethis::use_data(codebook, overwrite = TRUE)
}

scrape_thryve_data_sources <- function(
  url = "https://thryve.health/api-doc/access.php",
  save_data = TRUE
) {
  check_suggested("rvest")

  elements <- rvest::read_html(url) |>
    rvest::html_elements("h3, table")

  loc_active_data_sources <- map_lgl(elements, \(x) {
    grepl("active-data-sources", x)
  })
  loc_experimental_data_sources <- map_lgl(elements, \(x) {
    grepl("experimental-data-sources", x)
  })
  loc_thryve_data_sources <- map_lgl(elements, \(x) grepl("thryve-data", x))

  loc_active_data_sources <- which(loc_active_data_sources)
  loc_experimental_data_sources <- which(loc_experimental_data_sources)
  loc_thryve_data_sources <- which(loc_thryve_data_sources)

  # Extract the tables for each data sources
  if (length(loc_active_data_sources) > 0) {
    active_data_sources <- rvest::html_table(elements[[
      loc_active_data_sources + 1
    ]])
  } else {
    rlang::warn("No active data sources found at the provided URL")
    active_data_sources <- tibble()
  }

  if (length(loc_experimental_data_sources) > 0) {
    experimental_data_sources <- rvest::html_table(elements[[
      loc_experimental_data_sources + 1
    ]])
    experimental_data_sources <- experimental_data_sources |>
      mutate(ID = ifelse(.data$ID == "na", NA, .data$ID)) |>
      mutate(ID = as.integer(.data$ID))
  } else {
    rlang::warn("No experimental data sources found at the provided URL")
    experimental_data_sources <- tibble()
  }

  if (length(loc_thryve_data_sources) > 0) {
    thryve_data_sources <- rvest::html_table(elements[[
      loc_thryve_data_sources + 1
    ]])
  } else {
    rlang::warn("No Thryve data sources found at the provided URL")
    thryve_data_sources <- tibble()
  }

  # Bind them together
  data_sources <- bind_rows(
    mutate(active_data_sources, source = "active"),
    mutate(experimental_data_sources, source = "experimental"),
    mutate(thryve_data_sources, source = "thryve")
  )

  # Set snake case column names
  colnames(data_sources) <- c(
    "id",
    "data_source",
    "type_integration",
    "data_retrieval_frequency",
    "type_data_source"
  )

  if (save_data) {
    check_suggested("usethis")
    usethis::use_data(data_sources, overwrite = TRUE)
    return(invisible(data_sources))
  }

  data_sources
}

scrape_thryve_activity_types <- function(
  url = "https://thryve.health/api-doc/biomarkers.php",
  save_data = TRUE
) {
  check_suggested("rvest")

  elements <- rvest::read_html(url) |>
    rvest::html_elements("h3, table")

  loc_activitytype <- map_lgl(elements, \(x) grepl("id=\"activitytype\"", x))
  loc_activitytype_1 <- map_lgl(elements, \(x) {
    grepl("id=\"activitytypedetail1\"", x)
  })
  loc_activitytype_2 <- map_lgl(elements, \(x) {
    grepl("id=\"activitytypedetail2\"", x)
  })

  loc_activitytype <- which(loc_activitytype)
  loc_activitytype_1 <- which(loc_activitytype_1)
  loc_activitytype_2 <- which(loc_activitytype_2)

  activitytype <- activitytype_1 <- activitytype_2 <- NULL

  if (length(loc_activitytype) > 0) {
    activitytype <- rvest::html_table(elements[[loc_activitytype + 2]])
  }

  if (length(loc_activitytype_1) > 0) {
    activitytype_1 <- rvest::html_table(elements[[loc_activitytype_1 + 2]])
  }

  if (length(loc_activitytype_2) > 0) {
    activitytype_2 <- rvest::html_table(elements[[loc_activitytype_2 + 2]])
  }

  activity_types <- bind_rows(
    activitytype,
    activitytype_1,
    activitytype_2
  )
  colnames(activity_types) <- c("code", "activity")
  activity_types$code <- as.character(activity_types$code)

  if (save_data) {
    check_suggested("usethis")
    usethis::use_data(activity_types, overwrite = TRUE)
    return(invisible(activity_types))
  }

  activity_types
}
