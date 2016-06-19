#!/usr/bin/env Rscript
# Simple Hello World Example
# Load the example registry from the library code

library(pbcommandR)
library(argparser)
library(logging)
library(uuid)
library(jsonlite, quietly = TRUE)

#' Example Function that would be imported from your core library
helloReseqConditionMain <- function(reseqConditionsPath, txtOutputPath) {
  logging::loginfo("Running main with conditions from file", reseqConditionsPath)
  reseqConditions <- loadReseqConditionsFromPath(reseqConditionsPath)
  logging::loginfo("Loaded conditions ")
  write("Hello World Reseq Condition", file = txtOutputPath)
  return(0)
}

#' Example function that will leverage a Report and write
#' a single Report Attribute
helloReseqConditionReportMain <- function(reseqConditionsPath, reportOutputPath) {
  logging::loginfo("Running main with conditions from file", reseqConditionsPath)
  reseqConditions <- loadReseqConditionsFromPath(reseqConditionsPath)
  logging::loginfo("Loaded conditions ")

  reportUUID <- uuid::UUIDgenerate()
  a1 <- methods::new("ReportAttribute", id = "num_conditions", value = length(reseqConditions@conditions), name = "Number of Conditions")

  report <- methods::new("Report", id = "pbcommandr_hello_reseq", plotGroups = list(),
  attributes = list(a1), tables = list(), uuid = reportUUID, version = "0.3.3")

  writeReport(report, reportOutputPath)
  logging::loginfo("completed writing report")
  return(0)
}

# Resolved Tool Contract Wrappers to call lib main code

#' Convert RTC to args for lib function,
helloReseqConditionRtc <- function(rtc) {
  return(helloReseqConditionMain(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

helloReseqConditionReportRtc <- function(rtc) {
  return(helloReseqConditionReportMain(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}

# Example populated Registry for testing
#' @export
exampleReseqconditionRegistryBuilder <- function() {

  r <- registryBuilder(PB_TOOL_NAMESPACE, "exampleReseqConditions.R run-rtc ")

  registerTool(r,
               "hello_reseq_condition", "0.1.1",
               c(FileTypes$RESEQ_COND), c(FileTypes$TXT), 1, FALSE, helloReseqConditionRtc)

  registerTool(r, "hello_reseq_condition_report", "0.1.1",
    c(FileTypes$RESEQ_COND), c(FileTypes$REPORT), 1, FALSE, helloReseqConditionReportRtc)
  return(r)
}


q(status=mainRegisteryMainArgs(exampleReseqconditionRegistryBuilder()))
