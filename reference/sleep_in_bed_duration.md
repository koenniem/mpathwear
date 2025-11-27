# Calculate time spent in bed

Calculates the total duration spent in bed (from first to last
sleep-related measurement) for each night, regardless of whether the
person was asleep or awake.

## Usage

``` r
sleep_in_bed_duration(
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

A data frame with columns for `day` and `SleepInBedDuration` (in
seconds).

## See also

[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
# Calculate the total sleep in bed duration
# from intraday (dynamic) data.
sleep_in_bed_duration(dynamic_data)
#> # A tibble: 15 × 2
#>    day        SleepInBedDuration
#>    <date>                  <int>
#>  1 2025-11-12              23520
#>  2 2025-11-13              25440
#>  3 2025-11-14              26700
#>  4 2025-11-15              35158
#>  5 2025-11-16              30600
#>  6 2025-11-17              25140
#>  7 2025-11-18              29640
#>  8 2025-11-19              26820
#>  9 2025-11-20              31500
#> 10 2025-11-21              29520
#> 11 2025-11-22              36780
#> 12 2025-11-23              31971
#> 13 2025-11-24              25920
#> 14 2025-11-25              28500
#> 15 2025-11-26              22440

# We can compare this to the sleep in bed duration from the
# daily data.
# Note that in the daily data, the sleep in bed duration
# is shown in minutes instead of seconds.
daily_data[daily_data$variable == "SleepInBedDuration", c("day", "value")]
#> # A tibble: 15 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 438  
#>  2 2025-11-13 424  
#>  3 2025-11-14 445  
#>  4 2025-11-15 586  
#>  5 2025-11-16 510  
#>  6 2025-11-17 419  
#>  7 2025-11-18 494  
#>  8 2025-11-19 447  
#>  9 2025-11-20 525  
#> 10 2025-11-21 492  
#> 11 2025-11-22 613  
#> 12 2025-11-23 533  
#> 13 2025-11-24 432  
#> 14 2025-11-25 475  
#> 15 2025-11-26 374  
```
