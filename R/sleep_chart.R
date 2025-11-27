#' Create a sleep stages chart
#'
#' Creates a visualization of sleep stages (Awake, REM, Light, Deep) over time from wearable
#' data. The chart shows sleep stage transitions throughout each night.
#'
#' @inheritParams .sleep_prep
#' @param add_bed_time Logical. If `TRUE` (default), adds dotted vertical lines and labels
#'   showing bedtime and wake time.
#'
#' @return A [ggplot2::ggplot] object displaying sleep stages faceted by night.
#'
#' @seealso [sleep_duration()], [sleep_efficiency()], [sleep_score()] for sleep metrics
#'
#' @export
#'
#' @examples
#' # Show the sleep chart of a single participant
#' sleep_chart(dynamic_data)
#'
#' # Optionally, show the sleep chart without bed and wakeup times
#' sleep_chart(dynamic_data, add_bed_time = FALSE)
sleep_chart <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset",
  add_bed_time = TRUE
) {
  .data <- check_multiple_ids(.data)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  # Extract the variables related to sleep
  .data <- .data |>
    filter(
      {{ variable }} %in%
        c(
          "SleepLightBinary",
          "SleepREMBinary",
          "SleepDeepBinary",
          "SleepAwakeBinary"
        )
    )

  # Set the factor levels
  .data <- .data |>
    mutate(
      {{ variable }} := case_match(
        variable,
        "SleepAwakeBinary" ~ "Awake",
        "SleepREMBinary" ~ "REM",
        "SleepLightBinary" ~ "Light",
        "SleepDeepBinary" ~ "Deep",
        .ptype = "factor"
      )
    ) |>
    mutate(
      {{ variable }} := factor(
        x = {{ variable }},
        levels = c("Awake", "REM", "Light", "Deep")
      )
    )

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # Determine the nights
  .data <- .data |>
    mutate(day = cut({{ end }} + (12 * 3600), "days"))

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
    scale_y_discrete(limits = rev) +
    scale_colour_discrete(guide = NULL) +
    scale_x_datetime(
      date_breaks = "2 hours",
      date_labels = "%H:%M"
    ) +
    facet_wrap(vars(day), scales = "free_x") +
    labs(
      x = "Time",
      y = "Sleep state",
    )

  # Add the bed and wakeup time to the plot
  if (!add_bed_time) {
    return(p)
  }

  # Calculate the sleep and bed time for each day
  start_sleep <- .data |>
    group_by(.data$day) |>
    summarise(start = min({{ start }}, na.rm = TRUE), .groups = "drop")

  end_sleep <- .data |>
    group_by(.data$day) |>
    summarise(end = max({{ end }}, na.rm = TRUE), .groups = "drop")

  p <- p +
    geom_vline(
      xintercept = start_sleep$start,
      colour = "black",
      linetype = "dotted"
    ) +
    geom_vline(
      xintercept = end_sleep$end,
      colour = "black",
      linetype = "dotted"
    ) +
    geom_text(
      data = start_sleep,
      aes(
        x = start,
        y = 4,
        label = format(start, "%H:%M")
      ),
      alpha = 0.6,
      nudge_y = 0.3,
      nudge_x = 200,
      hjust = 0,
      vjust = 0,
      size = 3
    ) +
    geom_text(
      data = end_sleep,
      aes(
        x = end,
        y = 4,
        label = format(end, "%H:%M")
      ),
      alpha = 0.6,
      nudge_y = 0.3,
      nudge_x = -300,
      hjust = 1,
      vjust = 0,
      size = 3
    )

  p
}


#' Prepare sleep data for analysis
#'
#' Internal helper function that filters and prepares sleep data for duration and metric
#' calculations.
#'
#' @param .data A data frame containing the wearable data, typically from [clean_dynamic_data()].
#' @param vars A character vector of sleep-related variable types to filter for.
#' @param start The name of the column containing start timestamps. Defaults to `"start_time"`.
#' @param end The name of the column containing end timestamps. Defaults to `"end_time"`.
#' @param variable The name of the column containing variable names. Defaults to `"variable"`.
#' @param tz_offset The name of the column containing timezone offsets. Defaults to `"tz_offset"`.
#'
#' @return A data frame with filtered sleep data and an added `day` column representing the
#'   sleep night.
#'
#' @keywords internal
.sleep_prep <- function(
  .data,
  vars,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  force(start)
  force(end)
  force(variable)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  # Extract the variables
  .data <- .data |>
    filter(!!variable %in% vars)

  # Add the timezone offset to the timestamps
  .data <- add_tz_offset(.data, start, end, tz_offset)

  # Determine the nights:
  #  - If the end time is between 0:00 and 12:00, the day is the same as the end time
  #  - If the start time is after 18:00, the day is the next day
  #  - If the start time is before 9:00 and the end time is before 14:00, the day is the same as the end time
  #  - Otherwise, the day is the same as the start time
  .data <- .data |>
    # mutate(day = cut(!!end + (12 * 3600), "days"))
    mutate(
      day = case_when(
        hour(!!end) >= 0 & hour(!!end) < 12 ~ lubridate::date(!!end),
        hour(!!start) >= 18 ~ lubridate::date(!!start) + 1,
        hour(!!start) <= 9 & hour(!!end) <= 14 ~ lubridate::date(!!end),
        .default = lubridate::date(!!start)
      )
    )
  # mutate(day = lubridate::date(!!start + 12 * 3600))

  .data
}


