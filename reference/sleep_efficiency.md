# Calculate sleep efficiency

Calculates sleep efficiency as the ratio of actual sleep time to time
spent in bed. Sleep efficiency is computed as
`(SleepInBedDuration - SleepAwakeDuration) / SleepInBedDuration`.

## Usage

``` r
sleep_efficiency(
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

A data frame with columns for `day` and `SleepEfficiency` (as a
proportion between 0 and 1).

## See also

[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_score()`](https://koenniem.github.io/mpathwear/reference/sleep_score.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
# Calculate the total sleep efficiency from
# intraday (dynamic) data.
sleep_efficiency(dynamic_data)
#> # A tibble: 15 × 2
#>    day        SleepEfficiency
#>    <date>               <dbl>
#>  1 2025-11-12           0.974
#>  2 2025-11-13           0.955
#>  3 2025-11-14           0.942
#>  4 2025-11-15           0.915
#>  5 2025-11-16           0.973
#>  6 2025-11-17           0.990
#>  7 2025-11-18           0.868
#>  8 2025-11-19           0.908
#>  9 2025-11-20           0.882
#> 10 2025-11-21           0.941
#> 11 2025-11-22           0.845
#> 12 2025-11-23           0.872
#> 13 2025-11-24           0.898
#> 14 2025-11-25           0.928
#> 15 2025-11-26           0.888

# We can compare this to the sleep efficiency from the
# daily data.
daily_data[daily_data$variable == "SleepEfficiency", c("day", "value")]
#> # A tibble: 15 × 2
#>    day        value
#>    <date>     <chr>
#>  1 2025-11-12 98   
#>  2 2025-11-13 96   
#>  3 2025-11-14 94   
#>  4 2025-11-15 91   
#>  5 2025-11-16 97   
#>  6 2025-11-17 99   
#>  7 2025-11-18 87   
#>  8 2025-11-19 91   
#>  9 2025-11-20 88   
#> 10 2025-11-21 94   
#> 11 2025-11-22 85   
#> 12 2025-11-23 87   
#> 13 2025-11-24 90   
#> 14 2025-11-25 93   
#> 15 2025-11-26 89   
```
