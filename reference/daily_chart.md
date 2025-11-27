# Create a daily summary chart

Creates a line chart visualization of daily summary wearable data
metrics over time for a single participant. Each variable is displayed
in its own facet with points connected by lines.

## Usage

``` r
daily_chart(.data, day = "day", variable = "variable", value = "value")
```

## Arguments

- .data:

  A data frame containing the daily wearable data, typically from
  [`clean_daily_data()`](https://koenniem.github.io/mpathwear/reference/clean_daily_data.md).

- day:

  The name of the column containing date values. Defaults to `"day"`.

- variable:

  The name of the column containing variable names. Defaults to
  `"variable"`.

- value:

  The name of the column containing measurement values. Defaults to
  `"value"`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying daily metrics as line charts faceted by variable type.
