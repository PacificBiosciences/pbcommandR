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

main <- function() {
  logger.info("Starting main")
  if (length(args) != 1) {
    usageStatement()
  }
  manifestPath <- normalizePath(args[1])
  driverManifest <- loadResolvedToolContractFromPath(manifestPath)
  logger.debug(paste(
    "Loaded Resolved tool contract id", driverManifest@task@taskId, "from manifest", manifestPath
  ))
  # look up Tool in registry
  results <- runExampleToCmd(driverManifest)
  logger.info(results)
  logger.info("exiting main")
  return(0);
}
#main()
