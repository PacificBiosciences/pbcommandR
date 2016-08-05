#' Helper function for verifying arguments
#' @export
chkClass <- function(var, classname, msg) {
  if (!(classname %in% class(var))) {
    stop(msg)
  }
}

#' Check the file ends as a png
chkPng <- function(fname) {
  substr(fname, nchar(fname) - 3, nchar(fname)) == '.png'
}


#' Sugar object to make it easier to generate reports.
#'
#' When writing a report, there is a lot of "state" to account for.  Plots and
#' tables must be written to the same output directory, and whenever a file is
#' output, we have to update the pbreport to ensure it shows up in the GUI.
#'
#' Passing all this information around gets annoying fast. R is a functional
#' language and does not like keeping track of state very much. To work around
#' this, we are going to use the closure approach outlined in Section 5.4 of
#' "Software for Data Analysis" by John Chambers.  The basic idea is that we'll
#' define functions for saving plots/data in a closure that contains an
#' environment with the objects we want to update.
#'
#' This could also be accomplished using the newer reference classes introduced
#' in R version 2.12.  However I haven't seen those used at PacBio yet and it's
#' less elegant, so will avoid introducing new syntax.
#' @param reSeqConditions The file with the resequencing conditions.
#' @param reportOutputPath The path of the report JSON file to write.
#' @param reportid A lowercase/no-special character ID.
#' @param version The version number (1.0.0)
#' @export
pbreporter <- function(conditionFile, outputFile, reportid, version = "0.0.1") {

  conditionFile = conditionFile
  reportOutputPath <- dirname(outputFile)
  reportOutputFile = outputFile
  reportUUID <- uuid::UUIDgenerate()
  reportId <- reportid
  version <- version
  attributes <- list()
  plotsToOutput <- list()
  tablesToOutput <- list()

  decoded <- loadReseqConditionsFromPath(conditionFile)
  conds = decoded@conditions
  tmp = lapply(conds, function(z) data.frame(condition = z@condId,
                                               subreadset = z@subreadset,
                                               alignmentset = z@alignmentset,
                                               referenceset = z@referenceset))
  cond_table = do.call(rbind, tmp)

  # Save a ggplot in the report.
  ggsave <- function(img_file_name, plot, id = "plot_name", title="Default Title",
                     caption="No caption specified", ...)
  {
    chkClass(plot, "ggplot", "You can only save ggplots in reports.")
    if (!chkPng(img_file_name)) {
     img_file_name = paste(img_file_name, ".png", sep = "")
    }
    img_path = file.path(reportOutputPath, img_file_name)
    ggplot2::ggsave(img_path, plot = plot, ...)
    logging::loginfo(paste("Wrote img to: ", img_path))
    p <- methods::new("ReportPlot",
                       id = id,
                       image = img_file_name,
                       title = title,
                       caption = caption)
    plotsToOutput <<- c(list(p), plotsToOutput)
  }

  # Add a table to the report.
  write.table <- function(tbl, id = "table_name", title = "Default Title") {
    table = list(methods::new("ReportTable", title = title, id = id, data = tbl))
    tablesToOutput <<- c(list(table), tablesToOutput)
  }

  # Output the report file as json.
  write.report <- function() {
    pg <- methods::new("ReportPlotGroup",
                       id = "plotgroup_a",
                       plots = plotsToOutput)

    report <- methods::new("Report",
                           uuid = reportUUID,
                           version = version,
                           id = reportId,
                           plotGroups = list(pg),
                           attributes = attributes,
                           tables = tablesToOutput)

    writeReport(report, reportOutputFile)
    logging::loginfo(paste("Wrote report to ", reportOutputFile))
  }

  # Return a list with functions that capture this functions environment
  # and so have a "global state" we can share and mutate.
  list(condition.table = cond_table,
       ggsave = ggsave,
       write.table = write.table,
       write.report = write.report)
}

#' Create a resequencing job tool wrapper using a function that takes an object
#' returned by pbreporter() as input.
#'
#' @param scriptFileName The name of the R file. (e.g. myTool.R, should be the name of the file that calls this)
#' @param toolName What is the name of the tool, should be all lowercase, no special characters.
#' @param reportid Name of the report id.
#' @param version Default = 0.0.1
#' @param nproc How many processors does the tool need?
#' @param distributed Should this run on the server or the cluster?
#' @export
pbReseqJob <- function(scriptFileName, toolName, func, reportid,
                       version = "0.0.1", nproc = 1,
                       distributed = TRUE) {

  chkClass(func, "function", "Argument func was not a function.")
  wrappedFunc <- function(rtc) {
    conditionFile = rtc@task@inputFiles[1]
    reportFile = rtc@task@outputFiles[1]
    rpt = pbreporter(conditionFile, reportFile, reportid = reportid, version = version)
    func(rpt)
  }

  registerMyTool <- function() {
    r <- registryBuilder(PB_TOOL_NAMESPACE, paste(scriptFileName, "run-rtc "))
    registerTool(r,
                 toolName,
                 version,
                 c(FileTypes$RESEQ_COND), c(FileTypes$REPORT), nproc, distributed, wrappedFunc)
    return(r)
  }

  runTask <- function() {
    mainRegisteryMainArgs(registerMyTool())
  }
  return(runTask)
}
