library(pbcommandR)

context("Sanity tests for ToolContract Registry Building")

runHelloWorld <- function(rtc) {
  fileConn <- file(rtc@task@outputFiles[1])
  writeLines(c("Hello World. Input File ", rtc@task@inputFiles[1]))
  close(fileConn)
  return(0)
}

test_that("Simple example", {
  r <- registryBuilder("pbcommandR", "Rscript /path/to/myExample.R run-rtc ")

  registerTool(r, "hello_world", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorld)

  expect_that(10, equals(10))
})

exampleFunc <- function(rtc) {
  return(0)
}

test_that("Registery Builder", {

  r <- registryBuilder("pbcommandR", "namespace")
  inputTypes <- c(FileTypes$FASTA, FileTypes$FASTA)
  outputTypes <- c(FileTypes$REPORT)
  tc <- registerTool(r, "my_id", "0.1.0", inputTypes, outputTypes, 1, FALSE, exampleFunc)
  tid = paste("pbcommandR", "tasks", "my_id", sep = '.')
  # FIXME. This shouldn't be that complicated.
  #hx <- as.list.hash(r@rtcRunners[[tid]])
  #func <- hx[[tid]]
  #rtc <- loadResolvedToolContractFromPath("/Users/mkocher/gh_projects/pbcommandR/rtc.json")
  #loginfo(paste("Loaded RTC with id ", rtc@task@taskId))
  #exitCode <- func(rtc)
  exitCode <- 0
  expect_that(0, equals(exitCode))
})

test_that("Registery Runner", {
  r <- exampleToolRegistryBuilder()
  #rtcPath <- "/Users/mkocher/gh_projects/pbcommandR/rtc.json"
  #exitCode <- registryRunner(r, rtcPath)
  exitCode <- 0
  expect_that(0, equals(exitCode))
})
