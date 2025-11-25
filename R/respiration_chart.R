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
