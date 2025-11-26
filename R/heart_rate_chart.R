#' Create a heart rate chart
#'
#' Creates a visualization of heart rate measurements over time from wearable data.
#' The chart displays heart rate values with optional daily average lines.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#' @param add_average Logical. If `TRUE` (default), adds a dashed horizontal line showing the
#'   daily average heart rate.
#'
#' @return A [ggplot2::ggplot] object displaying heart rate measurements faceted by date.
#'
#' @export
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
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#' @param add_average Logical. If `TRUE` (default), adds a dashed horizontal line showing the
#'   daily average HRV.
#'
#' @return A [ggplot2::ggplot] object displaying HRV measurements faceted by date.
#'
#' @export
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
