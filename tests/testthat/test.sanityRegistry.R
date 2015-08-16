library(pbsmrtpipeR)

context("Sanity tests for ToolContract Registry Building")

runHelloWorld <- function(rtc) {
  fileConn <- file(rtc.task.outputFiles[0])
  writeLines(c("Hello World. Input File ", rtc.task.inputFiles[0]))
  close(fileConn)
  return(0)
}

test_that("Simple example", {
  r <- registryBuilder(PB_TOOL_NAMESPACE, "Rscript /path/to/myExample.R run-rtc ")

  registerTool(r, "hello_world", "0.1.0", c(FileTypes$TXT), c(FileTypes$TXT), 1, FALSE, runHelloWorld)

  expect_that(10, equals(10))
})

exampleFunc <- function(rtc) {
  return(0)
}

test_that("Registery Builder", {

  r <- registryBuilder("tool", "namespace")
  inputTypes <- c(FileTypes$FASTA, FileTypes$FASTA)
  outputTypes <- c(FileTypes$REPORT)
  tc <- registerTool(r, "my_id", "0.1.0", inputTypes, outputTypes, 1, FALSE, exampleFunc)
  tid = paste("tool", "tasks", "my_d", sep = '.')
  #rtcRunnerFunc <- r@rtcRunners[tid]
  expect_that(10, equals(10))
})
