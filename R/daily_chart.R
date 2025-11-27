#' Create a daily summary chart
#'
#' Creates a line chart visualization of daily summary wearable data metrics over time for a single
#' participant.
#' Each variable is displayed in its own facet with points connected by lines.
#'
#' @param .data A data frame containing the daily wearable data, typically from
#'   [clean_daily_data()].
#' @param day The name of the column containing date values. Defaults to `"day"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#'
#' @return A [ggplot2::ggplot] object displaying daily metrics as line charts faceted by
#'   variable type.
#'
#' @export
daily_chart <- function(
  .data,
  day = "day",
  variable = "variable",
  value = "value"
) {
  .data <- check_multiple_ids(.data)

  day <- rlang::ensym(day)
  variable <- rlang::ensym(variable)
  value <- rlang::ensym(value)

  # Convert the values to doubles, except SleepStartTime and SleepEndTime
  .data <- .data |>
    filter(!({{ variable }} %in% c("SleepStartTime", "SleepEndTime"))) |>
    mutate({{ value }} := as.double({{ value }})) |>
    drop_na({{ value }})

  # Build the plot
  p <- .data |>
    ggplot(aes(
      x = {{ day }},
      y = {{ value }},
      colour = {{ variable }},
      fill = {{ variable }}
    )) +
    geom_point() +
    geom_line() +
    scale_fill_discrete(guide = NULL) +
    scale_colour_discrete(guide = NULL) +
    facet_wrap(vars({{ variable }}), scales = "free_y")

  p
}
