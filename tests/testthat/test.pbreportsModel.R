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
    p1 <- methods::new("ReportPlot", id = "readlength", image = "image-relative-path.png", title = "Read Length", caption = "Read Lenght Caption")
    p2 <- methods::new("ReportPlot", id = "accuracy", image = "image2-relative-path.png", title = "Accuracy", caption = "Read Length Caption")
    pg <- methods::new("ReportPlotGroup", id = plotGroupId, plots = list(p1, p2), title = "My Plots")
    return(pg)
  }

  getMockTables <- function() {
    # this should just converted from a dataframe
    fakeData = data.frame(names = c("Something Good", "Something Bad"), values = 1:2)
    colnames(fakeData) <- c("name spaced", "values")
    t <- methods::new("ReportTable", id = "my_table", data = fakeData)
    t2 <- methods::new("ReportTable", id = "my_readlength_table",
                       title = "Not so great", data = fakeData)
    tables <- list(t, t2)
    return(tables)
  }

  reportOutputPath <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "report.json")
  # reportOutputPath <- "example-report.json"
  logging::loginfo(paste("Report output ", reportOutputPath))

  attributes <- getMockAttributeGroup()
  plotGroups <- list(getMockPlotGroup())
  tables <- getMockTables()

  reportUUID <- uuid::UUIDgenerate()
  version <- "1.0.0"

  report <- methods::new("Report", uuid = reportUUID, version = version,
                         id = "pbcommandr_hello_reseq", plotGroups = plotGroups,
                          attributes = attributes, tables = tables)
  writeReport(report, reportOutputPath)
  cat(paste("Writing report ", reportOutputPath))

  expect_that(10, equals(10))
})
