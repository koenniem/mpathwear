# Calculate sleep onset latency

Calculates the time between getting into bed and falling asleep for each
night. This is the duration from the first `SleepInBedBinary` to the
first `SleepStateBinary`.

## Usage

``` r
sleep_onset_latency(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset"
)
```

## Arguments

- .data:

  A data frame containing the wearable data, typically from
  [`clean_dynamic_data()`](https://koenniem.github.io/mpathwear/reference/clean_dynamic_data.md).

- start:

  The name of the column containing start timestamps. Defaults to
  `"start_time"`.

- end:

  The name of the column containing end timestamps. Defaults to
  `"end_time"`.

- variable:

  The name of the column containing variable names. Defaults to
  `"variable"`.

- tz_offset:

  The name of the column containing timezone offsets. Defaults to
  `"tz_offset"`.

## Value

A data frame with columns for `day` and `SleepOnSetLatency` (in
seconds).

## See also

[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_score()`](https://koenniem.github.io/mpathwear/reference/sleep_score.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
# Calculate the sleep onset latency from
# intraday (dynamic) data.
sleep_onset_latency(dynamic_data)
#> # A tibble: 15 × 3
#>    connectionId day        SleepOnSetLatency
#>    <chr>        <date>                 <int>
#>  1 123456       2025-11-12                 0
#>  2 123456       2025-11-13                 0
#>  3 123456       2025-11-14                 0
#>  4 123456       2025-11-15                 0
#>  5 123456       2025-11-16                 0
#>  6 123456       2025-11-17                 0
#>  7 123456       2025-11-18                 0
#>  8 123456       2025-11-19                 0
#>  9 123456       2025-11-20                 0
#> 10 123456       2025-11-21                 0
#> 11 123456       2025-11-22                 0
#> 12 123456       2025-11-23                 0
#> 13 123456       2025-11-24                 0
#> 14 123456       2025-11-25                 0
#> 15 123456       2025-11-26                 0

# We can compare this to the sleep onset latency from the
# daily data.
# Note that in the daily data, the sleep onset latency is shown
# in minutes instead of seconds.
daily_data[daily_data$variable == "SleepLatency", c("day", "value")]
#> # A tibble: 0 × 2
#> # ℹ 2 variables: day <date>, value <chr>
```
