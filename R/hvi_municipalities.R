#' Create an hvi_municipalities object
#'
#' Wraps a joined municipalities + population sf object with class metadata.
#'
#' @param x An `sf` object produced by `join_population_to_municipalities()`.
#' @return An object of class `hvi_municipalities`.
#' @export
new_hvi_municipalities <- function(x) {
  stopifnot(inherits(x, "sf"))
  required <- c("codine", "Province", "Total_Vulnerable_Population")
  missing  <- setdiff(required, names(x))
  if (length(missing) > 0) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }
  structure(x, class = c("hvi_municipalities", class(x)))
}

#' @export
print.hvi_municipalities <- function(x, ...) {
  cat("Heat Vulnerability Municipalities\n")
  cat("Municipalities :", nrow(x), "\n")
  cat("Provinces      :", length(unique(x$Province)), "\n")
  cat("CRS            :", sf::st_crs(x)$input, "\n")
  cat("Vulnerable pop :", sum(x$Total_Vulnerable_Population, na.rm = TRUE), "\n")
  invisible(x)
}

#' @export
summary.hvi_municipalities <- function(object, ...) {
  cat("Heat Vulnerability Municipalities - Summary\n")
  cat("-------------------------------------------\n")
  cat("Total municipalities     :", nrow(object), "\n")
  cat("Provinces covered        :", length(unique(object$Province)), "\n")
  cat("Total population         :", sum(object$Total, na.rm = TRUE), "\n")
  cat("Total vulnerable pop     :", 
      sum(object$Total_Vulnerable_Population, na.rm = TRUE), "\n")
  cat("Mean vulnerable pop      :", 
      round(mean(object$Total_Vulnerable_Population, na.rm = TRUE), 1), "\n")
  invisible(object)
}