#' Create a heart rate chart
#'
#' Creates a visualization of heart rate measurements over time from wearable data.
#' The chart displays heart rate values with optional daily average lines.
#'
#' @inheritParams continuous_chart
#' @param add_average Logical. If `TRUE` (default), adds a dashed horizontal line showing the
#'   daily average heart rate.
#'
#' @return A [ggplot2::ggplot] object displaying heart rate measurements faceted by date.
#'
#' @seealso [hrv_chart()] for heart rate variability
#'
#' @export
#'
#' @examples
#' heart_rate_chart(dynamic_data)
heart_rate_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset",
  add_average = TRUE
) {
  p <- suppressMessages(
    continuous_chart(
      .data,
      type = "HeartRate",
      start = start,
      end = end,
      variable = variable,
      value = value,
      tz_offset = tz_offset
    ) +
      scale_y_continuous(limits = c(40, 200)) +
      scale_color_viridis_c(
        name = "Heart rate",
        limits = c(40, 200),
        option = "inferno",
        direction = -1
      ) +
      labs(y = "Heart rate")
  )

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

#' Create a heart rate variability (HRV) chart
#'
#' Creates a visualization of heart rate variability measurements over time from wearable data.
#' HRV metrics include RMSSD, SDNN, and SDRR.
#'
#' @inheritParams continuous_chart
#' @param add_average Logical. If `TRUE` (default), adds a dashed horizontal line showing the
#'   daily average HRV.
#'
#' @return A [ggplot2::ggplot] object displaying HRV measurements faceted by date.
#'
#' @seealso [heart_rate_chart()] for heart rate measurements
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # HRV is not available in the example data,
#' # but this is how you would call the function:
#' hrv_chart(dynamic_data)
#' }
hrv_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset",
  add_average = TRUE
) {
  p <- suppressMessages(
    continuous_chart(
      .data,
      type = c("Rmssd", "SDNN", "SDRR"),
      start = start,
      end = end,
      variable = variable,
      value = value,
      tz_offset = tz_offset
    ) +
      labs(y = "HRV")
  )

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
