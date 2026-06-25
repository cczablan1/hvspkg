#' Compute a heat vulnerability index
#'
#' Adds a normalised heat vulnerability score (0–1) based on the proportion
#' of vulnerable population.
#'
#' @param x An `hvi_municipalities` object.
#' @return An object of class `hvi_score`.
#' @export
compute_hvi_score <- function(x) {
  stopifnot(inherits(x, "hvi_municipalities"))
  vp    <- x$Total_Vulnerable_Population
  total <- x$Total
  score <- ifelse(total > 0, vp / total, 0)
  # Normalise 0-1
  rng   <- range(score, na.rm = TRUE)
  if (diff(rng) > 0) {
    score <- (score - rng[1]) / diff(rng)
  }
  x$hvi_score <- score
  structure(x, class = c("hvi_score", class(x)))
}

#' @export
print.hvi_score <- function(x, ...) {
  cat("Heat Vulnerability Index\n")
  cat("Municipalities:", nrow(x), "\n")
  cat("Score range   : [",
      round(min(x$hvi_score, na.rm = TRUE), 3), ",",
      round(max(x$hvi_score, na.rm = TRUE), 3), "]\n")
  cat("Mean score    :", round(mean(x$hvi_score, na.rm = TRUE), 3), "\n")
  invisible(x)
}

#' @export
plot.hvi_score <- function(x, ...) {
  plot(x["hvi_score"],
       main   = "Heat Vulnerability Index",
       breaks = "quantile",
       nbreaks = 5,
       pal = function(n) grDevices::hcl.colors(n, "YlOrRd"),
       ...)
  invisible(x)
}