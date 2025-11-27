# Calculate total awake duration during sleep

Calculates the total time spent awake during sleep periods for each
night from intraday wearable data.

## Usage

``` r
sleep_awake_duration(
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

A data frame with columns for `day` and `SleepAwakeDuration` (in
seconds).

## See also

[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
# Calculate the total awake duration during sleep from
# intraday (dynamic) data.
sleep_awake_duration(dynamic_data)
#> # A tibble: 15 × 2
#>    day        SleepAwakeDuration
#>    <date>                  <int>
#>  1 2025-11-12                600
#>  2 2025-11-13               1140
#>  3 2025-11-14               1560
#>  4 2025-11-15               3000
#>  5 2025-11-16                840
#>  6 2025-11-17                240
#>  7 2025-11-18               3900
#>  8 2025-11-19               2460
#>  9 2025-11-20               3720
#> 10 2025-11-21               1740
#> 11 2025-11-22               5700
#> 12 2025-11-23               4080
#> 13 2025-11-24               2640
#> 14 2025-11-25               2040
#> 15 2025-11-26               2520

# We can compare this to the awake duration from the
# daily data.
# Note that in the daily data, the awake duration is shown
# in minutes instead of seconds.
daily_data[daily_data$variable == "SleepAwakeDuration", c("day", "value")]
#> # A tibble: 15 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 10   
#>  2 2025-11-13 19   
#>  3 2025-11-14 26   
#>  4 2025-11-15 50   
#>  5 2025-11-16 14   
#>  6 2025-11-17 4    
#>  7 2025-11-18 65   
#>  8 2025-11-19 41   
#>  9 2025-11-20 62   
#> 10 2025-11-21 29   
#> 11 2025-11-22 95   
#> 12 2025-11-23 68   
#> 13 2025-11-24 44   
#> 14 2025-11-25 34   
#> 15 2025-11-26 42   
```
