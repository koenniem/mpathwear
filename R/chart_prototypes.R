#' Create a continuous value chart
#'
#' Internal function that creates a faceted line chart for continuous wearable data measurements
#' over time.
#'
#' @param .data A data frame containing the wearable data.
#' @param type A character vector of variable types to filter for (e.g., "HeartRate", "Stress").
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#'
#' @return A [ggplot2::ggplot] object displaying the continuous data as a line chart faceted by
#'   date.
#'
#' @keywords internal
continuous_chart <- function(
  .data,
  type,
  start,
  end,
  variable,
  value,
  tz_offset
) {
  .data <- check_multiple_ids(.data)

  force(start)
  force(end)
  force(variable)
  force(value)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)
  value <- rlang::ensym(value)

  # Extract and clean the values
  .data <- .data |>
    filter({{ variable }} %in% type) |>
    drop_na({{ value }}) |>
    mutate({{ value }} := as.integer({{ value }}))

  # If there are no end values, consider the measurements are "momentary", and set the end time
  # to be the same as the start time.
  .data <- .data |>
    mutate({{ end }} := dplyr::coalesce({{ end }}, {{ start }}))

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # Clean up the timestamps and get timestamp for the next value
  .data <- .data |>
    arrange({{ start }}, {{ end }}) |>
    mutate(next_value = lead({{ value }})) |>
    mutate(date = lubridate::date({{ start }}))

  # Calculate the minimum and maximum times for the dates to ensure that all facet panels are
  # 24 hours long
  min_max_times <- .data |>
    distinct(.data$date) |>
    mutate(min = as.POSIXct(paste0(.data$date, "00:00:00"))) |>
    mutate(max = as.POSIXct(paste0(.data$date, "23:59:59"))) |>
    pivot_longer(c("min", "max"), names_to = NULL, values_to = "time")

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
    scale_color_viridis_c(
      name = .data$type,
      option = "plasma",
      direction = -1
    ) +
    scale_x_datetime(
      date_breaks = "6 hours",
      date_labels = "%H:%M"
    ) +
    facet_wrap(vars(.data$date), scales = "free_x") +
    labs(
      x = "Time",
      y = "Stress"
    )

  p
}

#' Create a discrete state chart
#'
#' Internal function that creates a faceted segment chart for discrete wearable data states
#' over time (e.g., sleep stages, activity intensity levels).
#'
#' @param .data A data frame containing the wearable data.
#' @param types A character vector of variable types to filter for.
#' @param names A character vector of display names corresponding to the types.
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param value The name of the column containing measurement values. Defaults to `"value"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#' @param .call The calling environment for error messages.
#'
#' @return A [ggplot2::ggplot] object displaying the discrete states as horizontal segments
#'   faceted by day.
#'
#' @keywords internal
discrete_chart <- function(
  .data,
  types,
  names,
  start,
  end,
  variable,
  value,
  tz_offset,
  .call = rlang::caller_env()
) {
  .data <- check_multiple_ids(.data)

  force(start)
  force(end)
  force(variable)
  force(value)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  # Extract the variables related to sleep
  .data <- .data |>
    filter({{ variable }} %in% types)

  if (nrow(.data) == 0) {
    cli::cli_abort(
      c(
        paste0(
          "There was no data in ",
          variable,
          " for the following variables types: ",
          paste("'", types, "'", collapse = ", ")
        )
      ),
      call = .call
    )
  }

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # Set the factor levels
  matches <- paste0("\"", types, "\"", "~", "\"", names, "\"")
  matches <- lapply(matches, str2lang)
  matches <- lapply(matches, eval)

  .data <- .data |>
    mutate(
      {{ variable }} := case_match(
        {{ variable }},
        !!!matches,
        .ptype = "factor"
      )
    ) |>
    mutate(
      {{ variable }} := factor(
        x = {{ variable }},
        levels = names
      )
    )

  # Determine the days
  .data <- .data |>
    mutate(day = cut({{ end }}, "days"))

  # Calculate the subsequent sleep phase
  .data <- .data |>
    arrange({{ start }}, {{ end }}) |>
    group_by(.data$day) |>
    mutate(next_state = lead({{ variable }})) |>
    mutate(
      next_state = dplyr::if_else(
        is.na(.data$next_state),
        {{ variable }},
        .data$next_state
      )
    ) |>
    ungroup()

  # Create the plot
  p <- .data |>
    ggplot() +
    geom_segment(
      aes(
        x = {{ start }},
        xend = {{ end }},
        y = {{ variable }},
        colour = {{ variable }}
      ),
      linewidth = 2
    ) +
    geom_segment(
      aes(
        x = {{ end }},
        y = {{ variable }},
        yend = .data$next_state
      ),
      alpha = 0.5,
      colour = "grey",
      linetype = "dashed"
    ) +
    scale_colour_discrete(guide = NULL) +
    scale_x_datetime(
      date_breaks = "2 hours",
      date_labels = "%H:%M"
    ) +
    scale_y_discrete(drop = FALSE) +
    facet_wrap(vars(.data$day), scales = "free_x", drop = FALSE) +
    labs(
      x = "Time",
      y = "State",
    )

  p
}
