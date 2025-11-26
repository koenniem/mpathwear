# Clean mpathwear intraday (i.e. dynamic) data

Clean mpathwear intraday (i.e. dynamic) data

## Usage

``` r
clean_dynamic_data(data, .col = "dynamicData", connectionId = "connectionId")
```

## Arguments

- data:

  A data frame containing the wearable data, as returned by
  [`read_mpathwear()`](https://koenniem.github.io/mpathwear/reference/read_mpathwear.md).

- .col:

  The column containing the data to be unpacked.

- connectionId:

  The column containing the participant ID.

## Value

A tibble containing at least the following columns:

|                          |                                                                                                                                                                                                |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `connectionId`           | The participant ID in m-Path, as specified by the `connectionId` argument.                                                                                                                     |
| `start_time`             | The start time of the measurement.                                                                                                                                                             |
| `end_time`               | The end time of the measurement.                                                                                                                                                               |
| `category`               | The overall category of the measurement.                                                                                                                                                       |
| `subcategory`            | The more specific category of the measurement.                                                                                                                                                 |
| `variable`               | The variable name of the measurement.                                                                                                                                                          |
| `value`                  | The value of the measurement.                                                                                                                                                                  |
| `timezoneOffset`         | The timezone offset of the measurement compared to UTC.                                                                                                                                        |
| `generation`             | Whether the measurement was a calculation, automatic measurement, or manual input.                                                                                                             |
| `chronologicalExactness` | The imprecision of the timestamp in minutes. This imprecision occurs when some specific sources give the summary of activity without precise information about timestamp of specific activity. |
| `created_at`             | The time the measurement was created or updated.                                                                                                                                               |
| `data_source`            | The data source of the measurement. Also see [data_sources](https://koenniem.github.io/mpathwear/reference/data_sources.md).                                                                   |
| `description`            | The description of the measurement.                                                                                                                                                            |
| `available_sources`      | The available data sources (e.g. Garmin, Fitbit) for this type of measurement.                                                                                                                 |
