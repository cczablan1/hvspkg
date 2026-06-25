test_that("compute_hvi_score adds hvi_score column", {
  muni <- new_hvi_municipalities(
    join_population_to_municipalities(example_municipalities, example_population)
  )
  scored <- compute_hvi_score(muni)
  expect_true("hvi_score" %in% names(scored))
  expect_true(all(scored$hvi_score >= 0 & scored$hvi_score <= 1, na.rm = TRUE))
})