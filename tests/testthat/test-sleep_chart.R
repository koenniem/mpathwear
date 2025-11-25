generate_sleep_test_data <- function(n_participants = 2) {
  base_time <- as.POSIXct("2024-01-01 23:00:00", tz = "UTC")
  minutes <- 480 # 8 hours of data

  purrr::map_dfr(1:n_participants, function(id) {
    start_time <- base_time + lubridate::days(id - 1)
    df <- tibble(
      timestamp = start_time + lubridate::minutes(0:(minutes - 1)),
      tz_offset = 0
    )

    bind_rows(
      df |>
        filter(dplyr::between(timestamp, start_time, start_time + lubridate::dhours(2) - 1)) |>
        mutate(variable = "SleepLightBinary"),
      df |>
        filter(dplyr::between(
          timestamp,
          start_time + lubridate::dhours(2),
          start_time + lubridate::dhours(4) - 1
        )) |>
        mutate(variable = "SleepDeepBinary"),
      df |>
        filter(dplyr::between(
          timestamp,
          start_time + lubridate::dhours(4),
          start_time + lubridate::dhours(6) - 1
        )) |>
        mutate(variable = "SleepREMBinary"),
      df |>
        filter(dplyr::between(
          timestamp,
          start_time + lubridate::dhours(6),
          start_time + lubridate::dhours(8) - 1
        )) |>
        mutate(variable = "SleepAwakeBinary"),
      df |> mutate(variable = "SleepStateBinary"),
      df |> mutate(variable = "SleepInBedBinary")
    ) |>
      mutate(
        connectionId = paste0("user", id),
        start_time = timestamp,
        end_time = timestamp + lubridate::dminutes(1)
      ) |>
      select("connectionId", "start_time", "end_time", "variable", "tz_offset")
  })
}

sleep_test_data <- generate_sleep_test_data()


test_that(".sleep_prep handles multiple users correctly", {
  df <- .sleep_prep(sleep_test_data, vars = "SleepAwakeBinary")
  expect_true(all(df$variable == "SleepAwakeBinary"))
  expect_gt(dplyr::n_distinct(df$connectionId), 1)
  expect_s3_class(df$day, "Date")
})

test_that("sleep_awake_duration returns 2 hours per user", {
  df <- sleep_awake_duration(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepAwakeDuration == 60 * 60 * 2))
})

test_that("sleep_rem_duration returns 2 hours per user", {
  df <- sleep_rem_duration(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepREMDuration == 60 * 60 * 2))
})

test_that("sleep_deep_duration returns 2 hours per user", {
  df <- sleep_deep_duration(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepDeepDuration == 60 * 60 * 2))
})

test_that("sleep_in_bed_duration returns 8 hours per user", {
  df <- sleep_in_bed_duration(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepInBedDuration == 60 * 60 * 8))
})

test_that("sleep_duration returns 6 hours per user", {
  df <- sleep_duration(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepDuration == 60 * 60 * 6))
})

test_that("sleep_onset_latency is 0 for all users", {
  df <- sleep_onset_latency(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepOnSetLatency == 0))
})

test_that("sleep_efficiency is 75% for all users", {
  df <- sleep_efficiency(sleep_test_data)
  expect_equal(nrow(df), 2)
  expect_true(all(df$SleepEfficiency == 0.75))
})
