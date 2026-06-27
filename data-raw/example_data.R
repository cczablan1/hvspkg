library(sf)
library(dplyr)
library(readxl)
library(stringr)
library(hvspkg)

# ---- Load real data ----
spain_municip <- sf::st_read("data-raw/spain_municipalities.gpkg", quiet = TRUE)
code_provinces <- readxl::read_xls("data-raw/province_codes.xls", skip = 1)

# ---- Build municipalities ----
example_municipalities <- spain_municip |>
  dplyr::mutate(
    province_code = as.integer(stringr::str_sub(as.character(codine), 1, 2))
  ) |>
  dplyr::left_join(
    code_provinces |> dplyr::mutate(CODIGO = as.integer(CODIGO)),
    by = c("province_code" = "CODIGO")
  ) |>
  dplyr::rename(Province = LITERAL)

# ---- Process population (already has Total_Vulnerable_Population) ----
example_population <- process_population_data("data-raw/spain_population.csv")

# Rename non-ASCII column
example_population <- example_population |>
  dplyr::rename(X100.o.mas = `X100.o.más`)

usethis::use_data(example_municipalities, example_population, overwrite = TRUE)