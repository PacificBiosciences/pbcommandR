#!/usr/bin/env Rscript
# Simple Hello World Example
# Load the example registry from the library code

library(pbcommandR)
library(argparser)
library(logging)
library(jsonlite, quietly = TRUE)

helloReseqConditionMain <- function(reseqConditions, reportOutputPath) {
  logging.info("Running main with conditions ", reseqConditions)
  write("Hello World Reseq Condition", file = reportOutputPath)
  return(0)
}


helloReseqCondtionRtc <- function(rtc) {
  return(helloReseqCondtionMain(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}


# Example populated Registry for testing
#' @export
exampleReseqconditionRegistryBuilder <- function() {

  r <- registryBuilder("example_reseq_condition", "exampleReseqCondition_R.sh run-rtc ")

  registerTool(r,
               "hello_reseq_condtion",
               "0.1.0",
               c(FileTypes$RESEQ_COND), c(FileTypes$TXT), 1, FALSE, helloReseqCondtionRtc)
  return(r)
}


q(status=mainRegisteryMainArgs(exampleToolRegistryBuilder()))
