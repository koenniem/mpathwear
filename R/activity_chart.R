#' Create an activity type chart
#'
#' Creates a visualization of activity types over time from wearable data. The chart can display
#' activities either as merged horizontal bars per day or as individual activity segments with
#' transitions.
#'
#' @inheritParams discrete_chart
#' @param merged_bars Logical. If `TRUE` (default), activities are shown as a single row per day.
#'   If `FALSE`, activities are shown with vertical transitions between states.
#'
#' @return A [ggplot2::ggplot] object displaying activity types over time.
#'
#' @seealso [activity_intensity_chart()] for activity intensity levels, [steps_chart()] for
#'   step counts
#'
#' @export
#'
#' @examples
#' # Show a single timeline
#' activity_chart(dynamic_data)
#'
#' # Display activities with transitions
#' activity_chart(dynamic_data, merged_bars = FALSE)
activity_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset",
  merged_bars = TRUE
) {
  .data <- check_multiple_ids(.data)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)
  value <- rlang::ensym(value)

  .data <- .data |>
    filter(grepl("ActivityType|ActiveBinary", {{ variable }})) |>
    left_join(mpathwear::activity_types, by = c("value" = "code")) |>
    mutate(
      activity = if_else(
        is.na(.data$activity) & {{ variable }} == "ActiveBinary",
        "Active",
        .data$activity
      )
    )

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # Determine the days
  .data <- .data |>
    mutate(day = cut({{ start }}, "days"))

  # Calculate the subsequent activity phase
  .data <- .data |>
    arrange({{ start }}, {{ end }}) |>
    group_by(.data$day) |>
    mutate(next_state = lead(.data$activity)) |>
    mutate(
      next_state = dplyr::if_else(is.na(.data$next_state), .data$activity, .data$next_state)
    ) |>
    ungroup()

  # Create the plot
  if (merged_bars) {
    p <- .data |>
      mutate(across(
        .cols = c({{ start }}, {{ end }}),
        .fns = \(x) lubridate::origin + (as.integer(difftime(x, .data$day, units = "secs")))
      )) |>
      ggplot() +
      geom_segment(
        aes(
          x = {{ start }},
          xend = {{ end }},
          y = .data$day,
          colour = .data$activity
        ),
        linewidth = 2
      ) +
      labs(
        x = "time",
        y = "Date"
      )
  } else {
    p <- .data |>
      ggplot() +
      geom_segment(
        aes(
          x = {{ start }},
          xend = {{ end }},
          y = .data$activity,
          colour = .data$activity
        ),
        linewidth = 2
      ) +
      geom_segment(
        aes(
          x = {{ end }},
          y = .data$activity,
          yend = .data$next_state
        ),
        alpha = 0.5,
        colour = "grey",
        linetype = "dashed"
      ) +
      scale_colour_discrete(guide = NULL) +
      facet_wrap(vars(day), scales = "free_x") +
      labs(
        x = "Time",
        y = "State",
      )
  }

  p <- p +
    scale_x_datetime(
      date_breaks = "2 hours",
      date_labels = "%H:%M"
    )

  p
}

#' Create an activity intensity chart
#'
#' Creates a visualization of activity intensity levels (Sedentary, Low, Medium, High) over time
#' from wearable data.
#'
#' @inheritParams discrete_chart
#'
#' @return A [ggplot2::ggplot] object displaying activity intensity levels over time.
#'
#' @seealso [activity_chart()] for activity types, [steps_chart()] for step counts
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Activity intensity are not available in the example data,
#' # but this is how you would show them:
#' activity_intensity_chart(dynamic_data)
#' }
activity_intensity_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset"
) {
  discrete_chart(
    .data,
    types = c(
      "ActivitySedentaryBinary",
      "ActivityLowBinary",
      "ActivityMidBinary",
      "ActivityHighBinary"
    ),
    names = c("Sedentary", "Low", "Medium", "High"),
    start = start,
    end = end,
    variable = variable,
    value = value,
    tz_offset = tz_offset
  ) +
    labs(y = "Activity intensity")
}

#' Create a step count chart
#'
#' Creates a visualization of cumulative step counts over time from wearable data. The chart
#' displays steps as a line graph with the cumulative count building up throughout each day.
#'
#' @inheritParams continuous_chart
#'
#' @return A [ggplot2::ggplot] object displaying cumulative step counts faceted by date.
#'
#' @seealso [activity_chart()] for activity types, [activity_intensity_chart()] for intensity
#'   levels
#'
#' @export
#'
#' @examples
#' steps_chart(dynamic_data)
steps_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset"
) {
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)
  value <- rlang::ensym(value)

  # Extract and clean the values
  .data <- .data |>
    filter({{ variable }} == "Steps") |>
    drop_na({{ value }}) |>
    mutate({{ value }} := as.integer({{ value }}))

  # If there are no end values, consider the measurements are "momentary", and set the end time
  # to be the same as the start time.
  .data <- .data |>
    mutate({{ end }} := dplyr::coalesce({{ end }}, {{ start }}))

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # Clean up the timestamps
  .data <- .data |>
    arrange({{ start }}, {{ end }}) |>
    mutate(date = lubridate::date({{ start }}))

  # Make sure that the step count is cumulative
  .data <- .data |>
    group_by(date) |>
    mutate({{ value }} := cumsum({{ value }})) |>
    ungroup()

  # Get timestamp for the next value
  # .data <- .data |>
  #   group_by(date) |>
  #   mutate(next_value = lead({{ value }})) |>
  #   ungroup()

  # Calculate the minimum and maximum times for the dates to ensure that all facet panels are
  # 24 hours long
  min_max_times <- .data |>
    distinct(date) |>
    mutate(min = as.POSIXct(paste0(date, "00:00:00"))) |>
    mutate(max = as.POSIXct(paste0(date, "23:59:59"))) |>
    pivot_longer(c("min", "max"), names_to = NULL, values_to = "time")

  # Ensure that days always start at 0 steps
  start_points <- .data |>
    distinct(date) |>
    mutate({{ start }} := as.POSIXct(paste0(date, "00:00:00"))) |>
    mutate({{ end }} := {{ start }}) |>
    mutate({{ value }} := 0)

  .data <- .data |>
    bind_rows(start_points) |>
    arrange({{ start }}, {{ end }})

  # Since steps are cumulative, ensure that measurements are contiguous. If there are no
  # measurements, this is an indication of no steps and not necessarily of missed measurements.
  .data <- .data |>
    group_by(date) |>
    mutate({{ end }} := lead({{ start }})) |>
    mutate(next_value = lead({{ value }})) |>
    ungroup()

  # Build the plot
  p <- .data |>
    ggplot() +
    geom_segment(aes(
      x = {{ start }},
      xend = {{ end }},
      y = {{ value }},
      colour = {{ value }}
    )) +
    geom_segment(aes(
      x = {{ end }},
      y = {{ value }},
      yend = .data$next_value,
      colour = {{ value }}
    )) +
    geom_blank(
      aes(x = .data$time),
      data = min_max_times
    ) +
    scale_color_viridis_c(name = "Steps", option = "plasma", direction = -1) +
    scale_x_datetime(
      date_breaks = "6 hours",
      date_labels = "%H:%M"
    ) +
    facet_wrap(vars(.data$date), scales = "free_x") +
    labs(
      x = "Time",
      y = "Step count"
    )

  p
}
