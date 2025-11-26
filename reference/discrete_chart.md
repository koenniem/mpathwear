# Create a discrete state chart

Internal function that creates a faceted segment chart for discrete
wearable data states over time (e.g., sleep stages, activity intensity
levels).

## Usage

``` r
discrete_chart(
  .data,
  types,
  names,
  start,
  end,
  variable,
  value,
  tz_offset,
  .call = rlang::caller_env()
)
```

## Arguments

- .data:

  A data frame containing the wearable data.

- types:

  A character vector of variable types to filter for.

- names:

  A character vector of display names corresponding to the types.

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

- .call:

  The calling environment for error messages.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying the discrete states as horizontal segments faceted by
day.
