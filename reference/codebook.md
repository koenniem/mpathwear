# Overview of Thryve measurement codes and descriptions

A table containing the connection between the Thryve ID codes for
measurements listed in the `dailyValueType` and `dynamicValueType`
columns of the mpathwear data, along with descriptions, units, and
available data sources.

## Usage

``` r
codebook
```

## Format

### `codebook`

A data frame with 344 rows and 8 columns:

- category:

  The overall category of the measurement.

- subcategory:

  The more specific category of the measurement.

- level:

  The measurement of the variable, i.e. `Daily` or `Intraday`

- variable:

  The variable name of the measurement.

- description:

  The description of the measurement.

- code:

  The Thryve code for the measurement, as used in the
  `dailyDynamicValueType` and `dynamicValueType` columns of the
  mpathwear data.

- unit:

  The unit of the measurement, as used in the `valueType` column of the
  mpathwear data.

- available_sources:

  The available data sources (e.g. Garmin, Fitbit) for this type of
  measurement.

## Source

<https://docs-old.thryve.health/biomarkers.php>

<https://docs-old.thryve.health/analytics.php>
