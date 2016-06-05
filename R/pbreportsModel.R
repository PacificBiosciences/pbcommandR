#!/usr/bin/env Rscript



# pbReport Model
setClass("ReportTable", representation(id = "character"))

# In the python code, a table is a relatively small list of values that can be
# displayed in Portal It's primarily used as a summary of computed values In R,
# this should be converted from a dataframe
setClass("ReportTableGroup", representation(id = "character", tables = "list"))

# The image should be relative path to the report.json file
setClass("ReportPlot", representation(id = "character", image = "character"))

setClass("ReportPlotGroup", representation(id = "character", plots = "list"))

# This needs to be updated to support Strings
setClass("ReportAttribute", representation(value = "numeric", id = "character", name = "character"))

# Need to validate "id" format.
setClass("Report", representation(id = "character", version = "character", uuid = "character", attributes = "list", plotGroups = "list",
  tables = "list"))

# FIXME. Add loadReportFrom
#' @export
writeReport <- function(r, outputPath) {

  # Temp hack to get this json to look correct
  toI <- function(i) {
    return(paste(r@id, i, sep="."))
  }

  attributeToD <- function(a) {
    return(list(id = toI(a@id), value = a@value, name = a@name))
  }

  plotToD <- function(p) {
    return(list(caption = NA, image = p@image, id = toI(p@id)))
  }

  plotGroupToD <- function(p) {
    plots <- Map(plotToD, p@plots)
    if(length(p@plots) == 0) {
      thumbnail <- p@plots[[1]]@image
    } else {
      thumbnail <- NA
    }

    return(list(
      id = toI(p@id),
      legend = NA,
      title = "Title",
      thumbnail = thumbnail,
      plots = plots))
  }

  attributes <- Map(attributeToD, r@attributes)
  plotGroups <- Map(plotGroupToD, r@plotGroups)

  rx <- list(
    id = r@id,
    uuid = r@uuid,
    version = r@version,
    attributes = attributes,
    dataset_uuid = list(),
    plotGroups = plotGroups,
    tables = list())

  sx <- jsonlite::toJSON(rx, pretty = TRUE, auto_unbox = TRUE)
  write(sx, file = outputPath)
  return(sx)
}
