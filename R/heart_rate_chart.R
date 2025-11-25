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
