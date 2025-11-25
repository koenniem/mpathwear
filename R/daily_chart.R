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
