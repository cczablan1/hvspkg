utils::globalVariables(c("LST_mean", "NDVI_mean", "Total",
                          "Total_Vulnerable_Population"))

#' Extract raster statistics to municipalities
#'
#' Computes zonal mean statistics for LST and NDVI rasters over Spanish
#' municipal boundaries and joins the results to the sf object.
#'
#' @param municipalities An `hvi_municipalities` object.
#' @param lst_path Path to the LST GeoTIFF file (values in Kelvin).
#' @param ndvi_path Path to the NDVI GeoTIFF file.
#'
#' @return The input sf object with added columns `LST_mean` (Celsius)
#'   and `NDVI_mean`.
#' @export
extract_raster_to_municipalities <- function(municipalities, lst_path, ndvi_path) {
  stopifnot(inherits(municipalities, "hvi_municipalities"))
  if (!file.exists(lst_path))  stop("LST file not found: ",  lst_path)
  if (!file.exists(ndvi_path)) stop("NDVI file not found: ", ndvi_path)

  lst_rast  <- terra::rast(lst_path)
  ndvi_rast <- terra::rast(ndvi_path)

  muni_lst  <- sf::st_transform(municipalities, terra::crs(lst_rast))
  muni_ndvi <- sf::st_transform(municipalities, terra::crs(ndvi_rast))

  lst_vals  <- terra::extract(lst_rast,  terra::vect(muni_lst),
                               fun = mean, na.rm = TRUE)
  ndvi_vals <- terra::extract(ndvi_rast, terra::vect(muni_ndvi),
                               fun = mean, na.rm = TRUE)

  municipalities$LST_mean  <- lst_vals[[2]] - 273.15
  municipalities$NDVI_mean <- ndvi_vals[[2]]

  municipalities
}