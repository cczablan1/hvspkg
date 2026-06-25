#' Clean INE population data and compute vulnerable population
#'
#' Reads an INE population CSV, removes thousands separators from numeric
#' fields, separates the combined `INE_Code + Municipality` column, and
#' computes the total heat-vulnerable population for children aged
#' 0-5 and adults aged 65+ by default.
#'
#' @param csv_path Character scalar path to the INE population CSV file.
#' @param vulnerable_young Numeric vector of young ages to include in the
#'   vulnerable population total. Defaults to `0:5`.
#' @param vulnerable_old Numeric vector of older ages to include in the
#'   vulnerable population total. Defaults to `65:100`.
#' @return A tibble with the original population columns, newly split
#'   `INE_Code` and `Municipality` columns, and `Total_Vulnerable_Population`.
#' @examples
#' \dontrun{
#' process_population_data(
#'   csv_path = "data/ine_population.csv"
#' )
#' }
#' @export
process_population_data <- function(csv_path,
                                    vulnerable_young = 0:5,
                                    vulnerable_old   = 65:100) {

  # ---- Input validation ----
  if (!is.character(csv_path) || length(csv_path) != 1) {
    stop("`csv_path` must be a single character string.")
  }
  if (!file.exists(csv_path)) {
    stop("Population file not found: ", csv_path)
  }
  if (!is.numeric(vulnerable_young) || !is.numeric(vulnerable_old)) {
    stop("`vulnerable_young` and `vulnerable_old` must be numeric vectors.")
  }

  # ---- Read CSV ----
  population_data <- utils::read.csv(csv_path)

  if (ncol(population_data) < 3) {
    stop("Population data must have at least 3 columns (code+name, total, ages).")
  }

  # ---- Convert numeric-like character columns ----
  # INE exports use commas as thousands separators -> strip then coerce
  population_data <- population_data |>
    dplyr::mutate(
      dplyr::across(2:dplyr::last_col(),
                    ~ as.numeric(gsub(",", "", .)))
    )

  # ---- Split first column into INE_Code + Municipality ----
  # Format is e.g. "01001 Alegria-Dulantzi" -> separate on first space
  population_data <- population_data |>
    tidyr::separate(col = 1,
                    into = c("INE_Code", "Municipality"),
                    sep = " ", extra = "merge")

  # ---- Compute vulnerable population ----
  # Match column names against the requested age ranges

  # drop INE_Code + Municipality
  age_cols <- names(population_data)[-c(1, 2)]  

  # Build the expected R-style column names from the numeric age vectors
  vulnerable_ages <- paste0("X", c(vulnerable_young, vulnerable_old))

  # Special case: the open-ended top age bin "100 o mas" -> "X100.o.mas"
  # If the user asked for age 100, also include that column.
  if (100 %in% c(vulnerable_young, vulnerable_old)) {
    vulnerable_ages <- c(vulnerable_ages, "X100.o.m\u00e1s")
  }

  # Keep only the columns that actually exist in the data
  matched_cols <- intersect(age_cols, vulnerable_ages)

  if (length(matched_cols) == 0) {
    warning("No age columns matched the vulnerable age ranges; ",
            "returning 0 for Total_Vulnerable_Population.")
    population_data$Total_Vulnerable_Population <- 0
  } else {
    # Row-wise sum across the vulnerable age columns only
    population_data$Total_Vulnerable_Population <-
      rowSums(population_data[, matched_cols, drop = FALSE], na.rm = TRUE)
  }

  return(population_data)
}