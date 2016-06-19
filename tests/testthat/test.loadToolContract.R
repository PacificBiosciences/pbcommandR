library(pbcommandR)

context("Test for loading a Tool Contract")
path <- "dev_example_dev_txt_app_tool_contract.json"


test_that("Sanity Example to load TC from file", {
  tc <- loadToolContractFromPath(path)
  #print(tc)
  expect_that(10, equals(10))
})

test_that("Convert TC to JSON, then load TC from JSON", {
  tc <- loadToolContractFromPath(path)
  #cat(paste("successfully loaded TC", tc@task@isDistributed, sep = " "))
  outputTc <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "tool_contract.json")
  writeToolContract(tc, outputTc)
  logging::loginfo("completed writing tool contract")
  expect_true(is.logical(tc@task@isDistributed))
  expect_true(tc@task@isDistributed)
  expect_that(10, equals(10))
})
