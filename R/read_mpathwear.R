#' Read wearable data from m-Path
#'
#' This function reads one more multiple CSV files containing wearable data exported from m-Path.
#'
#' @param path A character string to the directory containing the data files or a single file path.
#' @param recursive A logical value indicating whether data files should be searched in
#' subdirectories.
#'
#' @returns
#' A tibble containing the following columns:
#' **Variable** | **Explanation**
#' |---|---|
#' |connectionId | The participant ID in m-Path.|
#' |legacyCode |The legacy invitation code format. Corresponds directly to `code`.|
#' |code | The invitation code used in the study, if any.|
#' |alias | The alias of the participant (can be changed by the participant at any point).|
#' |initials | The initials of the participant based on the first seen alias.|
#' |accountCode | The account code of the researcher.|
#' |startUTS | The start of the requested data period in Unix timestamp format.|
#' |stopUTS | The end of the requested data period in Unix timestamp format.|
#' |lastCreatedAtUnix| The last Unix timestamp at which the wearable data was updated. |
#' |dynamicData | The intraday (i.e. momentary) wearable data.|
#' |dailyData | The interday (i.e. daily) wearable data.|
#'
#' See [the m-Path manual page on data exporting](https://m-path.io/manual/knowledge-base/export-data/)
#' for more information on the columns `connectionId` through `accountCode`, as these are
#' part of the default m-Path data output.
#'
#' @export
#' @seealso [clean_dynamic_data()] and [clean_daily_data()] for unpacking the dynamic and daily data.
#'
#' @examples
#' # Your path to the data, or in this case the package example data.
#' # Note that this can also be a folder containing several files.
#' path <- system.file("extdata", "example.csv", package = "mpathwear")
#'
#' read_mpathwear(path)
read_mpathwear <- function(path, recursive = FALSE) {
  # Is the specified path a file or directory?
  if (file.info(path, extra_cols = FALSE)$isdir) {
    # Get the files in the path
    files <- list.files(
      path = path,
      recursive = recursive,
      full.names = TRUE,
      pattern = "\\.csv"
    )
  } else {
    files <- path
  }

  if (length(files) == 0) {
    cli_abort(paste0("No CSV files could be found at '", path, "'."))
  }

  # Read all files using `readr` and bind the result together
  data <- map(
    .x = files,
    .f = read_mpathwear_file
  )
  data <- bind_rows(data)

  # Keep only unique instances, as sometimes the same data is exported multiple times
  # Note: This should not be the case for data exported outside of sausje
  # TODO: remove this line in future iterations of the package
  data <- distinct(data)

  # Unpack the JSONs for dynamicData and dailyData
  data <- data |>
    dplyr::rowwise() |>
    mutate(
      dynamicData = jsonlite::fromJSON(.data$dynamicData, simplifyVector = FALSE)
    ) |>
    mutate(dailyData = jsonlite::fromJSON(.data$dailyData, simplifyVector = FALSE)) |>
    ungroup()

  # Format the `startuTS` and `stopUTS` columns
  data <- data |>
    mutate(across(
      .cols = any_of(c(
        "startUTS",
        "stopUTS",
        "lastCreatedAtUnix"
      )),
      .fns = \(x) ifelse(x != 0, as.POSIXct(x, tz = "UTC"), NA)
    ))

  # Warn if there are any days missing, i.e. entire days not queried in terms of startUTS
  # and stopUTS
  # .missing_days(data)

  data
}

