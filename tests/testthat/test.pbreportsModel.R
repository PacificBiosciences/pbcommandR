library(pbcommandR)
library(uuid)
library(logging)

context("Test for serializing pbreports Model to JSON")

test_that("Simple Report example", {


  getMockAttributeGroup <- function() {
    # In the python code the ids are automatically turned into absolute ids via the
    # container Not sure this is a great idea
    a1 <- methods::new("ReportAttribute", id = "n50", value = 1234, name = "n50")
    a2 <- methods::new("ReportAttribute", id = "mean_readlength", value = 4567, name = "Mean Readlength")
    ag <- list(a1, a2)
    return(ag)
  }

  getMockPlotGroup <- function() {
    plotGroupId <- "plotgroupa.readlength_plot"

    # see the above comment regarding ids
    p1 <- methods::new("ReportPlot", id = "readlength", image = "image-relative-path.png")
    p2 <- methods::new("ReportPlot", id = "accuracy", image = "image2-relative-path.png")
    pg <- methods::new("ReportPlotGroup", id = plotGroupId, plots = list(p1, p2))
    return(pg)
  }

  getMockTableGroup <- function() {
    # this should just converted from a dataframe
    t <- methods::new("ReportTable", id = "my_table")
    t2 <- methods::new("ReportTable", id = "my_readlength_table")
    tables <- list(t, t2)
    tg <- methods::new("ReportTableGroup", id = "mytable_id", tables = tables)
    return(tg)
  }

  getMockReport <- function() {
    plotGroup <- getMockPlotGroup()
    attributeGroup <- getMockAttributeGroup()
    tableGroup <- getMockTableGroup()
    report <- methods::new("Report", id = "pbmilhouse_report_example", plotGroups = list(plotGroup),
      attributeGroups = list(attributeGroup), tableGroups = list(tableGroup))

    return(report)
  }

  reportOutputPath <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "report.json")
  # reportOutputPath <- "example-report.json"
  logging::loginfo(paste("Report output ", reportOutputPath))

  attributes <- getMockAttributeGroup()
  plotGroups <- list(getMockPlotGroup())
  tables <- list(getMockPlotGroup)

  reportUUID <- uuid::UUIDgenerate()
  version <- "3.1.0"

  report <- methods::new("Report", uuid = reportUUID, version = version, id = "pbcommandr_hello_reseq", plotGroups = plotGroups,
  attributes = attributes, tables = tables)
  writeReport(report, reportOutputPath)
  cat(paste("Writing report ", reportOutputPath))

  expect_that(10, equals(10))
})
