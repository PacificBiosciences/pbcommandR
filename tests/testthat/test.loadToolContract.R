library(pbcommandR)

context("Test for loading a Tool Contract")
path <- "dev_example_dev_txt_app_tool_contract.json"


test_that("Simple example", {
  tc <- loadToolContractFromPath(path)
  print(tc)
  expect_that(10, equals(10))
})

test_that("Convert TC to json", {
  tc <- loadToolContractFromPath(path)
  writeToolContract(tc, "convert-tc.json")
  expect_that(10, equals(10))
})