#' Calculate total awake duration during sleep
#'
#' Calculates the total time spent awake during sleep periods for each night from intraday
#' wearable data.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepAwakeDuration` (in seconds).
#'
#' @seealso [sleep_duration()], [sleep_efficiency()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' # Calculate the total awake duration during sleep from
#' # intraday (dynamic) data.
#' sleep_awake_duration(dynamic_data)
#'
#' # We can compare this to the awake duration from the
#' # daily data.
#' # Note that in the daily data, the awake duration is shown
#' # in minutes instead of seconds.
#' daily_data[daily_data$variable == "SleepAwakeDuration", c("day", "value")]
sleep_awake_duration <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  .data <- .sleep_prep(
    .data,
    vars = "SleepAwakeBinary",
    start = start,
    end = end,
    variable = variable,
    tz_offset = tz_offset
  )

  # Calculate the total wake duration per day
  .data <- .data |>
    group_by(.data$day, .add = TRUE) |>
    summarise(
      SleepAwakeDuration = sum(difftime(!!end, !!start, units = "secs")),
      .groups = "drop_last"
    ) |>
    mutate(SleepAwakeDuration = as.integer(.data$SleepAwakeDuration))

  .data
}

#' Calculate total REM sleep duration
#'
#' Calculates the total time spent in REM sleep for each night from intraday wearable data.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepREMDuration` (in seconds).
#'
#' @seealso [sleep_deep_duration()], [sleep_duration()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' #' # Calculate the total REM duration during sleep from
#' # intraday (dynamic) data.
#' sleep_rem_duration(dynamic_data)
#'
#' # We can compare this to the REM duration from the
#' # daily data.
#' # Note that in the daily data, the REM duration is shown
#' # in minutes instead of seconds.
#' daily_data[daily_data$variable == "SleepREMDuration", c("day", "value")]
sleep_rem_duration <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  .data <- .sleep_prep(
    .data,
    vars = "SleepREMBinary",
    start = start,
    end = end,
    variable = variable,
    tz_offset = tz_offset
  )

  # Calculate the total wake duration per day
  .data <- .data |>
    group_by(day, .add = TRUE) |>
    summarise(
      SleepREMDuration = sum(difftime(!!end, !!start, units = "secs")),
      .groups = "drop_last"
    ) |>
    mutate(SleepREMDuration = as.integer(.data$SleepREMDuration))

  .data
}

#' Calculate total deep sleep duration
#'
#' Calculates the total time spent in deep sleep for each night from intraday wearable data.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepDeepDuration` (in seconds).
#'
#' @seealso [sleep_rem_duration()], [sleep_duration()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' # Calculate the total deep sleep duration from
#' # intraday (dynamic) data.
#' sleep_deep_duration(dynamic_data)
#'
#' # We can compare this to the deep sleep duration from the
#' # daily data.
#' # Note that in the daily data, the deep sleep duration is shown
#' # in minutes instead of seconds.
#' daily_data[daily_data$variable == "SleepDeepDuration", c("day", "value")]
sleep_deep_duration <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  .data <- .sleep_prep(
    .data,
    vars = "SleepDeepBinary",
    start = start,
    end = end,
    variable = variable,
    tz_offset = tz_offset
  )

  # Calculate the total wake duration per day
  .data <- .data |>
    group_by(.data$day, .add = TRUE) |>
    summarise(
      SleepDeepDuration = sum(difftime(!!end, !!start, units = "secs")),
      .groups = "drop_last"
    ) |>
    mutate(SleepDeepDuration = as.integer(.data$SleepDeepDuration))

  .data
}

