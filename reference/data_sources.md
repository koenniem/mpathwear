# Overview of supported Thryve data sources and data retrieval periods

A table containing the connection between the Thryve ID codes for
activity types listed in the `value` column for variables
ActivityTypeDetail1 and ActivityTypeDetail2.

## Usage

``` r
data_sources
```

## Format

### `data_sources`

A data frame with 38 rows and 5 columns:

- id:

  ID number of the data source in Thryve.

- data_source:

  The name of the data source.

- type_integration:

  How Thryve connects to the data source, e.g. oAuth (via API).

- data_retrieval_frequency:

  How and how often data is pulled from the data source.

- type_data_source:

  The status of integration of the data sources in Thryve. One of
  "active", "experimental", or "thryve".

## Source

<https://docs-old.thryve.health/access.php#data-sources>
