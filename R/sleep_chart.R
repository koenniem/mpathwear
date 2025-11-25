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


# Daily variable SleepAwakeDuration based on intraday data
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

# Daily variable SleepREMDuration based on intraday data
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

# Daily variable SleepDeepDuration based on intraday data
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

# Refers to the duration spent in bed trying to sleep regardless of sleeping or awake phases.
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

# Total sleep duration, without being awake
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

# First SleepInBeDuration until the first SleepAwakeBinary
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


# Established Indicator describing the likelihood that any two time-points 24 hours apart were the
# same sleep/wake state, across all days.
# Well-established indicator, describing the longterm likelihood of being asleep at the same time as
# in the previous day. Values below 60% are associated with a significantly higher likelihood for
# Alzheimer disease, depression and cardiovascular diseases.
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

# Based on Arora, A., Chakraborty, P., & Bhatia, M. P. S. (2020). Analysis of Data from Wearable
# Sensors for Sleep Quality Estimation and Prediction Using Deep Learning. Arabian Journal for
# Science and Engineering, 45(12), 10793–10812. https://doi.org/10.1007/s13369-020-04877-w
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
