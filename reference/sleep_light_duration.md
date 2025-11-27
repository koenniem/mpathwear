# Calculate total light sleep duration

Calculates the total time spent in light sleep for each night from
intraday wearable data.

## Usage

``` r
sleep_light_duration(
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

A data frame with columns for `day` and `SleepLightDuration` (in
seconds).

## See also

[`sleep_deep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_deep_duration.md),
[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
#' # Calculate the total light sleep duration during sleep from
# intraday (dynamic) data.
sleep_light_duration(dynamic_data)
#> # A tibble: 15 × 2
#>    day        SleepLightDuration
#>    <date>                  <int>
#>  1 2025-11-12              16200
#>  2 2025-11-13              16380
#>  3 2025-11-14              17880
#>  4 2025-11-15              23160
#>  5 2025-11-16              21000
#>  6 2025-11-17              16740
#>  7 2025-11-18              16920
#>  8 2025-11-19              16980
#>  9 2025-11-20              18480
#> 10 2025-11-21              17280
#> 11 2025-11-22              19680
#> 12 2025-11-23              21720
#> 13 2025-11-24              15540
#> 14 2025-11-25              15240
#> 15 2025-11-26              16200

# We can compare this to the light sleep duration from the
# daily data.
# Note that in the daily data, the sleep light duration is shown
# in minutes instead of seconds.
daily_data[daily_data$variable == "SleepLightDuration", c("day", "value")]
#> # A tibble: 15 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 272  
#>  2 2025-11-13 273  
#>  3 2025-11-14 298  
#>  4 2025-11-15 386  
#>  5 2025-11-16 350  
#>  6 2025-11-17 279  
#>  7 2025-11-18 282  
#>  8 2025-11-19 283  
#>  9 2025-11-20 308  
#> 10 2025-11-21 288  
#> 11 2025-11-22 328  
#> 12 2025-11-23 362  
#> 13 2025-11-24 259  
#> 14 2025-11-25 254  
#> 15 2025-11-26 270  
```
