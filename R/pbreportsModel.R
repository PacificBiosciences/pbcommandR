#!/usr/bin/env Rscript



# pbReport Model
setClass("ReportTable", representation(id = "character"))

# In the python code, a table is a relatively small list of values that can be
# displayed in Portal It's primarily used as a summary of computed values In R,
# this should be converted from a dataframe
setClass("ReportTableGroup", representation(id = "character", tables = "list"))

setClass("ReportPlot", representation(id = "character", image = "character"))

setClass("ReportPlotGroup", representation(id = "character", plots = "list"))

# This needs to be updated to support Strings
setClass("ReportAttribute", representation(value = "numeric", id = "character", name = "character"))

# Need to validate "id" format.
setClass("Report", representation(id = "character", attributes = "list", plotGroups = "list",
  tables = "list"))

# FIXME. Add loadReportFrom
#' @export
writeReport <- function(r, outputPath) {
  # Temp hack to get this json to look correct
  attributeToD <- function(a) {
    return(list(id = paste(r@id, a@id, sep="."), value = a@value, name = a@name))
  }

  attributes <- Map(attributeToD, r@attributes)
  rx <- list(id = r@id, attibutes = attributes, dataset_uuid = list(), plotGroups = list(), tables = list())

  sx <- jsonlite::toJSON(rx, pretty = TRUE, auto_unbox = TRUE)
  write(sx, file = outputPath)
  return(sx)
}


getMockAttributeGroup <- function() {
  # In the python code the ids are automatically turned into absolute ids via the
  # container Not sure this is a great idea
  a1 <- methods::new("ReportAttribute", id = "n50", value = 1234, name = "n50")
  a2 <- methods::new("ReportAttribute", id = "mean_readlength", value = 4567, name = "Mean Readlength")
  ag <- list(a1, a2)
  attributeGroup <- methods::new("ReportAttributeGroup", id = "pbmilhouse.subread", attributes = ag)
  return(attributeGroup)
}

getMockPlotGroup <- function() {
  plotGroupId <- "pbmilhouse.readlength_plot"

  # see the above comment regarding ids
  p1 <- methods::new("ReportPlot", id = "readlength", image = "/path/to/image.png")
  p2 <- methods::new("ReportPlot", id = "accuracy", image = "/path/to/image2.png")
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

testBasicReport <- function() {
  r <- getMockReport()

  if (r@id != "pbmilhouse_report_example") {
    stop("Malformed id")
  }

  s <- jsonlite::toJSON(r)

  cat("Json Report\n")
  cat(s)
}
