# Create a sleep stages chart

Creates a visualization of sleep stages (Awake, REM, Light, Deep) over
time from wearable data. The chart shows sleep stage transitions
throughout each night.

## Usage

``` r
sleep_chart(
  .data,
  start = "start_time",
  end = "end_time",
  variable = "variable",
  tz_offset = "tz_offset",
  add_bed_time = TRUE
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

- add_bed_time:

  Logical. If `TRUE` (default), adds dotted vertical lines and labels
  showing bedtime and wake time.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object displaying sleep stages faceted by night.

## See also

[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_score()`](https://koenniem.github.io/mpathwear/reference/sleep_score.md)
for sleep metrics

## Examples

``` r
# Show the sleep chart of a single participant
sleep_chart(dynamic_data)


# Optionally, show the sleep chart without bed and wakeup times
sleep_chart(dynamic_data, add_bed_time = FALSE)
```
