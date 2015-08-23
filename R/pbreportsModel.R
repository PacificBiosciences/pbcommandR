#!/usr/bin/env Rscript

library(methods)
library(jsonlite)

# pbReport Model
setClass("ReportTable", representation(id = "character"))

# In the python code, a table is a relatively small list of values that can be
# displayed in Portal It's primarily used as a summary of computed values In R,
# this should be converted from a dataframe
setClass("ReportTableGroup", representation(id = "character", tables = "list"))

setClass("ReportPlot", representation(id = "character", image = "character"))

setClass("ReportPlotGroup", representation(id = "character", plots = "list"))

setClass("ReportAttribute", representation(value = "numeric", id = "character"))

setClass("ReportAttributeGroup", representation(id = "character", attributes = "list"))

setClass("Report", representation(id = "character", attributeGroups = "list", plotGroups = "list", 
  tableGroups = "list"))

getMockAttributeGroup <- function() {
  # In the python code the ids are automatically turned into absolute ids via the
  # container Not sure this is a great idea
  a1 <- new("ReportAttribute", id = "n50", value = 1234)
  a2 <- new("ReportAttribute", id = "mean_readlength", value = 4567)
  ag <- list(a1, a2)
  attributeGroup <- new("ReportAttributeGroup", id = "pbmilhouse.subread", attributes = ag)
  return(attributeGroup)
}

getMockPlotGroup <- function() {
  plotGroupId <- "pbmilhouse.readlength_plot"
  
  # see the above comment regarding ids
  p1 <- new("ReportPlot", id = "readlength", image = "/path/to/image.png")
  p2 <- new("ReportPlot", id = "accuracy", image = "/path/to/image2.png")
  pg <- new("ReportPlotGroup", id = plotGroupId, plots = list(p1, p2))
  return(pg)
}

getMockTableGroup <- function() {
  # this should just converted from a dataframe
  t <- new("ReportTable", id = "my_table")
  t2 <- new("ReportTable", id = "my_readlength_table")
  tables <- list(t, t2)
  tg <- new("ReportTableGroup", id = "mytable_id", tables = tables)
  return(tg)
}

getMockReport <- function() {
  plotGroup <- getMockPlotGroup()
  attributeGroup <- getMockAttributeGroup()
  tableGroup <- getMockTableGroup()
  report <- new("Report", id = "pbmilhouse_report_example", plotGroups = list(plotGroup), 
    attributeGroups = list(attributeGroup), tableGroups = list(tableGroup))
  
  return(report)
}

testBasicReport <- function() {
  r <- getMockReport()
  
  if (r@id != "pbmilhouse_report_example") {
    stop("Malformed id")
  }
  
  s <- toJSON(r)
  
  cat("Json Report\n")
  cat(s)
} 
