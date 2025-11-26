# Calculate time spent in bed

Calculates the total duration spent in bed (from first to last
sleep-related measurement) for each night, regardless of whether the
person was asleep or awake.

## Usage

``` r
sleep_in_bed_duration(
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

A data frame with columns for `day` and `SleepInBedDuration` (in
seconds).

## See also

[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)
