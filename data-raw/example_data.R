## code to prepare `example_data` dataset goes here
library(sf)
library(dplyr)

# 10 fake municipalities, realistic column names
set.seed(42)
n <- 10

example_municipalities <- sf::st_sf(
  codine    = c("28001","28002","28003","08001","08002",
                "41001","41002","17001","17002","17003"),
  NAMEUNIT  = paste("Municipality", 1:n),
  province_code = c(28,28,28,8,8,41,41,17,17,17),
  Province  = c(rep("Madrid",3), rep("Barcelona",2),
                rep("Sevilla",2), rep("Girona",3)),
  geometry  = sf::st_sfc(
    lapply(1:n, function(i)
      sf::st_polygon(list(matrix(
        c(i, i, i+0.1, i, i+0.1, i+0.1, i, i+0.1, i, i),
        ncol=2, byrow=TRUE
      )))
    ),
    crs = 4326
  )
)

# Matching population data
example_population <- data.frame(
  INE_Code  = c("28001","28002","28003","08001","08002",
                "41001","41002","17001","17002","17003"),
  Municipality = paste("Municipality", 1:n),
  Total        = c(5000,12000,800,45000,3200,9100,670,2300,8800,1500),
  Total_Vulnerable_Population = c(800,2100,120,7200,500,1400,90,310,1300,200),
  stringsAsFactors = FALSE
)

usethis::use_data(example_municipalities, example_population, overwrite = TRUE)