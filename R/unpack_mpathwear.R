unpack_mpathwear <- function(data, .col) {
  if (!is.character(.col) && length(.col) > 1) {
    stop("`.col` must be a single character string.")
  }

  data <- data |>
    hoist(.col = .col, "dataSources") |>
    select(-all_of(.col)) |>
    unnest("dataSources", keep_empty = TRUE) |>
    unnest_wider("dataSources") |>
    unnest("data", keep_empty = TRUE) |>
    unnest_wider("data") |>
    unnest_wider("details")

  # Correct the timestamps
  # TODO: consider replacing timezones with `timezoneOffset` to convert to UTC. This will
  # bring all data to UTC, and lose the timezone permanently, but does allow different
  # measurements to have varying timezones.
  data <- data |>
    mutate(across(
      .cols = any_of(c(
        "createdAtUnix",
        "startTimestampUnix",
        "timestampUnix",
        "endTimestampUnix"
      )),
      .fns = \(x) x / 1000
    )) |>
    mutate(across(
      .cols = any_of(c(
        "startUTS",
        "stopUTS",
        "createdAtUnix",
        "timestampUnix",
        "startTimestampUnix",
        "endTimestampUnix"
      )),
      .fns = \(x) as.POSIXct(x, tz = "UTC")
    ))

  # Merge with data_sources
  data_sources <- select(data_sources, "id", "data_source")
  data <- data |>
    left_join(
      y = data_sources,
      by = c("dataSource" = "id")
    ) |>
    select(-c("dataSource"))

  data
}

#' Clean mpathwear daily data
#'
#' @param data A data frame containing the wearable data, as returned by [read_mpathwear()].
#' @param .col The column containing the data to be unpacked.
#' @param connectionId The column containing the participant ID.
#' @param start The column containing the start time of the data retrieval period.
#' @param end The column containing the end time of the data retrieval period.
#'
#' @returns A tibble containing at least the following columns:
#' \tabular{ll}{
#' `connectionId` \tab The participant ID in m-Path, as specified by the `connectionId` argument.\cr
#' `day` \tab The day of the measurement as a Date object. \cr
#' `category` \tab The overall category of the measurement. \cr
#' `subcategory` \tab The more specific category of the measurement. \cr
#' `variable` \tab The variable name of the measurement. \cr
#' `value` \tab The value of the measurement. \cr
#' `timezoneOffset` \tab The timezone offset of the measurement compared to UTC. \cr
#' `generation` \tab Whether the measurement was  a calculation, automatic measurement, or manual
#' input. \cr
#' `trustworthiness` \tab Whether the measurement was trustworthy. \cr
#' `created_at` \tab The time the measurement was created or updated. \cr
#' `data_source` \tab The data source of the measurement. Also see [data_sources()]. \cr
#' `day_complete` \tab A flag that signals whether the day was complete, i.e. a value of 1. A value
#' of 0 indicates that it is uncertain that the day was complete, as there was no data the next
#' day. \cr
#' `description` \tab The description of the measurement. \cr
#' `available_sources` \tab The available data sources (e.g. Garmin, Fitbit) for this type of
#' measurement. \cr
#' }
#' @export
clean_daily_data <- function(
  data,
  .col = "dailyData",
  connectionId = "connectionId",
  start = "startUTS",
  end = "stopUTS"
) {
  data <- unpack_mpathwear(data, .col)

  if (!is.null(start) && !is.null(end)) {
    if (start %in% colnames(data) && end %in% colnames(data)) {
      start <- rlang::ensym(start)
      end <- rlang::ensym(end)

      # Add a flag that signals whether the day was complete, i.e. a value of 1. A value of 0 indicates
      # that it is uncertain that the day was complete, as there was not data the next day.
      data <- data |>
        mutate(
          day_complete = as.integer(difftime(
            {{ end }},
            {{ start }},
            units = "secs"
          )) /
            86400
        ) |>
        select(-c({{ start }}, {{ end }}))

      # Keep only the most recent data point in the database.
      data <- slice_max(
        data,
        order_by = .data$createdAtUnix,
        by = all_of(c("connectionId", "timestampUnix", "dailyDynamicValueType")),
        with_ties = FALSE
      )
    }
  }

  # Merge with codebook
  codebook <- filter(codebook, .data$level == "Daily")
  data <- data |>
    left_join(
      y = codebook,
      by = c("dailyDynamicValueType" = "code", "valueType" = "unit")
    ) |>
    select(-c("dailyDynamicValueType", "valueType", "level"))

  # Reorder some of the columns
  data <- dplyr::relocate(
    data,
    "timestampUnix",
    "category":"variable",
    .before = "value"
  )

  data <- mutate(data, timestampUnix = as.Date(.data$timestampUnix))

  # Rename some columns
  data <- data |>
    rename(
      day = "timestampUnix",
      created_at = "createdAtUnix"
    )

  data
}


