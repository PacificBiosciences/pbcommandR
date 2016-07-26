#!/usr/bin/env Rscript

# PacBio Report Data Model Schema
#' @export
PB_REPORT_SCHEMA_VERSION <- "1.0.0"

# pbReport Model
setClass("ReportTable", representation(title = "character",
                                       id = "character",
                                       data = "data.frame"),
         prototype(title = "Data Frame"))


# The image should be relative path to the report.json file
setClass("ReportPlot",
         representation(id = "character", image = "character", title = "character", caption = "character"),
         prototype(title = "R Generated Plot", caption="") )

setClass("ReportPlotGroup",
         representation(id = "character", plots = "list", title = "character"),
         prototype(title = "A Plot"))

# This needs to be updated to support Strings
setClass(
  "ReportAttribute",
  representation(value = "numeric", id = "character", name = "character")
)

# Need to validate "id" format.
setClass(
  "Report",
  representation(
    id = "character",
    version = "character",
    uuid = "character",
    title = "character",
    attributes = "list",
    # Once we can name plot groups I will change the type here
    plotGroups = "list",
    tables = "list"
  ),
  prototype(title = "Report",
            version = PB_REPORT_SCHEMA_VERSION,
            tables = list(),
            plotGroups = list()))





# FIXME. Add loadReportFrom
#' @export
writeReport <- function(r, outputPath) {
  # Temp hack to get this json to look correct
  toI <- function(i) {
    return(paste(r@id, i, sep = "."))
  }

  attributeToD <- function(a) {
    return(list(
      id = toI(a@id),
      value = a@value,
      name = a@name
    ))
  }

  plotToD <- function(p) {
    return(list(
      image = p@image,
      id = toI(p@id),
      title = p@title,
      caption = p@caption
    ))
  }

  plotGroupToD <- function(p) {
    plots <- Map(plotToD, p@plots)
    if (length(p@plots) == 0) {
      thumbnail <- p@plots[[1]]@image
    } else {
      thumbnail <- NA
    }

    return(list(
      id = toI(p@id),
      legend = NA,
      title = p@title,
      thumbnail = thumbnail,
      plots = plots
    ))
  }

  columnsToD <- function(df, namePrefix) {
    nms = colnames(df)
    ids = paste(namePrefix, sub(" ", "", nms), (1:length(nms)), sep = ".")
    columnToD <- function(i) {
      list(header = nms[i],
           id = ids[i],
           values = df[,i])
    }
    cols = lapply(1:ncol(df), columnToD)
    cols
  }

  tableToD <- function(table) {
    list(id = table@id,
         title = table@title,
         columns = columnsToD(table@data, table@id))
  }

  attributes <- Map(attributeToD, r@attributes)
  plotGroups <- Map(plotGroupToD, r@plotGroups)

  tables <- Map(tableToD, r@tables)


  rx <- list(
    id = r@id,
    uuid = r@uuid,
    version = r@version,
    attributes = attributes,
    title = r@title,
    dataset_uuid = list(),
    plotGroups = plotGroups,
    tables = tables
  )

  sx <- jsonlite::toJSON(rx, pretty = TRUE, auto_unbox = TRUE)
  write(sx, file = outputPath)
  return(sx)
}
