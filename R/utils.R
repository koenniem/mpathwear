check_multiple_ids <- function(.data, .call = rlang::caller_env()) {
  possible_names <- c(
    "connectionid",
    "participantid",
    "participant",
    "connection",
    "connection_id",
    "participant_id"
  )

  cnames <- colnames(.data)
  if (any(possible_names %in% tolower(cnames))) {
    group_name <- cnames[tolower(cnames) %in% possible_names]
    if (length(unique(.data[[group_name]])) > 1) {
      participants <- unique(.data[[group_name]])
      cli_warn(
        c(
          paste(
            "The data contains multiple participants.",
            "Only the first participant ID will be used."
          ),
          i = paste0(
            "Using participant with `",
            group_name,
            "` ",
            participants[1],
            "."
          )
        ),
        call = .call
      )
      .data <- .data[.data[[group_name]] == participants[1], ]
    }
  }

  .data
}

add_tz_offset <- function(
  .data,
  start,
  end,
  tz_offset
) {
  force(start)
  force(end)
  force(tz_offset)

  if (!rlang::is_symbol(tz_offset)) {
    tz_offset <- rlang::ensym(tz_offset)
  }

  .data <- .data |>
    mutate(
      {{ tz_offset }} := ifelse(is.na({{ tz_offset }}), 0, {{ tz_offset }})
    ) |>
    mutate({{ start }} := {{ start }} + ({{ tz_offset }} * 60)) |>
    mutate({{ end }} := {{ end }} + ({{ tz_offset }} * 60))

  .data
}

tz_to_offset <- function(x, tz) {
  tzs <- match(tz, OlsonNames())
  tzs <- OlsonNames()[tzs]

  if (anyNA(tzs)) {
    tzs <- tzs[!is.na(tzs)]
    cli::cli_abort(
      c(
        paste0(
          "Timezone '",
          paste0(tzs, collapse = ", "),
          "' is not a valid timezone."
        ),
        i = "See `OlsonNames()` for a list of valid timezones."
      )
    )
  }

  data.frame(
    x = x,
    tzone = tzs
  ) |>
    group_by(.data$tzone) |>
    mutate(offset = as.POSIXlt(x, tz = .data$tzone)$gmtoff) |>
    dplyr::pull("offset")
}

offset_to_tz <- function(x, offset) {
  all_timezones <- OlsonNames()
  offset <- offset / 3600

  # Loop over all timezones and check the UTC offset at the provided datetime
  matching_timezones <- map(
    .x = all_timezones,
    .f = \(tz) format(as.POSIXct(x, tz), "%z")
  )
  matching_timezones <- purrr::list_transpose(
    matching_timezones,
    simplify = TRUE
  )
  matching_timezones <- map(matching_timezones, as.double)
  matching_timezones <- map(matching_timezones, \(x) x / 100)

  matching_timezones <- map2(
    .x = matching_timezones,
    .y = offset,
    .f = \(tz, off) tz == off
  )
  matching_timezones <- map(matching_timezones, \(x) all_timezones[x])
  matching_timezones
}

#' Summarise Overlapping and Contiguous Time Intervals
#'
#' Summarise rows in a dataset where the `start` of the next interval is (nearly) equal to the
#' `end` of the current interval, indicating they are contiguous. This is useful for simplifying
#' sequences of adjacent time intervals into broader continuous spans. It also summarises over time
#' intervals if they overlap.
#'
#' @param .data A data frame containing at least the `start` and `end` time columns.
#' @param start The name of the column indicating start times. Defaults to `"start_time"`.
#' @param end The name of the column indicating end times. Defaults to `"end_time"`.
#' @param tolerance A numeric value indicating the maximum difference between the `end` of one interval
#' and the `start` of the next interval to consider them contiguous. Defaults to `0`.
#'
#' @return A data frame with collapsed contiguous time intervals, where each row represents a continuous span.
#'
#' @examples
#' df <- data.frame(
#'   start_time = c(1, 2, 4, 5),
#'   end_time = c(2, 3, 5, 6)
#' )
#' summarise_overlapping_time(
#'   df,
#'   start = start_time,
#'   end = end_time
#' )
#'
#' @export
summarise_overlapping_time <- function(.data, start, end, tolerance = 0) {
  # Sort by the values and find the previous end time
  .data <- .data |>
    arrange({{ start }}, {{ end }}, .by_group = TRUE) |>
    mutate(.prev_obs = lag({{ end }}, default = dplyr::first({{ start }})))

  # Create a new group each time the start time is greater than the previous end time plus tolerance
  # Then, cumulatively sum these to create group identifiers where the identifier goes up by 1 if
  # there is a group change.
  .data <- .data |>
    mutate(.grp = {{ start }} > (.data$.prev_obs + tolerance)) |>
    mutate(.grp = ifelse(is.na(.data$.grp), FALSE, .data$.grp)) |>
    mutate(.grp = cumsum(.data$.grp))

  # Once we have the groups, summarise to only retain the first start time and last end time of
  # each group
  .data |>
    group_by(.data$.grp, .add = TRUE) |>
    summarise(
      {{ start }} := dplyr::first({{ start }}),
      {{ end }} := dplyr::last({{ end }}),
      .groups = "drop_last"
    ) |>
    select(-".grp")
}


check_suggested <- function(name, call = rlang::caller_env()) {
  if (!requireNamespace(name, quietly = TRUE)) {
    cli::cli_abort(
      c(
        paste0("Package `", name, "` is needed for this function to work."),
        i = paste0("Please install it using `install.packages(\"", name, "\")`")
      ),
      call = call
    )
  }
}
