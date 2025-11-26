# Summarise Overlapping and Contiguous Time Intervals

Summarise rows in a dataset where the `start` of the next interval is
(nearly) equal to the `end` of the current interval, indicating they are
contiguous. This is useful for simplifying sequences of adjacent time
intervals into broader continuous spans. It also summarises over time
intervals if they overlap.

## Usage

``` r
summarise_overlapping_time(.data, start, end, tolerance = 0)
```

## Arguments

- .data:

  A data frame containing at least the `start` and `end` time columns.

- start:

  The name of the column indicating start times. Defaults to
  `"start_time"`.

- end:

  The name of the column indicating end times. Defaults to `"end_time"`.

- tolerance:

  A numeric value indicating the maximum difference between the `end` of
  one interval and the `start` of the next interval to consider them
  contiguous. Defaults to `0`.

## Value

A data frame with collapsed contiguous time intervals, where each row
represents a continuous span.

## Examples

``` r
df <- data.frame(
  start_time = c(1, 2, 4, 5),
  end_time = c(2, 3, 5, 6)
)
summarise_overlapping_time(
  df,
  start = start_time,
  end = end_time
)
#> # A tibble: 2 × 2
#>   start_time end_time
#>        <dbl>    <dbl>
#> 1          1        3
#> 2          4        6
```
