# Create a continuous value chart

Internal function that creates a faceted line chart for continuous
wearable data measurements over time.

## Usage

``` r
continuous_chart(.data, type, start, end, variable, value, tz_offset)
```

## Arguments

- .data:

  A data frame containing the wearable data.

- type:

  A character vector of variable types to filter for (e.g., "HeartRate",
  "Stress").

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
object displaying the continuous data as a line chart faceted by date.
