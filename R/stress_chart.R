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
