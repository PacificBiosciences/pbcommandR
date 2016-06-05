library(testthat)
library(pbcommandR)
test_check("pbcommandR")

# MK. Note where this is pulled to run the linter when the tests run
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {
    lintr::expect_lint_free()
  })
}
