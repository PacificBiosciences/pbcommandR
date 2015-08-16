#!/usr/bin/env Rscript
# Simple Hello World Example
# Load the example registry from the library code

library(pbcommandR)
library(argparser)
library(logging)
library(jsonlite, quietly = TRUE)
library(hash, quietly = TRUE)

# Run from a Resolved Tool Contract JSON file -> Rscript /path/to/exampleDriver.R run-rtc /path/to/rtc.json
# Emit Registered Tool Contracts to JSON      -> Rscript /path/to/exampleDriver.R emit-tc /path/to/output-dir
# then make Tool Contracts JSON accessible to pbsmrtpipe
# Builds a commandline wrapper that will call your driver
q(status=mainRegisteryMainArgs(exampleToolRegistryBuilder()))

