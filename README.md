# pbsmrtpipeR

[![Build Status](https://travis-ci.org/mpkocher/pbsmrtpipeR.svg?branch=master)](https://travis-ci.org/mpkocher/pbsmrtpipeR)

WIP R interface for PacBio Tool Contract and Resolved Tool Contract that can be used in pbsmrtpipe workflow engine.

For more details:

[Docs and Motivation](http://pbcommand.readthedocs.org/en/latest/)

[Python API](https://github.com/PacificBiosciences/pbcommand)

Installing

```r
> library(devtools)
> install_githhub("mpkocher/pbsmrtpipeR")
```

Testing

```r
> library(testthat)
> test()
```

# Quick start

```R
library(pbsmrtpipeR)

# Import your function from library code
runHelloWorld <- function(rtc) {
  fileConn <- file(rtc@task@outputFiles[1])
  writeLines(c("Hello World. Input File ", rtc@task@inputFiles[1]))
  close(fileConn)
  return(0)
}

# The driver is what pbsmrtpipe will call with the path to resolved tool contract JSON file
r <- registryBuilder("pbcommandR", "Rscript /path/to/myExample.R run-rtc ")
registerTool(r, "helloWorld", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorld)
registerTool(r, "helloWorld2", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorld)

# Run from a Resolved Tool Contract JSON file -> Rscript /path/to/exampleDriver.R run-rtc /path/to/rtc.json
# Emit Registered Tool Contracts to JSON      -> Rscript /path/to/exampleDriver.R emit-tc /path/to/output-dir 
# then make Tool Contracts JSON accessible to pbsmrtpipe
# Builds a commandline wrapper that will call your driver
q(status=mainRegisteryMainArgs(r))
```

Now the tool id "pbcommandR.tasks.helloWorld" is now usable in a pbsmrtpipe pipeline template.
