# Create a heart rate variability (HRV) chart

Creates a visualization of heart rate variability measurements over time
from wearable data. HRV metrics include RMSSD, SDNN, and SDRR.

## Usage

``` r
hrv_chart(
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
  the daily average HRV.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying HRV measurements faceted by date.

## See also

[`heart_rate_chart()`](https://koenniem.github.io/mpathwear/reference/heart_rate_chart.md)
for heart rate measurements
