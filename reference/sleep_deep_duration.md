# Calculate total deep sleep duration

Calculates the total time spent in deep sleep for each night from
intraday wearable data.

## Usage

``` r
sleep_deep_duration(
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

A data frame with columns for `day` and `SleepDeepDuration` (in
seconds).

## See also

[`sleep_rem_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_rem_duration.md),
[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
# Calculate the total deep sleep duration from
# intraday (dynamic) data.
sleep_deep_duration(dynamic_data)
#> # A tibble: 15 × 2
#>    day        SleepDeepDuration
#>    <date>                 <int>
#>  1 2025-11-12              2460
#>  2 2025-11-13              4320
#>  3 2025-11-14              5580
#>  4 2025-11-15              6120
#>  5 2025-11-16              4020
#>  6 2025-11-17              3360
#>  7 2025-11-18              4860
#>  8 2025-11-19              4140
#>  9 2025-11-20              4620
#> 10 2025-11-21              7620
#> 11 2025-11-22              6000
#> 12 2025-11-23              3360
#> 13 2025-11-24              4260
#> 14 2025-11-25              8220
#> 15 2025-11-26              3720

# We can compare this to the deep sleep duration from the
# daily data.
# Note that in the daily data, the deep sleep duration is shown
# in minutes instead of seconds.
daily_data[daily_data$variable == "SleepDeepDuration", c("day", "value")]
#> # A tibble: 15 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 85   
#>  2 2025-11-13 72   
#>  3 2025-11-14 93   
#>  4 2025-11-15 102  
#>  5 2025-11-16 67   
#>  6 2025-11-17 56   
#>  7 2025-11-18 81   
#>  8 2025-11-19 69   
#>  9 2025-11-20 77   
#> 10 2025-11-21 127  
#> 11 2025-11-22 100  
#> 12 2025-11-23 56   
#> 13 2025-11-24 71   
#> 14 2025-11-25 137  
#> 15 2025-11-26 62   
```
