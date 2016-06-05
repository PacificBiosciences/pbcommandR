# Example Task for Development

#' Example Task for testing
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Fasta]
#' @export
examplefilterFastaTask <- function(pathToFasta, filteredFasta, minSequenceLength) {
  logging::loginfo(paste("Writing filtered fasta to ", filteredFasta))
  write(">r1\nACGT\n>r2\nACCCGGTTT\n", filteredFasta)
  return(0)
}

getPlotGroup <- function(outputPath) {
  plotGroupId <- "plotgroup_a"

  # Demo function
  fun.1 <- function(x) { return(x^2 + x) }

  p <- ggplot2::ggplot(data = data.frame(x = 0), mapping = ggplot2::aes(x = x))
  p + ggplot2::stat_function(fun = fun.1) + ggplot2::xlim(-5,5)

  ggplot2::ggsave(outputPath, plot = ggplot2::last_plot())

  basePlotFileName <- basename(outputPath)
  # see the above comment regarding ids. The Plots must always be provided
  # as relative path to the output dir
  p1 <- methods::new("ReportPlot", id = "parabola_dev_example", image = basePlotFileName)
  pg <- methods::new("ReportPlotGroup", id = plotGroupId, plots = list(p1))
  return(pg)
}

#' Example Task for Testing with emitting a report
#'
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Report]
#' @export
examplefastaReport <- function(pathToFasta, reportPath) {
  logging::loginfo(paste("loading fasta file ", pathToFasta))
  logging::loginfo(paste("will be writing report to ", reportPath))

  imageName <- "report_plot.png"

  reportDir <- dirname(reportPath)
  imagePath <- file.path(reportDir, imageName)

  reportUUID <- uuid::UUIDgenerate()
  reportId <- "pbcommandr_dev_fasta"
  version <- "3.1.0"
  tables <- list()
  attributes <- list()
  plotGroups <- list(getPlotGroup(imagePath))


  report <- methods::new("Report",
  uuid = reportUUID,
  version = version,
  id = reportId,
  plotGroups = plotGroups,
  attributes = attributes,
  tables = tables)

  writeReport(report, reportPath)
  logging::loginfo(paste("Wrote report to ", reportPath))
  return(0)
}

# This can be done here or in a separate file There can be a single registry for
# all tasks, or subparser-eseque model to group tasks

# Define the RTC -> main funcs. Example funcs are defined in exampleTasks.R
runFilterFastaRtc <- function(rtc) {
  minLength <- 25
  return(examplefilterFastaTask(rtc@task@inputFiles[1], rtc@task@outputFiles[1],
    minLength))
}

runFastaReportRtc <- function(rtc) {
  return(examplefastaReport(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

# Import your function from library code
runHelloWorld <- function(inputTxt, outputTxt) {
  msg <- paste("Hello World. Input File ", inputTxt)
  cat(msg, file = outputTxt)
  return(0)
}

# Wrapper to convert Resolved Tool Contract to your library func
runHelloWorldRtc <- function(rtc) {
  return(runHelloWorld(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

# Example populated Registry for testing
#' @export
exampleToolRegistryBuilder <- function() {
  # The driver is what pbsmrtpipe will call with the path to resolved tool contract
  # JSON file FIXME. Not sure how to package exes with R to create a 'console entry
  # point' in python parlance
  # FIXME. There's an extra shell layer to get packrat loaded so the exampleHelloWorld.R
  # can be called correctly.
  r <- registryBuilder(PB_TOOL_NAMESPACE, "exampleHelloWorld.R run-rtc ")
  # could be more clever and use partial application for registry, but this is fine
  registerTool(r, "filterFasta", "0.1.0", c(FileTypes$FASTA), c(FileTypes$FASTA),
    1, FALSE, runFilterFastaRtc)
  registerTool(r, "fastaReport", "0.1.0", c(FileTypes$FASTA), c(FileTypes$REPORT),
    1, FALSE, runFastaReportRtc)
  registerTool(r, "helloWorld", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1,
    FALSE, runHelloWorldRtc)
  return(r)
}

# Run from a Resolved Tool Contract JSON file -> Rscript /path/to/exampleDriver.R
# run-rtc /path/to/rtc.json Emit Registered Tool Contracts to JSON -> Rscript
# /path/to/exampleDriver.R emit-tc /path/to/output-dir then make Tool Contracts
# JSON accessible to pbsmrtpipe Builds a commandline wrapper that will call your
# driver q(status=mainRegisteryMainArgs(exampleToolRegistryBuilder()))
