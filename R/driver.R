library(methods)
library(jsonlite)
library(hash)

args <- commandArgs(TRUE)

writeMockOutputFile <- function(path) {
  fHandle <- file(path)
  writeLines(paste("Mock file ", path), fHandle)
  close(fHandle)
  logger.debug(paste("Successfully wrote to", path))
}

exampleToCmd <-
  function(inputFiles, outputFiles, taskOptions, nproc, resources) {
    logger.debug("Running toCmd")
    logger.debug("Input Files")
    logger.debug(inputFiles)
    logger.debug("OutputFiles")
    logger.debug(outputFiles)
    logger.debug("Writing mock output files")
    lapply(outputFiles, writeMockOutputFile)
    # R uses a 1-based index
    # these can be accessed via outputFiles[1], outputFiles[2] ...
    logger.debug("Nproc")
    logger.debug(nproc)
    return(0)
  }

runExampleToCmd <- function(dm) {
  return(
    exampleToCmd(
      dm@inputFiles, dm@outputFiles, dm@taskOptions, dm@nproc, dm@resources
    )
  )
}

usageStatement <- function() {
  m <- "Error Usage 'driver.R /path/to/driver-manifest.json'"
  stop(m)
}

#' Central Commandline Driver interface
#' Tools should use this interface to
#' @export
runDriver <- function(args_, toolContractRegistry_) {
  logger.info("Starting main")
  if (length(args_) != 1) {
    usageStatement()
  }
  logger.info(paste("Args", args_))
  # this should all be wrapped in a tryCatch
  manifestPath <- normalizePath(args_[1])
  rtc <- loadResolvedToolContractFromPath(manifestPath)
  logger.debug(paste(
    "Loaded Resolved tool contract id", rtc@task@taskId, "from ", manifestPath
  ))

  # look up Tool in registry
  results <- toolContractRegistry_(rtc)
  # run task func

  logger.info(results)
  logger.info("exiting main")
  return(0);

}
