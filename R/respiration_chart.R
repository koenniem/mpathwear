#' Create a respiration rate chart
#'
#' Creates a visualization of respiration rate measurements over time from wearable data.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#'
#' @return A [ggplot2::ggplot] object displaying respiration rate measurements faceted by date.
#'
#' @export
respiration_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset"
) {
  p <- continuous_chart(
    .data,
    type = "RespirationRate",
    start = start,
    end = end,
    variable = variable,
    value = value,
    tz_offset = tz_offset
  )

  p +
    labs(
      y = "Respiration Rate"
    )
}
