# Create a stress level chart

Creates a visualization of continuous stress level measurements over
time from wearable data. Stress values are shown on a scale of 0 to 100.

## Usage

``` r
stress_chart(
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
  the daily average stress level.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying stress levels faceted by date.

## See also

[`stress_chart_discrete()`](https://koenniem.github.io/mpathwear/reference/stress_chart_discrete.md)
for discrete stress states

## Examples

``` r
stress_chart(dynamic_data)
#> Warning: Removed 1 row containing missing values or values outside the scale range
#> (`geom_segment()`).
```
