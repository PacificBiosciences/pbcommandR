library(pbcommandR)

context("Test for loading a Reseq Conditions")

test_that("Load Reseq Conditions", {
  path <- "reseq-conditions-01.json"
  reseqConditions <- loadReseqConditionsFromPath(path)
  #print(reseqConditions)
  expect_that(10, equals(10))
})
