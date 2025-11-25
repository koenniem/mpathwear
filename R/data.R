#' Codes for Activity Types
#'
#' A table containing the connection between the Thryve ID codes for activity types listed in the
#' `value` column for variables ActivityTypeDetail1 and ActivityTypeDetail2.
#'
#' @format ## `activity_types`
#' A data frame with 125 rows and 2 columns:
#' \describe{
#'   \item{code}{Thryve ID specifying a type of activity for ActivityTypeDetail1 and ActivityTypeDetail2}
#'   \item{activity}{The type of activity, e.g. "Walk", "Run, "Bike", etc.}
#' }
#' @source <https://docs-old.thryve.health/biomarkers.php#activitytypedetail1>
"activity_types"


#' Overview of supported Thryve data sources and data retrieval periods
#'
#' A table containing the connection between the Thryve ID codes for activity types listed in the
#' `value` column for variables ActivityTypeDetail1 and ActivityTypeDetail2.
#'
#' @format ## `data_sources`
#' A data frame with 38 rows and 5 columns:
#' \describe{
#'   \item{id}{ID number of the data source in Thryve.}
#'   \item{data_source}{The name of the data source.}
#'   \item{type_integration}{How Thryve connects to the data source, e.g. oAuth (via API).}
#'   \item{data_retrieval_frequency}{How and how often data is pulled from the data source.}
#'   \item{type_data_source}{The status of integration of the data sources in Thryve. One of
#'   "active", "experimental", or "thryve".}
#' }
#' @source <https://docs-old.thryve.health/access.php#data-sources>
"data_sources"


#' Overview of Thryve measurement codes and descriptions
#'
#' A table containing the connection between the Thryve ID codes for measurements listed in the
#' `dailyValueType` and `dynamicValueType` columns of the mpathwear data, along with descriptions,
#' units, and available data sources.
#'
#' @format ## `codebook`
#' A data frame with 344 rows and 8 columns:
#' \describe{
#'   \item{category}{The overall category of the measurement.}
#'   \item{subcategory}{The more specific category of the measurement.}
#'   \item{level}{The measurement of the variable, i.e. `Daily` or `Intraday`}
#'   \item{variable}{The variable name of the measurement.}
#'   \item{description}{The description of the measurement.}
#'   \item{code}{The Thryve code for the measurement, as used in the `dailyDynamicValueType`
#'   and `dynamicValueType` columns of the mpathwear data.}
#'   \item{unit}{The unit of the measurement, as used in the `valueType` column of the mpathwear
#'   data.}
#'   \item{available_sources}{The available data sources (e.g. Garmin, Fitbit) for this type of
#'   measurement.}
#' }
#' @source <https://docs-old.thryve.health/biomarkers.php>
#' @source <https://docs-old.thryve.health/analytics.php>
"codebook"
