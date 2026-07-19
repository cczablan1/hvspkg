test_that("compute_hvi_score adds HVI column", {
  pop    <- example_population
  muni   <- join_population_to_municipalities(example_municipalities, pop)
  obj    <- new_hvi_municipalities(muni)

  # Simulate raster columns
  set.seed(42)
  obj$LST_mean  <- runif(nrow(obj), 25, 45)
  obj$NDVI_mean <- runif(nrow(obj), 0.1, 0.6)

  scored <- compute_hvi_score(obj)
  expect_true("HVI" %in% names(scored))
  expect_true(all(scored$HVI >= 0 & scored$HVI <= 1, na.rm = TRUE))
})