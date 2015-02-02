library(methods)
library(jsonlite)
library(hash)

# Load the library code
source("pbsmrtpipe.R")

args <- commandArgs(TRUE)

setClass("DriverManifest", representation(taskId="character",
                                          inputFiles="character",
                                          outputFiles="character",
                                          taskOptions="hash",
                                          nproc="numeric",
                                          resources="character"))


logger <- function(msg, level="INFO") {
    # This should be able to be initialized with a handler

    .log <- function(level, msg) {
        cat(paste("[", level, "] ", msg, "\n", sep=""))
    }

    .log(level, msg)

    # FIXME. Use partial application
    debug <- function(msg) {.log("DEBUG", msg)}
    info <- function(msg) {.log("INFO", msg)}
    warn <- function(msg) {.log("WARN", msg)}
    error <- function(msg) {.log("ERROR", msg)}
    # Not exactly sure how to do this in R
    #return(c(debug=debug, info=info, warn=warn, error=error))
}


loadManifestFromPath <- function(path) {
    logger(paste("Loading manifest from", path))
    if(file.exists(path)){
        s <- readChar(path, file.info(path)$size)
        d <- fromJSON(s)
        return(d)
    } else {
        m <- paste("Unable to find manifest file", "'", path, "'")
        logger(msg, "ERROR")
        stop(m)
    }
}

manifestToObject <- function(d) {
    taskId <- d$task$task_id
    inputFiles <- d$task$input_files
    outputFiles <- d$task$output_files
    #inputFiles <- c("file1", "file2")
    #outputFiles <- c("out1", "out2")
    driverManifest <- new("DriverManifest", taskId=taskId, inputFiles=inputFiles, outputFiles=outputFiles, nproc=1)
    return(driverManifest)
}

loadManifest <- function(path) {
    return(manifestToObject(loadManifestFromPath(path)))
}

writeMockOutputFile <- function(path) {
    fHandle <- file(path)
    writeLines(paste("Mock file ", path), fHandle)
    close(fHandle)
    #logger(paste("Successfully wrote to", path))
}

exampleToCmd <- function(inputFiles, outputFiles, taskOptions, nproc, resources) {
    logger("Running toCmd")
    logger("Input Files")
    logger(inputFiles)
    logger("OutputFiles")
    logger(outputFiles)
    logger("Writing mock output files")
    lapply(outputFiles, writeMockOutputFile)
    # R uses a 1-based index 
    # these can be accessed via outputFiles[1], outputFiles[2] ...
    logger("Nproc")
    logger(nproc)
    return(0)
}

runExampleToCmd <- function(dm) {
    return(exampleToCmd(dm@inputFiles, dm@outputFiles, dm@taskOptions, dm@nproc, dm@resources))
}


main <- function() {
    logger("Starting main")
    manifestPath <- normalizePath(args[1])
    driverManifest <- loadManifest(manifestPath)
    logger(paste("Loaded task id", driverManifest@taskId, "from manifest", manifestPath))
    #logger(driverManifest)
    results <- runExampleToCmd(driverManifest)
    logger("exiting main")
    return(0);
}

main()
