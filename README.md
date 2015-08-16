# pbcommandR

[![Build Status](https://travis-ci.org/mpkocher/pbcommandR.svg?branch=master)](https://travis-ci.org/mpkocher/pbcommandR)

WIP R interface for PacBio Tool Contract and Resolved Tool Contract that can be used in pbsmrtpipe workflow engine.

For more details:

[Docs and Motivation](http://pbcommand.readthedocs.org/en/latest/)

[Python API](https://github.com/PacificBiosciences/pbcommand)

Installing

```r
> library(devtools)
> install_githhub("mpkocher/pbcommandR")
```

Testing

```r
> library(testthat)
> test()
```

# Quick start

```R
library(pbcommandR)

# Import your function from library code
runHelloWorld <- function(inputTxt, outputTxt) {
  fileConn <- file(outputTxt)
  writeLines(c("Hello World. Input File ", inputTxt))
  close(fileConn)
  return(0)
}

# Wrapper to convert Resolved Tool Contract to your library func
runHelloWorldRtc <- function(rtc) {
  return(runHellWorld(rtc@task@inputFiles[1],rtc@task@outFiles[1])) 
}

# The driver is what pbsmrtpipe will call with the path to resolved tool contract JSON file
r <- registryBuilder("pbcommandR", "Rscript /path/to/myExample.R run-rtc ")
registerTool(r, "helloWorld", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorldRtc)
# you can add more than one tool
registerTool(r, "helloWorld2", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 2, FALSE, runHelloWorldRtc)

# Run from a Resolved Tool Contract JSON file -> Rscript /path/to/exampleDriver.R run-rtc /path/to/rtc.json
# Emit Registered Tool Contracts to JSON      -> Rscript /path/to/exampleDriver.R emit-tc /path/to/output-dir 
# then make Tool Contracts JSON accessible to pbsmrtpipe
# Builds a commandline wrapper that will call your driver
q(status=mainRegisteryMainArgs(r))
```

Now the tool id "pbcommandR.tasks.helloWorld" is now usable in a pbsmrtpipe pipeline template.
