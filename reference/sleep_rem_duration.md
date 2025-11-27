# Calculate total REM sleep duration

Calculates the total time spent in REM sleep for each night from
intraday wearable data.

## Usage

``` r
sleep_rem_duration(
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

A data frame with columns for `day` and `SleepREMDuration` (in seconds).

## See also

[`sleep_deep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_deep_duration.md),
[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
#' # Calculate the total REM duration during sleep from
# intraday (dynamic) data.
sleep_rem_duration(dynamic_data)
#> # A tibble: 14 × 2
#>    day        SleepREMDuration
#>    <date>                <int>
#>  1 2025-11-12             4260
#>  2 2025-11-13             3600
#>  3 2025-11-14             1680
#>  4 2025-11-15             2878
#>  5 2025-11-16             4740
#>  6 2025-11-17             4800
#>  7 2025-11-18             3960
#>  8 2025-11-19             3240
#>  9 2025-11-20             4680
#> 10 2025-11-21             2880
#> 11 2025-11-22             5400
#> 12 2025-11-23             2811
#> 13 2025-11-24             3480
#> 14 2025-11-25             3000

# We can compare this to the REM duration from the
# daily data.
# Note that in the daily data, the REM duration is shown
# in minutes instead of seconds.
daily_data[daily_data$variable == "SleepREMDuration", c("day", "value")]
#> # A tibble: 14 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 71   
#>  2 2025-11-13 60   
#>  3 2025-11-14 28   
#>  4 2025-11-15 48   
#>  5 2025-11-16 79   
#>  6 2025-11-17 80   
#>  7 2025-11-18 66   
#>  8 2025-11-19 54   
#>  9 2025-11-20 78   
#> 10 2025-11-21 48   
#> 11 2025-11-22 90   
#> 12 2025-11-23 47   
#> 13 2025-11-24 58   
#> 14 2025-11-25 50   
```
