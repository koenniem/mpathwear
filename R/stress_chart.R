#' Create a stress level chart
#'
#' Creates a visualization of continuous stress level measurements over time from wearable data.
#' Stress values are shown on a scale of 0 to 100.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#' @param add_average Logical. If `TRUE` (default), adds a dashed horizontal line showing the
#'   daily average stress level.
#'
#' @return A [ggplot2::ggplot] object displaying stress levels faceted by date.
#'
#' @export
stress_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset",
  add_average = TRUE
) {
  p <- continuous_chart(
    .data,
    type = "Stress",
    start = start,
    end = end,
    variable = variable,
    value = value,
    tz_offset = tz_offset
  ) +
    scale_y_continuous(limits = c(0, 100))

  if (add_average) {
    means <- p$data |>
      group_by(date) |>
      summarise(across(
        .cols = value,
        .fns = \(x) mean(x, na.rm = TRUE),
        .names = "mean"
      ))

    p <- p +
      geom_hline(
        data = means,
        mapping = aes(yintercept = mean),
        colour = "black",
        linetype = "dashed"
      )
  }

  p
}

#' Create a discrete stress state chart
#'
#' Creates a visualization of discrete stress states (Low, Medium, High) over time from
#' wearable data.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#'
#' @return A [ggplot2::ggplot] object displaying discrete stress states faceted by day.
#'
#' @export
stress_chart_discrete <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset"
) {
  discrete_chart(
    .data,
    types = c("LowStressBinary", "MediumStressBinary", "HighStressBinary"),
    names = c("Low", "Medium", "High"),
    start = start,
    end = end,
    variable = variable,
    value = value,
    tz_offset = tz_offset
  ) +
    labs(y = "Stress state")
}
