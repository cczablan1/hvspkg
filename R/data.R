#' Example Spanish municipalities
#'
#' A small synthetic sf object with 10 municipalities for illustration.
#'
#' @format An sf object with 10 rows and 5 columns:
#' \describe{
#'   \item{codine}{INE municipality code}
#'   \item{NAMEUNIT}{Municipality name}
#'   \item{province_code}{Numeric province code}
#'   \item{Province}{Province name}
#'   \item{geometry}{Municipality polygon geometry}
#' }
"example_municipalities"

#' Example population data
#'
#' A small synthetic population table matching `example_municipalities`.
#'
#' @format A data frame with 10 rows and 4 columns:
#' \describe{
#'   \item{INE_Code}{INE municipality code}
#'   \item{Municipality}{Municipality name}
#'   \item{Total}{Total population}
#'   \item{Total_Vulnerable_Population}{Heat-vulnerable population count}
#' }
"example_population"