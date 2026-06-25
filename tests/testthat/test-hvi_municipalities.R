test_that("new_hvi_municipalities requires sf input", {
  expect_error(new_hvi_municipalities(data.frame(a = 1)))
})

test_that("print.hvi_municipalities returns invisibly", {
  muni <- join_population_to_municipalities(
    example_municipalities, example_population
  )
  obj <- new_hvi_municipalities(muni)
  expect_invisible(print(obj))
})