.missing_days <- function(data, call = rlang::caller_env()) {
  .data <- select(
    data,
    all_of(c(
      "connectionId",
      "startUTS",
      "stopUTS"
    ))
  )

  # Get the range of the days
  days <- .data |>
    group_by(.data$connectionId) |>
    summarise(
      min = min(.data$startUTS),
      max = max(.data$startUTS),
      .groups = "keep"
    ) |>
    pivot_longer("min":"max", names_to = NULL, values_to = "day")

  # Generate the complete sequence for this range
  all_days <- days |>
    mutate(day = lubridate::floor_date(.data$day, unit = "day")) |>
    tidyr::complete(
      day = seq(
        from = min(.data$day),
        to = max(.data$day),
        by = "1 day"
      )
    ) |>
    distinct()

  # Find out if any days are missing
  between <- function(...) dplyr::between(...) # Silence R error diagnostic
  missing_days <- dplyr::anti_join(
    all_days,
    .data,
    by = dplyr::join_by(
      "connectionId",
      between(day, startUTS, stopUTS, bounds = '[)')
    )
  )

  if (nrow(missing_days) == 0) {
    return(invisible(TRUE))
  }

  bullets <- paste0(
    "Participant ",
    missing_days$connectionId,
    ", ",
    as.Date(missing_days$day)
  )
  names(bullets) <- rep("*", length(bullets))

  # Limit to 50 missing days, otherwise printing the warnings may take a very long time
  if (length(bullets) > 50) {
    len <- length(bullets)
    bullets <- bullets[1:50]
    bullets <- c(bullets, paste0("... and ", len - 50, " more days."))
  }

  cli_warn(
    c(
      "There were days missing in the data:\n",
      bullets
    ),
    call = call
  )

  invisible(FALSE)
}

read_mpathwear_file <- function(file) {
  # Do NOT use the column names when reading in the data or you might risk this error:
  #   Error: The size of the connection buffer (131072) was not large enough
  #   to fit a complete line:
  #     * Increase it by setting `Sys.setenv("VROOM_CONNECTION_SIZE")`
  #
  # This is caused by the skip = 1 argument we have to use because we provide the column names.
  # Because of this, vroom has to fit the skipped data and the next 2 lines in its buffer:
  # https://github.com/tidyverse/vroom/issues/364#issuecomment-900287167
  # However, because the dynamicData and dailyData columns can be very large, this buffer is not
  # sufficient and needs to be increased, but we cannot set beforehand how big it should be.
  cols <- c(
    connectionId = "c",
    legacyCode = "c",
    code = "c",
    alias = "c",
    initials = "c",
    accountCode = "c",
    lastCreatedAtUnix = "d",
    dynamicData = "c",
    dailyData = "c"
  )

  data <- suppressWarnings(readr::read_delim(
    file,
    delim = ";",
    # col_names = names(cols),
    col_types = paste0(cols, collapse = ""),
    # skip = 1, # Due to providing the column names
    locale = .mpath_locale,
    na = "",
    progress = FALSE,
    show_col_types = FALSE
  ))

  problems <- readr::problems(data)
  .warn_readr_problems(problems)

  data
}

.warn_readr_problems <- function(problems) {
  # Warn about other problems when reading in the data, if any
  # problems <- problems[!grepl("columns", problems$expected), ]

  if (nrow(problems) > 0) {
    problems <- paste0(
      "In row ",
      problems$row,
      " column ",
      problems$col,
      ", expected ",
      problems$expected,
      " but got ",
      problems$actual,
      "."
    )
    names(problems) <- rep("x", length(problems))

    # Limit the number of problems to 50, otherwise printing the warnings may take a very long time
    if (length(problems) > 50) {
      len <- length(problems)
      problems <- problems[1:50]
      problems <- c(problems, paste0("... and ", len - 50, " more problems."))
    }

    cli_warn(c(
      "There were problems when reading in the data:",
      problems,
      i = "Try redownloading the file from the m-Path dashboard.",
      i = paste(
        "Consult the m-Path manual {.url https://m-path.io/manual/knowledge-base/export-data/}",
        "for more information on how to export the data."
      )
    ))
  }
}

#' Locale to be used for m-Path data
#'
#' @description
#' Hard coded locale to be used for 'm-Path' data
#'
#' @returns Return a locale to be used in [readr::read_delim()] or friends.
#' @keywords internal
.mpath_locale <- readr::locale(
  date_names = "en",
  date_format = "%AD",
  time_format = "%AT",
  decimal_mark = ".",
  grouping_mark = "",
  tz = "UTC",
  encoding = "UTF-8",
  asciify = FALSE
)
