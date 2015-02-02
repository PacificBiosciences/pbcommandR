library(methods)
library(jsonlite)
library(hash)

# Load the library code
source("pbsmrtpipe.R")

args <- commandArgs(TRUE)

writeMockOutputFile <- function(path) {
    fHandle <- file(path)
    writeLines(paste("Mock file ", path), fHandle)
    close(fHandle)
    logger.debug(paste("Successfully wrote to", path))
}

exampleToCmd <- function(inputFiles, outputFiles, taskOptions, nproc, resources) {
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
    return(exampleToCmd(dm@inputFiles, dm@outputFiles, dm@taskOptions, dm@nproc, dm@resources))
}

usageStatement <- function() {
    m <- "Usage 'driver.R /path/to/driver-manifest.json'"
    stop(m)
}

main <- function() {
    logger.info("Starting main")
    if(length(args) != 1) {
        usageStatement()
    }
    manifestPath <- normalizePath(args[1])
    driverManifest <- loadManifest(manifestPath)
    logger.debug(paste("Loaded task id", driverManifest@taskId, "from manifest", manifestPath))
    #logger(driverManifest)
    results <- runExampleToCmd(driverManifest)
    logger.info("exiting main")
    return(0);
}

main()
