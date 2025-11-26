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

The scoring is based on Arora, A., Chakraborty, P., & Bhatia, M. P. S.
(2020). Analysis of Data from Wearable Sensors for Sleep Quality
Estimation and Prediction Using Deep Learning. Arabian Journal for
Science and Engineering, 45(12), 10793-10812.

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
