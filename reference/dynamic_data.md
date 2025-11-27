# Example dataset of intradaily (i.e. dynamic) measurements

A dataset containing example 7 days of intradaily (i.e. dynamic)
measurements for a single participant. Exported from m-Path and cleaned
using
[`clean_dynamic_data()`](https://koenniem.github.io/mpathwear/reference/clean_dynamic_data.md)
for demonstration purposes.

## Usage

``` r
dynamic_data
```

## Format

### `dynamic_data` A data frame with 37,332 rows and 19 columns:

- connectionId:

  The participant ID in m-Path.

- legacyCode:

  The legacy invitation code format. Corresponds directly to `code`.

- code:

  The invitation code used in the study, if any.

- alias:

  The alias of the participant (can be changed by the participant at any
  point).

- initials:

  The initials of the participant based on the first seen alias.

- accountCode:

  The account code of the researcher.

- lastCreatedAtUnix:

  The last Unix timestamp at which the wearable data was updated.

- start_time:

  The start time of the measurement.

- end_time:

  The end time of the measurement.

- category:

  The overall category of the measurement.

- subcategory:

  The more specific category of the measurement.

- variable:

  The variable name of the measurement.

- value:

  The value of the measurement.

- tz_offset:

  The timezone offset of the measurement compared to UTC.

- generation:

  Whether the measurement was a calculation, automatic measurement, or
  manual input.

- created_at:

  The time the measurement was created or updated.

- data_source:

  The data source of the measurement. Also see
  [data_sources](https://koenniem.github.io/mpathwear/reference/data_sources.md).

- description:

  The description of the measurement.

- available_sources:

  The available data sources (e.g. Garmin, Fitbit) for this type of
  measurement.
