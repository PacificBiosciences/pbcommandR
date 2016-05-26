library(pbcommandR)

context("Test for loading a ResolvedTool Contract")

test_that("Simple example", {
  path <- "dev_example_resolved_tool_contract.json"
  rtc <- loadResolvedToolContractFromPath(path)
  expect_that(10, equals(10))
})
