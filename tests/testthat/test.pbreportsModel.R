library(pbcommandR)
library(logging)

context("Test for serializing pbreports Model to JSON")

test_that("Simple Report example", {

  reportOutputPath <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "report.json")
  logging::loginfo(paste("Report output ", reportOutputPath))
  a1 <- methods::new("ReportAttribute", id = "a1", value = 1234, name = "Metric 1")
  a2 <- methods::new("ReportAttribute", id = "a2", value = 45.67, name = "Metric 2")


  report <- methods::new("Report", id = "pbcommandR_hello_reseq", plotGroups = list(),
  attributes = c(a1, a2), tables = list())
  writeReport(report, reportOutputPath)

  expect_that(10, equals(10))
})