#' Calculate time spent in bed
#'
#' Calculates the total duration spent in bed (from first to last sleep-related measurement)
#' for each night, regardless of whether the person was asleep or awake.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepInBedDuration` (in seconds).
#'
#' @seealso [sleep_duration()], [sleep_efficiency()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' # Calculate the total sleep in bed duration
#' # from intraday (dynamic) data.
#' sleep_in_bed_duration(dynamic_data)
#'
#' # We can compare this to the sleep in bed duration from the
#' # daily data.
#' # Note that in the daily data, the sleep in bed duration
#' # is shown in minutes instead of seconds.
#' daily_data[daily_data$variable == "SleepInBedDuration", c("day", "value")]
sleep_in_bed_duration <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  # .data <- check_multiple_ids(.data)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  .data <- .sleep_prep(
    .data,
    vars = c(
      "SleepLightBinary",
      "SleepREMBinary",
      "SleepDeepBinary",
      "SleepAwakeBinary",
      "SleepInBedBinary",
      "SleepStateBinary"
    ),
    start = start,
    end = end,
    variable = variable,
    tz_offset = tz_offset
  )

  # Calculate the sleep and bed time for each day
  .data <- .data |>
    group_by(.data$day, .add = TRUE) |>
    summarise(
      start = min(!!start, na.rm = TRUE),
      end = max(!!end, na.rm = TRUE),
      .groups = "keep"
    ) |>
    mutate(
      SleepInBedDuration = difftime(.data$end, .data$start, units = "secs"),
      .keep = "none"
    ) |>
    mutate(SleepInBedDuration = as.integer(.data$SleepInBedDuration)) |>
    ungroup("day")

  .data
}

#' Calculate total sleep duration
#'
#' Calculates the total time spent asleep (excluding awake periods) for each night from
#' intraday wearable data. This includes light, REM, and deep sleep stages.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepDuration` (in seconds).
#'
#' @seealso [sleep_efficiency()], [sleep_score()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' # Calculate the total sleep duration from
#' # intraday (dynamic) data.
#' sleep_duration(dynamic_data)
#'
#' # We can compare this to the sleep duration from the
#' # daily data.
#' # Note that in the daily data, the sleep duration is shown
#' # in minutes instead of seconds.
#' daily_data[daily_data$variable == "SleepDuration", c("day", "value")]
sleep_duration <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  # .data <- check_multiple_ids(.data)

  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  .data <- .sleep_prep(
    .data,
    vars = c(
      "SleepLightBinary",
      "SleepREMBinary",
      "SleepDeepBinary"
    ),
    start = start,
    end = end,
    variable = variable,
    tz_offset = tz_offset
  )

  # Calculate the sleep and bed time for each day
  .data <- .data |>
    group_by(.data$day, .add = TRUE) |>
    summarise(
      start = min(!!start, na.rm = TRUE),
      end = max(!!end, na.rm = TRUE),
      .groups = "keep"
    ) |>
    mutate(
      SleepDuration = difftime(.data$end, .data$start, units = "secs"),
      .keep = "none"
    ) |>
    mutate(SleepDuration = as.integer(.data$SleepDuration)) |>
    ungroup("day")

  .data
}

#' Calculate sleep onset latency
#'
#' Calculates the time between getting into bed and falling asleep for each night.
#' This is the duration from the first `SleepInBedBinary` to the first `SleepStateBinary`.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepOnSetLatency` (in seconds).
#'
#' @seealso [sleep_efficiency()], [sleep_score()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' # Calculate the sleep onset latency from
#' # intraday (dynamic) data.
#' sleep_onset_latency(dynamic_data)
#'
#' # We can compare this to the sleep onset latency from the
#' # daily data.
#' # Note that in the daily data, the sleep onset latency is shown
#' # in minutes instead of seconds.
#' daily_data[daily_data$variable == "SleepLatency", c("day", "value")]
sleep_onset_latency <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  .data <- .sleep_prep(
    .data,
    vars = c(
      "SleepInBedBinary",
      "SleepStateBinary"
    ),
    start = start,
    end = end,
    variable = variable,
    tz_offset = tz_offset
  )

  # Calculate the sleep and bed time for each day
  .data <- .data |>
    select("connectionId", "day", !!start, !!variable) |>
    group_by(.data$day, !!variable, .add = TRUE) |>
    slice_min(!!start, n = 1, with_ties = FALSE, na_rm = TRUE) |>
    pivot_wider(names_from = !!variable, values_from = !!start) |>
    mutate(
      SleepOnSetLatency = difftime(
        .data$SleepStateBinary,
        .data$SleepInBedBinary,
        units = "secs"
      )
    ) |>
    mutate(SleepOnSetLatency = as.integer(.data$SleepOnSetLatency)) |>
    ungroup("day") |>
    select(-c("SleepInBedBinary", "SleepStateBinary"))

  .data
}

