#' Create a data coverage chart
#'
#' Creates a visualization showing the temporal coverage of wearable data across participants
#' and variable types. This is useful for assessing data completeness and identifying gaps.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param participant The name of the column containing participant identifiers. Defaults to
#'   `"connectionId"`.
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#'
#' @return A [ggplot2::ggplot] object displaying data coverage as horizontal segments per
#'   participant, faceted by variable type.
#'
#' @export
coverage_chart <- function(
  .data,
  participant = "connectionId",
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  # .data <- check_multiple_ids(.data)

  participant <- rlang::ensym(participant)
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # If there are no end values, consider the measurements are "momentary", and set the end time
  # to be the same as the start time.
  .data <- .data |>
    mutate({{ end }} := dplyr::coalesce({{ end }}, ({{ start }} + 300)))

  # Format the time stamps
  .data <- .data |>
    group_by({{ participant }}) |>
    mutate(min_time = min({{ start }}, na.rm = TRUE)) |>
    mutate({{ start }} := difftime({{ start }}, .data$min_time, units = "days")) |>
    mutate({{ end }} := difftime({{ end }}, .data$min_time, units = "days")) |>
    ungroup()

  # Make sure the participant variable is a factor
  .data <- .data |>
    mutate({{ participant }} := as.factor({{ participant }}))

  # Create the plot
  .data |>
    ggplot(aes(
      x = {{ start }},
      xend = {{ end }},
      y = {{ participant }},
      yend = {{ participant }},
      colour = {{ participant }}
    )) +
    geom_segment(linewidth = 4) +
    scale_x_continuous() +
    facet_wrap(vars({{ variable }})) +
    labs(
      x = "Day in study",
      y = "Participant"
    )
}

#' Create a daily data coverage chart
#'
#' Creates a tile-based visualization showing which days have data coverage for each participant
#' and variable type. This provides a clear overview of data availability at the daily level.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_daily_data()].
#' @param participant The name of the column containing participant identifiers. Defaults to
#'   `"connectionId"`.
#' @param time The name of the column containing day/date values. Defaults to `"day"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#'
#' @return A [ggplot2::ggplot] object displaying daily data coverage as tiles per participant,
#'   faceted by variable type.
#'
#' @export
daily_coverage_chart <- function(
  .data,
  participant = "connectionId",
  time = "day",
  variable = "variable"
) {
  participant <- rlang::ensym(participant)
  time <- rlang::ensym(time)
  variable <- rlang::ensym(variable)

  .data <- .data |>
    group_by({{ participant }}) |>
    mutate(min_time = min({{ time }}, na.rm = TRUE)) |>
    mutate({{ time }} := difftime({{ time }}, .data$min_time, units = "days")) |>
    mutate({{ time }} := floor({{ time }})) |>
    distinct() |>
    ungroup()

  .data <- .data |>
    mutate({{ participant }} := as.factor({{ participant }}))

  max_days <- .data |>
    summarise(max_days = max({{ time }}, na.rm = TRUE)) |>
    dplyr::pull()

  .data |>
    ggplot(aes(
      x = {{ time }},
      y = {{ participant }},
      fill = {{ participant }}
    )) +
    geom_tile(colour = "grey") +
    scale_fill_discrete(
      guide = NULL,
    ) +
    scale_x_continuous(
      breaks = seq.int(0, max_days, by = 1)
    ) +
    facet_wrap(vars({{ variable }})) +
    labs(
      x = "Day in study",
      y = "Participant"
    )
}
