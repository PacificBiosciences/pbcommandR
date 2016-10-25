library(pbcommandR)
#setwd("/Users/nigel/git/pbcommandR/tests/testthat")

context("Test that sugar layers work.")

test_that("WriteTitle", {
  path <- "reseq-conditions-01.json"
  opath = "test_out.json"
  t = pbreporter(path, opath, "c", "My Report")
  t$write.report()
  d = jsonlite::fromJSON(opath)
  expect_equal(d$title, "My Report")
  file.remove(opath)
})