#' Calculate sleep efficiency
#'
#' Calculates sleep efficiency as the ratio of actual sleep time to time spent in bed.
#' Sleep efficiency is computed as `(SleepInBedDuration - SleepAwakeDuration) / SleepInBedDuration`.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `SleepEfficiency` (as a proportion between
#'   0 and 1).
#'
#' @seealso [sleep_duration()], [sleep_score()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' # Calculate the total sleep efficiency from
#' # intraday (dynamic) data.
#' sleep_efficiency(dynamic_data)
#'
#' # We can compare this to the sleep efficiency from the
#' # daily data.
#' daily_data[daily_data$variable == "SleepEfficiency", c("day", "value")]
sleep_efficiency <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  group_vars <- dplyr::group_vars(.data)

  sleep_in_bed_duration <- sleep_in_bed_duration(
    .data,
    !!start,
    !!end,
    variable,
    tz_offset
  )
  sleep_awake_duration <- sleep_awake_duration(
    .data,
    !!start,
    !!end,
    variable,
    tz_offset
  )

  sleep_efficiency <- sleep_in_bed_duration |>
    dplyr::left_join(sleep_awake_duration, by = c("day", group_vars)) |>
    mutate(
      SleepEfficiency = ifelse(
        .data$SleepInBedDuration > 0,
        (.data$SleepInBedDuration - .data$SleepAwakeDuration) /
          .data$SleepInBedDuration,
        NA
      )
    ) |>
    select(-c("SleepInBedDuration", "SleepAwakeDuration"))

  sleep_efficiency
}


#' Calculate sleep regularity index
#'
#' Calculates the Sleep Regularity Index (SRI), which describes the likelihood that any two
#' time-points 24 hours apart were in the same sleep/wake state across all days. This is a
#' well-established indicator of sleep consistency.
#'
#' Values below 60% are associated with a significantly higher likelihood for Alzheimer's
#' disease, depression, and cardiovascular diseases.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with the `sleep_regularity` score (ranging from -100 to 100, where
#'   100 indicates perfect regularity).
#'
#' @note This function requires the `mpathsenser` package to be installed.
#'
#' @seealso [sleep_score()], [sleep_chart()]
#'
#' @export
#'
#' @examples
#' sleep_regularity(dynamic_data)
sleep_regularity <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  start <- rlang::ensym(start)
  end <- rlang::ensym(end)
  variable <- rlang::ensym(variable)

  # Extract the variables related to sleep
  .data <- .data |>
    filter(
      !!variable %in%
        c(
          "SleepLightBinary",
          "SleepREMBinary",
          "SleepDeepBinary",
          "SleepStateBinary"
        )
    )

  # Only retain the timestamps and grouping variables
  .data <- .data |>
    distinct(!!start, !!end) |>
    mutate(sleeping = TRUE)

  # Bin the data into 1 minute epochs
  check_suggested("mpathsenser")
  .data <- .data |>
    mpathsenser::bin_data(
      !!start,
      !!end,
      by = "min",
      fixed = TRUE
    ) |>
    unnest("bin_data", keep_empty = TRUE) |>
    select(-c(!!start, !!end)) |>
    mutate(sleeping = ifelse(is.na(.data$sleeping), FALSE, .data$sleeping)) |>
    distinct()

  # Fill the data with the other epochs
  .data <- .data |>
    tidyr::complete(
      bin = seq.POSIXt(
        from = min(.data$bin, na.rm = TRUE),
        to = max(.data$bin, na.rm = TRUE),
        by = "min"
      ),
      fill = list(sleeping = FALSE)
    )

  # Put the day and time in a separate column
  .data <- .data |>
    mutate(day = lubridate::date(.data$bin)) |>
    mutate(bin = format(.data$bin, "%X"))

  # Create a column for whether the participant was sleeping at this time (bin) the next day
  .data <- .data |>
    group_by(.data$bin, .add = TRUE) |>
    mutate(next_day = lead(.data$sleeping)) |>
    ungroup("bin") |>
    filter(.data$sleeping)

  n_epochs <- .data |>
    drop_na("sleeping", "next_day") |>
    dplyr::count()

  # Calculate the agreement between two days
  .data <- .data |>
    mutate(agreement = .data$sleeping == .data$next_day) |>
    summarise(sum_agreement = sum(.data$agreement, na.rm = TRUE), .groups = "keep")

  # Merge with the number of epochs and calculate the sleep regularity score
  .data <- .data |>
    left_join(n_epochs) |>
    mutate(sleep_regularity = -100 + (200 / .data$n * .data$sum_agreement)) |>
    select(-c("sum_agreement", "n")) |>
    suppressMessages()

  .data
}