#' Clean mpathwear intraday (i.e. dynamic) data
#'
#' @param data A data frame containing the wearable data, as returned by [read_mpathwear()].
#' @param .col The column containing the data to be unpacked.
#' @param connectionId The column containing the participant ID.
#'
#' @returns A tibble containing at least the following columns:
#' \tabular{ll}{
#' `connectionId` \tab The participant ID in m-Path, as specified by the `connectionId` argument.\cr
#' `start_time` \tab The start time of the measurement. \cr
#' `end_time` \tab The end time of the measurement. \cr
#' `category` \tab The overall category of the measurement. \cr
#' `subcategory` \tab The more specific category of the measurement. \cr
#' `variable` \tab The variable name of the measurement. \cr
#' `value` \tab The value of the measurement. \cr
#' `timezoneOffset` \tab The timezone offset of the measurement compared to UTC. \cr
#' `generation` \tab Whether the measurement was  a calculation, automatic measurement, or manual
#' input. \cr
#' `chronologicalExactness` \tab The imprecision of the timestamp in minutes. This imprecision
#' occurs when some specific sources give the summary of activity without precise information about
#' timestamp of specific activity. \cr
#' `created_at` \tab The time the measurement was created or updated. \cr
#' `data_source` \tab The data source of the measurement. Also see [data_sources]. \cr
#' `description` \tab The description of the measurement. \cr
#' `available_sources` \tab The available data sources (e.g. Garmin, Fitbit) for this type of
#' measurement. \cr
#' }
#' @export
clean_dynamic_data <- function(
  data,
  .col = "dynamicData",
  connectionId = "connectionId"
) {
  data <- unpack_mpathwear(data, .col)

  connectionId <- rlang::ensym(connectionId)

  # Remove measurements that somehow do not have a dynamicValueType (data is not identifiable)
  data <- filter(data, !is.na(.data$dynamicValueType))

  # Make sure there are no duplicate measurements
  data <- data |>
    distinct(
      {{ connectionId }},
      .data$startTimestampUnix,
      .data$endTimestampUnix,
      .data$value,
      .data$dynamicValueType,
      .keep_all = TRUE
    )

  # Merge with code book
  codebook <- filter(codebook, .data$level == "Intraday")
  # Replace code 4002 with 4000 as this is RespirationRate but is incorrectly labelled as
  # RespirationRateSleep, a daily variable
  data <- data |>
    mutate(
      dynamicValueType = ifelse(
        .data$dynamicValueType == 4002,
        4000,
        .data$dynamicValueType
      )
    )

  data <- data |>
    left_join(
      y = codebook,
      by = c("dynamicValueType" = "code", "valueType" = "unit")
    ) |>
    select(-c("dynamicValueType", "valueType", "level"))

  # Rename some columns
  data <- data |>
    rename(
      start_time = "startTimestampUnix",
      end_time = "endTimestampUnix",
      created_at = "createdAtUnix",
      tz_offset = "timezoneOffset"
    )

  # Reorder some of the columns
  data <- dplyr::relocate(
    data,
    "start_time",
    "end_time",
    "category":"variable",
    .before = "value"
  )

  data
}
