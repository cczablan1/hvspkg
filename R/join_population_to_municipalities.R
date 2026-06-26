#' Join population data to municipal boundaries
#'
#' Joins a cleaned INE population table to an enriched municipal `sf` object
#' using the INE municipality code, producing a spatial dataset ready for
#' analysis.
#'
#' @param municipalities An `sf` object returned by
#'   `load_municipalities_with_provinces()` containing municipal boundaries and
#'   a `codine` column.
#' @param population A data frame returned by `process_population_data()` with a
#'   split `INE_Code` column and vulnerable population totals.
#' @return An `sf` object containing the joined municipal boundaries and
#'   population data.
#' @examples
#' \dontrun{
#' municipalities <- load_municipalities_with_provinces(
#'   municip_path = "data/spain_municipalities.gpkg",
#'   province_path = "data/ine_provinces.xls"
#' )
#'
#' population <- process_population_data(
#'   csv_path = "data/ine_population.csv"
#' )
#'
#' joined <- join_population_to_municipalities(municipalities, population)
#' }
#' @export
join_population_to_municipalities <- function(municipalities, population) {

  # ---- Input validation ----
  if (!inherits(municipalities, "sf")) {
    stop("`municipalities` must be an sf object (use load_municipalities_with_provinces()).")
  }
  if (!is.data.frame(population)) {
    stop("`population` must be a data.frame (use process_population_data()).")
  }
  if (!"codine" %in% names(municipalities)) {
    stop("`municipalities` must contain a `codine` column.")
  }
  if (!"INE_Code" %in% names(population)) {
    stop("`population` must contain an `INE_Code` column.")
  }

  # ---- Perform the join ----
  joined <- merge(municipalities, population,
                by.x = "codine", by.y = "INE_Code",
                all.x = TRUE)
  joined <- sf::st_as_sf(joined)

  # ---- Report join quality ----
  # Useful diagnostic for the user; missing matches commonly stem from
  # leading zeros being stripped in CSV imports
  n_missing <- sum(is.na(joined$Total_Vulnerable_Population))
  message("Joined ", nrow(joined), " municipalities; ",
          n_missing, " have no matching population record.")

  return(joined)
}