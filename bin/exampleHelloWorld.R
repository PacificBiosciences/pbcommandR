#!/usr/bin/env Rscript
# Simple Hello World Example
# Load the example registry from the library code

library(pbsmrtpipeR)
library(argparser)
library(logging)

# This can be done here or in a separate file
# There can be a single registry for all tasks, or
# subparser-eseque model to group tasks

# Define the RTC -> main funcs
runFilterFastaMain = function(rtc) {
  minLength <- 25
  return(examplefilterFastaTask(rtc.task.inputFiles[0], rtc.task.outputFiles[0], minLength))
}

runFastaReportMain <- function(rtc) {
  return(examplefastaReport(rtc.task.inputFiles[0], rtc.task.outputFiles[0]))
}

runHelloWorld <- function(rtc) {
  fileConn <- file(rtc.task.outputFiles[0])
  writeLines(c("Hello World. Input File ", rtc.task.inputFiles[0]))
  close(fileConn)
  return(0)
}

myToolRegistryBuilder <- function() {
  r <- registryBuilder(PB_TOOL_NAMESPACE, "Rscript /path/to/myExample.R run-rtc ")
  # could be more clever and use partial application for registry, but this is fine
  registerTool(r, "filterFasta", "0.1.0", c(FileTypes$FASTA), c(FileTypes$FASTA), 1, FALSE, runFilterFastaMain)
  registerTool(r, "fastaReport", "0.1.0", c(FileTypes$FASTA), c(FileTypes$FASTA), 1, FALSE, runFastaReportMain)
  registerTool(r, "hello_world", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorld)
  return(r)
}

# Actually Runnable now via
# Run -> Rscript /path/to/exampleDriver.R run-rtc /path/to/rtc.json
# Emit TC -> Rscript /path/to/exampleDriver.R emit-tc /path/to/my-tool-contract.json # then make accessible to pbsmrtpipe
q(status=mainRegisteryMain(myToolRegistryBuilder))

