# Calculate sleep regularity index

Calculates the Sleep Regularity Index (SRI), which describes the
likelihood that any two time-points 24 hours apart were in the same
sleep/wake state across all days. This is a well-established indicator
of sleep consistency.

## Usage

``` r
sleep_regularity(
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

A data frame with the `sleep_regularity` score (ranging from -100 to
100, where 100 indicates perfect regularity).

## Details

Values below 60% are associated with a significantly higher likelihood
for Alzheimer's disease, depression, and cardiovascular diseases.

## Note

This function requires the `mpathsenser` package to be installed.

## See also

[`sleep_score()`](https://koenniem.github.io/mpathwear/reference/sleep_score.md),
[`sleep_chart()`](https://koenniem.github.io/mpathwear/reference/sleep_chart.md)

## Examples

``` r
sleep_regularity(dynamic_data)
#> # A tibble: 1 × 1
#>   sleep_regularity
#>              <dbl>
#> 1             67.4
```
