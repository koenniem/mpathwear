#' Create a respiration rate chart
#'
#' Creates a visualization of respiration rate measurements over time from wearable data.
#'
#' @inheritParams continuous_chart
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
