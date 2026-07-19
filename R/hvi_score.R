#' Compute a heat vulnerability index
#'
#' Combines normalised LST, NDVI (inverted), and demographic vulnerability
#' into a weighted heat vulnerability index (HVI) per municipality.
#' Weights: LST 50%, demographic vulnerability 30%, NDVI 20%.
#'
#' @param x An `hvi_municipalities` object with `LST_mean` and `NDVI_mean`
#'   columns added by `extract_raster_to_municipalities()`.
#' @param w_lst Numeric. Weight for LST (default 0.5).
#' @param w_vuln Numeric. Weight for demographic vulnerability (default 0.3).
#' @param w_ndvi Numeric. Weight for NDVI (default 0.2).
#'
#' @return An object of class `hvi_score` with an added `HVI` column.
#' @export
compute_hvi_score <- function(x, w_lst = 0.5, w_vuln = 0.3, w_ndvi = 0.2) {
  stopifnot(inherits(x, "hvi_municipalities"))

  required <- c("LST_mean", "NDVI_mean", "Total", "Total_Vulnerable_Population")
  missing  <- setdiff(required, names(x))
  if (length(missing) > 0) {
    stop("Missing columns: ", paste(missing, collapse = ", "),
         "\nRun extract_raster_to_municipalities() first.")
  }

  normalize <- function(v) {
    rng <- range(v, na.rm = TRUE)
    if (diff(rng) == 0) return(rep(0, length(v)))
    (v - rng[1]) / diff(rng)
  }

  vuln_ratio <- ifelse(x$Total > 0,
                       x$Total_Vulnerable_Population / x$Total, 0)
  vuln_norm  <- normalize(vuln_ratio)
  lst_norm   <- normalize(x$LST_mean)
  ndvi_norm  <- normalize(x$NDVI_mean)

  x$HVI <- w_lst * lst_norm + w_vuln * vuln_norm + w_ndvi * (1 - ndvi_norm)

  structure(x, class = c("hvi_score", class(x)))
}

#' @export
print.hvi_score <- function(x, ...) {
  cat("Heat Vulnerability Index\n")
  cat("Municipalities:", nrow(x), "\n")
  cat("HVI range     : [",
      round(min(x$HVI, na.rm = TRUE), 3), ",",
      round(max(x$HVI, na.rm = TRUE), 3), "]\n")
  cat("Mean HVI      :", round(mean(x$HVI, na.rm = TRUE), 3), "\n")
  invisible(x)
}

#' @export
#' @export
plot.hvi_score <- function(x, ...) {
  # Remove Canary Islands (Las Palmas and Santa Cruz de Tenerife)
  mainland <- x[!x$Province %in% c("Palmas, Las", "Santa Cruz de Tenerife"), ]

  plot(mainland["HVI"],
       main    = "Heat Vulnerability Index",
       breaks  = "quantile",
       nbreaks = 5,
       pal     = function(n) rev(grDevices::hcl.colors(n, "YlOrRd")),
       lwd     = 0.1,
       border  = NA,
       ...)
  invisible(x)
}