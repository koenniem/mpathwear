#' Create a stress level chart
#'
#' Creates a visualization of continuous stress level measurements over time from wearable data.
#' Stress values are shown on a scale of 0 to 100.
#'
#' @inheritParams continuous_chart
#' @param add_average Logical. If `TRUE` (default), adds a dashed horizontal line showing the
#'   daily average stress level.
#'
#' @return A [ggplot2::ggplot] object displaying stress levels faceted by date.
#'
#' @seealso [stress_chart_discrete()] for discrete stress states
#'
#' @export
#'
#' @examples
#' stress_chart(dynamic_data)
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
#' @inheritParams discrete_chart
#'
#' @return A [ggplot2::ggplot] object displaying discrete stress states faceted by day.
#'
#' @seealso [stress_chart()] for continuous stress levels
#'
#' @export
#'
#' @examples
#' stress_chart_discrete(dynamic_data)
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
