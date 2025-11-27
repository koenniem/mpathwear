# Calculate composite sleep score

Calculates a composite sleep quality score based on multiple sleep
metrics including onset latency, duration, efficiency, awake time, and
proportions of deep and REM sleep.

## Usage

``` r
sleep_score(
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

A data frame with columns for `day` and `sleep_score`. Lower scores
indicate better sleep quality.

## Details

The scoring is based on Arora et al. (2020). The calculated sleep
quality scores ranges from 0 to 14, where a lower scores denotes better
sleep quality.

## References

Arora, A., Chakraborty, P., & Bhatia, M. P. S. (2020). Analysis of Data
from Wearable Sensors for Sleep Quality Estimation and Prediction Using
Deep Learning. Arabian Journal for Science and Engineering, 45(12),
10793-10812.
[doi:10.1007/s13369-020-04877-w](https://doi.org/10.1007/s13369-020-04877-w)

## See also

[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
sleep_score(dynamic_data)
#> # A tibble: 15 × 2
#>    day        sleep_score
#>    <date>           <dbl>
#>  1 2025-11-12           2
#>  2 2025-11-13           1
#>  3 2025-11-14           2
#>  4 2025-11-15           4
#>  5 2025-11-16           1
#>  6 2025-11-17           2
#>  7 2025-11-18           4
#>  8 2025-11-19           4
#>  9 2025-11-20           4
#> 10 2025-11-21           2
#> 11 2025-11-22           5
#> 12 2025-11-23           4
#> 13 2025-11-24           4
#> 14 2025-11-25           3
#> 15 2025-11-26           5
```