#' Calculate composite sleep score
#'
#' Calculates a composite sleep quality score based on multiple sleep metrics including onset
#' latency, duration, efficiency, awake time, and proportions of deep and REM sleep.
#'
#' The scoring is based on Arora, A., Chakraborty, P., & Bhatia, M. P. S. (2020). Analysis of
#' Data from Wearable Sensors for Sleep Quality Estimation and Prediction Using Deep Learning.
#' Arabian Journal for Science and Engineering, 45(12), 10793-10812.
#'
#' @inheritParams .sleep_prep
#'
#' @return A data frame with columns for `day` and `sleep_score`. Lower scores indicate better
#'   sleep quality.
#'
#' @references
#' Arora, A., Chakraborty, P., & Bhatia, M. P. S. (2020). Analysis of Data from Wearable
#' Sensors for Sleep Quality Estimation and Prediction Using Deep Learning. Arabian Journal
#' for Science and Engineering, 45(12), 10793-10812. \doi{10.1007/s13369-020-04877-w}
#'
#' @seealso [sleep_duration()], [sleep_efficiency()], [sleep_chart()]
#'
#' @export
sleep_score <- function(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
) {
  onset <- sleep_onset_latency(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  duration <- sleep_duration(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  efficiency <- sleep_efficiency(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  awake <- sleep_awake_duration(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  deep <- sleep_deep_duration(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  rem <- sleep_rem_duration(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  sleep_in_bed <- sleep_in_bed_duration(
    .data,
    {{ start }},
    {{ end }},
    {{ variable }},
    tz_offset
  )

  group_vars <- dplyr::group_vars(.data)
  sleep_data <- onset |>
    dplyr::full_join(duration, by = c(group_vars, "day")) |>
    dplyr::full_join(efficiency, by = c(group_vars, "day")) |>
    dplyr::full_join(awake, by = c(group_vars, "day")) |>
    dplyr::full_join(deep, by = c(group_vars, "day")) |>
    dplyr::full_join(rem, by = c(group_vars, "day")) |>
    dplyr::full_join(sleep_in_bed, by = c(group_vars, "day"))

  # Calculate the percentage of total time for REM and Deep sleep
  sleep_data <- sleep_data |>
    mutate(
      SleepREMPercentage = ifelse(
        .data$SleepDuration > 0,
        .data$SleepREMDuration / .data$SleepInBedDuration,
        NA
      ),
      SleepDeepPercentage = ifelse(
        .data$SleepDuration > 0,
        .data$SleepDeepDuration / .data$SleepInBedDuration,
        NA
      )
    )

  # Score data
  sleep_data <- sleep_data |>
    mutate(
      SleepOnSetLatency = case_when(
        .data$SleepOnSetLatency <= 900 ~ 0,
        .data$SleepOnSetLatency <= 1800 ~ 1,
        .data$SleepOnSetLatency <= 3600 ~ 2,
        .default = 3
      )
    ) |>
    mutate(
      SleepDuration = case_when(
        .data$SleepDuration > 25200 ~ 0,
        .data$SleepDuration > 21600 ~ 1,
        .data$SleepDuration > 18000 ~ 2,
        .default = 3
      )
    ) |>
    mutate(
      SleepEfficiency = case_when(
        .data$SleepEfficiency >= 0.85 ~ 0,
        .data$SleepEfficiency >= 0.75 ~ 1,
        .data$SleepEfficiency >= 0.65 ~ 2,
        .default = 3
      )
    ) |>
    mutate(
      SleepAwakeDuration = case_when(
        .data$SleepAwakeDuration <= 1200 ~ 0,
        .data$SleepAwakeDuration <= 1800 ~ 1,
        .data$SleepAwakeDuration <= 2400 ~ 2,
        .default = 3
      )
    ) |>
    mutate(
      SleepDeepPercentage = case_when(
        .data$SleepDeepPercentage >= 0.1 ~ 0,
        .default = 1
      )
    ) |>
    mutate(
      SleepREMPercentage = case_when(
        dplyr::between(.data$SleepREMPercentage, 0.2, 0.25) ~ 0,
        .default = 1
      )
    )

  # Calculate sleep score
  sleep_data <- sleep_data |>
    mutate(
      sleep_score = .data$SleepOnSetLatency +
        .data$SleepDuration +
        .data$SleepEfficiency +
        .data$SleepAwakeDuration +
        .data$SleepREMPercentage +
        .data$SleepDeepPercentage
    ) |>
    select(all_of(c(group_vars, "day", "sleep_score")))

  sleep_data
}
