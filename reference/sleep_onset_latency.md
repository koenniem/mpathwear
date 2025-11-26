# Calculate sleep onset latency

Calculates the time between getting into bed and falling asleep for each
night. This is the duration from the first `SleepInBedBinary` to the
first `SleepStateBinary`.

## Usage

``` r
sleep_onset_latency(
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

A data frame with columns for `day` and `SleepOnSetLatency` (in
seconds).

## See also

[`sleep_efficiency()`](https://koenniem.github.io/mpathwear/reference/sleep_efficiency.md),
[`sleep_score()`](https://koenniem.github.io/mpathwear/reference/sleep_score.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)
