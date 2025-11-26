# Clean mpathwear daily data

Clean mpathwear daily data

## Usage

``` r
clean_daily_data(
  data,
  .col = "dailyData",
  connectionId = "connectionId",
  start = "startUTS",
  end = "stopUTS"
)
```

## Arguments

- data:

  A data frame containing the wearable data, as returned by
  [`read_mpathwear()`](https://koenniem.github.io/mpathwear/reference/read_mpathwear.md).

- .col:

  The column containing the data to be unpacked.

- connectionId:

  The column containing the participant ID.

- start:

  The column containing the start time of the data retrieval period.

- end:

  The column containing the end time of the data retrieval period.

## Value

A tibble containing at least the following columns:

|                     |                                                                                                                                                                                |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `connectionId`      | The participant ID in m-Path, as specified by the `connectionId` argument.                                                                                                     |
| `day`               | The day of the measurement as a Date object.                                                                                                                                   |
| `category`          | The overall category of the measurement.                                                                                                                                       |
| `subcategory`       | The more specific category of the measurement.                                                                                                                                 |
| `variable`          | The variable name of the measurement.                                                                                                                                          |
| `value`             | The value of the measurement.                                                                                                                                                  |
| `timezoneOffset`    | The timezone offset of the measurement compared to UTC.                                                                                                                        |
| `generation`        | Whether the measurement was a calculation, automatic measurement, or manual input.                                                                                             |
| `trustworthiness`   | Whether the measurement was trustworthy.                                                                                                                                       |
| `created_at`        | The time the measurement was created or updated.                                                                                                                               |
| `data_source`       | The data source of the measurement. Also see [`data_sources()`](https://koenniem.github.io/mpathwear/reference/data_sources.md).                                               |
| `day_complete`      | A flag that signals whether the day was complete, i.e. a value of 1. A value of 0 indicates that it is uncertain that the day was complete, as there was no data the next day. |
| `description`       | The description of the measurement.                                                                                                                                            |
| `available_sources` | The available data sources (e.g. Garmin, Fitbit) for this type of measurement.                                                                                                 |
