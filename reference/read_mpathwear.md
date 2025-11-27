# Read wearable data from m-Path

This function reads one more multiple CSV files containing wearable data
exported from m-Path.

## Usage

``` r
read_mpathwear(path, recursive = FALSE)
```

## Arguments

- path:

  A character string to the directory containing the data files or a
  single file path.

- recursive:

  A logical value indicating whether data files should be searched in
  subdirectories.

## Value

A tibble containing the following columns:

|                   |                                                                                |
|-------------------|--------------------------------------------------------------------------------|
| **Variable**      | **Explanation**                                                                |
| connectionId      | The participant ID in m-Path.                                                  |
| legacyCode        | The legacy invitation code format. Corresponds directly to `code`.             |
| code              | The invitation code used in the study, if any.                                 |
| alias             | The alias of the participant (can be changed by the participant at any point). |
| initials          | The initials of the participant based on the first seen alias.                 |
| accountCode       | The account code of the researcher.                                            |
| startUTS          | The start of the requested data period in Unix timestamp format.               |
| stopUTS           | The end of the requested data period in Unix timestamp format.                 |
| lastCreatedAtUnix | The last Unix timestamp at which the wearable data was updated.                |
| dynamicData       | The intraday (i.e. momentary) wearable data.                                   |
| dailyData         | The interday (i.e. daily) wearable data.                                       |

See [the m-Path manual page on data
exporting](https://m-path.io/manual/knowledge-base/export-data/) for
more information on the columns `connectionId` through `accountCode`, as
these are part of the default m-Path data output.

## See also

[`clean_dynamic_data()`](https://koenniem.github.io/mpathwear/reference/clean_dynamic_data.md)
and
[`clean_daily_data()`](https://koenniem.github.io/mpathwear/reference/clean_daily_data.md)
for unpacking the dynamic and daily data.

## Examples

``` r
# Your path to the data, or in this case the package example data.
# Note that this can also be a folder containing several files.
path <- system.file("extdata", "example.csv", package = "mpathwear")

read_mpathwear(path)
#> # A tibble: 3 × 9
#>   connectionId legacyCode  code     alias initials accountCode lastCreatedAtUnix
#>   <chr>        <chr>       <chr>    <chr> <chr>    <chr>                   <dbl>
#> 1 123456       !1234@abc12 !abcd e… exam… exa      abc12           1764164955448
#> 2 123456       !1234@abc12 !abcd e… exam… exa      abc12           1764165350362
#> 3 123456       !1234@abc12 !abcd e… exam… exa      abc12           1764166043493
#> # ℹ 2 more variables: dynamicData <list>, dailyData <list>
```
