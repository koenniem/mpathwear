# Calculate total sleep duration

Calculates the total time spent asleep (excluding awake periods) for
each night from intraday wearable data. This includes light, REM, and
deep sleep stages.

## Usage

``` r
sleep_duration(
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

A data frame with columns for `day` and `SleepDuration` (in seconds).

## See also

[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_score()`](https://koenniem.github.io/mpathwear/reference/sleep_score.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
# Calculate the total sleep duration from
# intraday (dynamic) data.
sleep_duration(dynamic_data)
#> # A tibble: 15 × 2
#>    day        SleepDuration
#>    <date>             <int>
#>  1 2025-11-12         23520
#>  2 2025-11-13         25440
#>  3 2025-11-14         26700
#>  4 2025-11-15         35158
#>  5 2025-11-16         30600
#>  6 2025-11-17         25140
#>  7 2025-11-18         29640
#>  8 2025-11-19         26820
#>  9 2025-11-20         31500
#> 10 2025-11-21         29520
#> 11 2025-11-22         36780
#> 12 2025-11-23         31971
#> 13 2025-11-24         25920
#> 14 2025-11-25         28500
#> 15 2025-11-26         22440

# We can compare this to the sleep duration from the
# daily data.
# Note that in the daily data, the sleep duration is shown
# in minutes instead of seconds.
daily_data[daily_data$variable == "SleepDuration", c("day", "value")]
#> # A tibble: 15 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 428  
#>  2 2025-11-13 405  
#>  3 2025-11-14 419  
#>  4 2025-11-15 536  
#>  5 2025-11-16 496  
#>  6 2025-11-17 415  
#>  7 2025-11-18 429  
#>  8 2025-11-19 406  
#>  9 2025-11-20 463  
#> 10 2025-11-21 463  
#> 11 2025-11-22 518  
#> 12 2025-11-23 465  
#> 13 2025-11-24 388  
#> 14 2025-11-25 441  
#> 15 2025-11-26 332  
```
