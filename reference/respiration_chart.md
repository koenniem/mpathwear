# Create a respiration rate chart

Creates a visualization of respiration rate measurements over time from
wearable data.

## Usage

``` r
respiration_chart(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  value = "value",
  tz_offset = "tz_offset"
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

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying respiration rate measurements faceted by date.
