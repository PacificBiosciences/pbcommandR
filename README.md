# pbcommandR

[![Build Status](https://travis-ci.org/PacificBiosciences/pbcommandR.svg?branch=master)](https://travis-ci.org/PacificBiosciences/pbcommandR)

WIP R interface for PacBio Tool Contract and Resolved Tool Contract that can be used in pbsmrtpipe workflow engine.

For more details:

[Docs and Motivation](http://pbcommand.readthedocs.org/en/latest/)

[Python API](https://github.com/PacificBiosciences/pbcommand)

Installing

```r
> library(devtools)
> install_githhub("PacificBiosciences/pbcommandR")
```

Interactive loading

```r
> devtools::load_all()
> # load code and experiment
```
Update NAMESPACE to export funcs.

```r
> library(devtools)
> document()
```

Testing

```r
> library(devtools)
> library(testthat)
> devtools::test()
```

# Quick start

```R
library(pbcommandR)

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
q(status=mainRegisteryMainArgs(exampleToolRegistryBuilder()))
```

Now the tool id "pbcommandR.tasks.helloWorld" is now usable in a pbsmrtpipe pipeline template.

Disclaimer
----------
THIS WEBSITE AND CONTENT AND ALL SITE-RELATED SERVICES, INCLUDING ANY DATA, ARE PROVIDED "AS IS," WITH ALL FAULTS, WITH NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY WARRANTIES OF MERCHANTABILITY, SATISFACTORY QUALITY, NON-INFRINGEMENT OR FITNESS FOR A PARTICULAR PURPOSE. YOU ASSUME TOTAL RESPONSIBILITY AND RISK FOR YOUR USE OF THIS SITE, ALL SITE-RELATED SERVICES, AND ANY THIRD PARTY WEBSITES OR APPLICATIONS. NO ORAL OR WRITTEN INFORMATION OR ADVICE SHALL CREATE A WARRANTY OF ANY KIND. ANY REFERENCES TO SPECIFIC PRODUCTS OR SERVICES ON THE WEBSITES DO NOT CONSTITUTE OR IMPLY A RECOMMENDATION OR ENDORSEMENT BY PACIFIC BIOSCIENCES.
