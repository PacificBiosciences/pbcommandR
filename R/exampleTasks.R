# Example Task for Development

#' Example Task for testing
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Fasta]
#' @export
examplefilterFastaTask <- function(pathToFasta, filteredFasta, minSequenceLength) {
  loginfo(paste("Writing filtered fasta to ", filteredFasta))
  return(0)
}

#' Example Task for Testing with emitting a report
#'
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Report]
#' @export
examplefastaReport <- function(pathToFasta, report) {
  loginfo(paste("Writing report of fasta file ", pathToFasta))
  # Generate a report
  return(0)
}

# This can be done here or in a separate file
# There can be a single registry for all tasks, or
# subparser-eseque model to group tasks

# Define the RTC -> main funcs. Example funcs are defined in exampleTasks.R
runFilterFastaRtc = function(rtc) {
  minLength <- 25
  return(examplefilterFastaTask(rtc@task@inputFiles[1], rtc@task@outputFiles[1], minLength))
}

runFastaReportRtc <- function(rtc) {
  return(examplefastaReport(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

# Import your function from library code
runHelloWorld <- function(inputTxt, outputTxt) {
  fileConn <- file(outputTxt)
  writeLines(c("Hello World. Input File ", inputTxt))
  close(fileConn)
  return(0)
}

# Wrapper to convert Resolved Tool Contract to your library func
runHelloWorldRtc <- function(rtc) {
  return(runHelloWorld(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

# Example populated Registry for testing
#' @export
exampleToolRegistryBuilder <- function() {
  # The driver is what pbsmrtpipe will call with the path to resolved tool contract JSON file
  r <- registryBuilder(PB_TOOL_NAMESPACE, "Rscript /path/to/myExample.R run-rtc ")
  # could be more clever and use partial application for registry, but this is fine
  registerTool(r, "filterFasta", "0.1.0", c(FileTypes$FASTA), c(FileTypes$FASTA), 1, FALSE, runFilterFastaRtc)
  registerTool(r, "fastaReport", "0.1.0", c(FileTypes$FASTA), c(FileTypes$FASTA), 1, FALSE, runFastaReportRtc)
  registerTool(r, "helloWorld", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorldRtc)
  return(r)
}

# Run from a Resolved Tool Contract JSON file -> Rscript /path/to/exampleDriver.R run-rtc /path/to/rtc.json
# Emit Registered Tool Contracts to JSON      -> Rscript /path/to/exampleDriver.R emit-tc /path/to/output-dir
# then make Tool Contracts JSON accessible to pbsmrtpipe
# Builds a commandline wrapper that will call your driver
#q(status=mainRegisteryMainArgs(exampleToolRegistryBuilder()))
