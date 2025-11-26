# Create a daily data coverage chart

Creates a tile-based visualization showing which days have data coverage
for each participant and variable type. This provides a clear overview
of data availability at the daily level.

## Usage

``` r
daily_coverage_chart(
  .data,
  participant = "connectionId",
  time = "day",
  variable = "variable"
)
```

## Arguments

- .data:

  A data frame containing the wearable data, typically from
  [`clean_daily_data()`](https://koenniem.github.io/mpathwear/reference/clean_daily_data.md).

- participant:

  The name of the column containing participant identifiers. Defaults to
  `"connectionId"`.

- time:

  The name of the column containing day/date values. Defaults to
  `"day"`.

- variable:

  The name of the column containing variable names. Defaults to
  `"variable"`.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying daily data coverage as tiles per participant, faceted
by variable type.

## See also

[`coverage_chart()`](https://koenniem.github.io/mpathwear/reference/coverage_chart.md)
for intraday coverage
