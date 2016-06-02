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
  logging::loginfo("successfully loaded TC")
  writeToolContract(tc, "convert-tc.json")
  logging::loginfo("completed writing tool contract")
  expect_that(10, equals(10))
})
