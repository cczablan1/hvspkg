utils::globalVariables(c("CODIGO", "LITERAL", "codine"))

#' Load Spanish municipal boundaries and join provinces
#'
#' Reads a municipal boundary GeoPackage and enriches it with province names
#' from an INE province lookup file using the first two digits of the municipality
#' code (`codine`).
#'
#' @param municip_path Character scalar path to the municipal boundary GeoPackage.
#' @param province_path Character scalar path to the INE province lookup XLS file.
#' @return An `sf` object containing the municipal boundaries with an added
#'   `province_code` column and a renamed `Province` column.
#' @examples
#' \dontrun{
#' load_municipalities_with_provinces(
#'   municip_path = "data/spain_municipalities.gpkg",
#'   province_path = "data/ine_provinces.xls"
#' )
#' }
#' @export
load_municipalities_with_provinces <- function(municip_path, province_path) {

  # ---- Input validation ----
  if (!is.character(municip_path) || length(municip_path) != 1) {
    stop("`municip_path` must be a single character string.")
  }
  if (!is.character(province_path) || length(province_path) != 1) {
    stop("`province_path` must be a single character string.")
  }
  if (!file.exists(municip_path)) {
    stop("Municipality file not found: ", municip_path)
  }
  if (!file.exists(province_path)) {
    stop("Province file not found: ", province_path)
  }

  # ---- Read inputs ----
  # Read the municipal boundaries as an sf object
  spain_municip <- sf::st_read(municip_path, quiet = TRUE)

  # Province lookup is published by INE with one header row to skip
  code_provinces <- readxl::read_xls(province_path, skip = 1)

  # Required columns must be present before we attempt the join
  if (!"codine" %in% names(spain_municip)) {
    stop("Municipality data must contain a `codine` column.")
  }
  if (!all(c("CODIGO", "LITERAL") %in% names(code_provinces))) {
    stop("Province file must contain `CODIGO` and `LITERAL` columns.")
  }

  # Ensure CODIGO is integer for a clean join
  code_provinces <- code_provinces |>
    dplyr::mutate(CODIGO = as.integer(CODIGO))

  # ---- Extract province code and join ----
  # The first two digits of `codine` correspond to the province code
  spain_municip <- spain_municip |>
    dplyr::mutate(
      province_code = as.integer(stringr::str_sub(as.character(codine), 1, 2))
    ) |>
    dplyr::left_join(code_provinces, by = c("province_code" = "CODIGO")) |>
    dplyr::rename(Province = LITERAL)

  # Return enriched sf object
  return(spain_municip)
}