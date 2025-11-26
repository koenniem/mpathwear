# Calculate total REM sleep duration

Calculates the total time spent in REM sleep for each night from
intraday wearable data.

## Usage

``` r
sleep_rem_duration(
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

A data frame with columns for `day` and `SleepREMDuration` (in seconds).

## See also

[`sleep_deep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_deep_duration.md),
[`sleep_duration()`](https://koenniem.github.io/mpathwear/reference/sleep_duration.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)
