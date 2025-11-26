# Create a heart rate chart

Creates a visualization of heart rate measurements over time from
wearable data. The chart displays heart rate values with optional daily
average lines.

## Usage

``` r
heart_rate_chart(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset",
  add_average = TRUE
)
```

## Arguments

- .data:

  A data frame containing the wearable data.

- start:

  The name of the column containing start timestamps. Defaults to
  `"start_time"`.

- end:

  The name of the column containing end timestamps. Defaults to
  `"end_time"`.

- variable:

  The name of the column containing variable names. Defaults to
  `"variable"`.

- value:

  The name of the column containing measurement values. Defaults to
  `"value"`.

- tz_offset:

  The name of the column containing timezone offsets. Defaults to
  `"tz_offset"`.

- add_average:

  Logical. If `TRUE` (default), adds a dashed horizontal line showing
  the daily average heart rate.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying heart rate measurements faceted by date.

## See also

[`hrv_chart()`](https://koenniem.github.io/mpathwear/reference/hrv_chart.md)
for heart rate variability
