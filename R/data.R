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

#' Example dataset of daily measurements
#'
#' A dataset containing example 15 days of daily measurements for a single participant. Exported from
#' m-Path and cleaned using [clean_daily_data()] for demonstration purposes.
#'
#' @format ## `daily_data` A data frame with 387 rows and 18 columns:
#' \describe{
#'   \item{connectionId}{The participant ID in m-Path.}
#'   \item{legacyCode}{The legacy invitation code format. Corresponds directly to `code`.}
#'   \item{code}{The invitation code used in the study, if any.}
#'   \item{alias}{The alias of the participant (can be changed by the participant at any point).}
#'   \item{initials}{The initials of the participant based on the first seen alias.}
#'   \item{accountCode}{The account code of the researcher.}
#'   \item{lastCreatedAtUnix}{The last Unix timestamp at which the wearable data was updated.}
#'   \item{day}{The day of the measurement.}
#'   \item{category}{The overall category of the measurement.}
#'   \item{subcategory}{The more specific category of the measurement.}
#'   \item{variable}{The variable name of the measurement.}
#'   \item{value}{The value of the measurement.}
#'   \item{timezoneOffset}{The timezone offset of the measurement compared to UTC.}
#'   \item{generation}{Whether the measurement was  a calculation, automatic measurement, or manual
#'   input.}
#'   \item{created_at}{The time the measurement was created or updated.}
#'   \item{data_source}{The data source of the measurement. Also see [data_sources].}
#'   \item{description}{The description of the measurement.}
#'   \item{available_sources}{The available data sources (e.g. Garmin, Fitbit) for this type of
#'   measurement.}
#' }
"daily_data"

#' Example dataset of intradaily (i.e. dynamic) measurements
#'
#' A dataset containing example 15 days of intradaily (i.e. dynamic) measurements for a single
#' participant. Exported from m-Path and cleaned using [clean_dynamic_data()] for demonstration
#' purposes.
#'
#' @format ## `dynamic_data` A data frame with 37,332 rows and 19 columns:
#' \describe{
#'   \item{connectionId}{The participant ID in m-Path.}
#'   \item{legacyCode}{The legacy invitation code format. Corresponds directly to `code`.}
#'   \item{code}{The invitation code used in the study, if any.}
#'   \item{alias}{The alias of the participant (can be changed by the participant at any point).}
#'   \item{initials}{The initials of the participant based on the first seen alias.}
#'   \item{accountCode}{The account code of the researcher.}
#'   \item{lastCreatedAtUnix}{The last Unix timestamp at which the wearable data was updated.}
#'   \item{start_time}{The start time of the measurement.}
#'   \item{end_time}{The end time of the measurement.}
#'   \item{category}{The overall category of the measurement.}
#'   \item{subcategory}{The more specific category of the measurement.}
#'   \item{variable}{The variable name of the measurement.}
#'   \item{value}{The value of the measurement.}
#'   \item{tz_offset}{The timezone offset of the measurement compared to UTC.}
#'   \item{generation}{Whether the measurement was  a calculation, automatic measurement, or manual
#'   input.}
#'   \item{created_at}{The time the measurement was created or updated.}
#'   \item{data_source}{The data source of the measurement. Also see [data_sources].}
#'   \item{description}{The description of the measurement.}
#'   \item{available_sources}{The available data sources (e.g. Garmin, Fitbit) for this type of
#'   measurement.}
#' }
"dynamic_data"
