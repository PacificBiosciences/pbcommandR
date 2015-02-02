library(methods)
library(hash)

fileNamespace <- "pbsmrtpipeR"

# Package level logging
.log <- function(level, msg) {
  cat(paste("[", level, "] ", msg, "\n", sep=""))
}

logger.info <- function(msg) {.log("INFO", msg)}
# FIXME. Use partial application
logger.debug <- function(msg) {.log("DEBUG", msg)}
logger.warn <- function(msg) {.log("WARN", msg)}
logger.error <- function(msg) {.log("ERROR", msg)}

setClass("FileType", representation(fileTypeId="character",
                                    baseName="character",
                                    fileExt="character",
                                    mimeType="character"))
# Haw to define custom types
setClass("MetaTask", representation(taskId="character",
                                    taskType="character",
                                    inputTypes="list",
                                    outputTypes="list",
                                    name="character",
                                    description="character"))

# How to generalize this to character, numeric
setClass("TaskOption", representation(optionId="character",
                                      jsonSchemaTypes="list",
                                      displayName="character",
                                      description="character",
                                      defaultValue="character"))

setClass("TaskTypes", representation(LOCAL="character", DISTRIBUTED="character"))


.toId <- function(prefix, s) {paste(fileNamespace, prefix, s, sep=".")}

toFileTypeId <- function(s) { return(paste("pbsmrtpipe", "files", s))}
toTaskOptionId <- function(s) {return(.toId("task_options", s))}
toTaskId <- function(s) {return(.toId("tasks", s))}

TaskTypes <- new("TaskTypes", LOCAL="pbsmrtpipe.task_types.local", DISTRIBUTED="pbsmrtpipe.task_types.distributed")

toFileTypes <- function() {
  # these are ported from pbsmrtpipe
  toF <- function(idx, baseName, fileExt, mimeType) {
    f <- new("FileType", fileTypeId=toFileTypeId(idx), baseName=baseName, fileExt=fileExt, mimeType=mimeType)
    return(f)
  }
    fasta <- new("FileType", fileTypeId=toFileTypeId("fasta"), baseName="file", fileExt="fasta", mimeType="text/plain")
    fastq <- new("FileType", fileTypeId=toFileTypeId("fastq"), baseName="file", fileExt="fastq", mimeType="text/plain")
    gff <- new("FileType", fileTypeId=toFileTypeId("gff"), baseName="file", fileExt="gff", mimeType="text/plain")
    rpt <- toF("report", "file.report", "json", "application/json")
    return(c(FASTA=fasta, FASTQ=fastq, GFF=gff, REPORT=rpt))
}

FileTypes <- toFileTypes()

.toSymbolTypes <- function() {
  # Ported from pbsmrtpipe
  symbolTypes = c("MAX_NPROC"="$max_nproc", "MAX_NCHUNKS"="$max_nchunks")
  return(symbolTypes)
}

SymbolTypes <- .toSymbolTypes()

.toResourceTypes <- function() {
    resourceTypes = c("TMP_DIR"="$tmpdir", "TMP_FILE"="$tmpfile", "LOG_FILE"="$logfile")
    return(resourceTypes)
}

ResourceTypes <- .toResourceTypes()

registerTaskFunc <- function() {
    xRegistry <- hash()
    registerTask <- function(metaTask) {
        cat("Registering task\n")
        cat(metaTask)
        return(metaTask)
    }
    getRegisteredTasks <- function() {
        return(values(xRegistry))
    }
    getRegisteredTaskById <- function(taskId) {
        cat(paste("Getting task ", taskId, "\n"))
        return("mock task")
    }
    funcs <- c("getRegisteredTasks"=getRegisteredTasks, "getRegisteredById"=getRegisteredTaskById, "registerTask"=registerTask)
    return(funcs)
}

# Global Regsitry
registry <- registerTaskFunc()

toTaskOption <- function(taskOptionId, jsonSchemaTypes, displayName, description, defaultValue) {
    opts <- c("optionId"=taskOptionId)
    return(opts)
}

#' Register a MetaTask
#'
#' @param taskId The metatask id
#' @param taskType the task type
#' @param inputTypes a list of file types
#' @param outputTypes a list of file types
#' @param taskOptions a hash of taskOptionId -> JsonSchema
#' @param nproc the number of processors
#' @param resources the list of Resource types
#' @return A metaTask instance
registerMetaTask <- function(taskId, taskType, inputTypes, outputTypes, taskOptions, nproc, resources, toCmd) {
    metaTask <- new("MetaTask", taskId=taskId, taskType=taskType,
                    inputTypes=inputTypes,
                    outputTypes=outputTypes)
    logger.debug(paste("Registering task", taskId, "\n"))
    logger.debug(metaTask)
    #cat("Comand\n")
    #cat(toCmd())
    return(metaTask)
}

runTask <- function(taskId, inputFiles, outputFiles, nproc, resources) {
  # grab task from the registry by id and run the toCmd func
    cat(paste("Mock Running task id", taskId, "\n"))
    return(0)
}

#---------------------------------Driver Manifest ------------------------------------
setClass("DriverManifest", representation(taskId="character",
                                          inputFiles="character",
                                          outputFiles="character",
                                          taskOptions="hash",
                                          nproc="numeric",
                                          resources="character"))


loadManifestFromPath <- function(path) {
    logger.info(paste("Loading manifest from", path))
    if(file.exists(path)){
        s <- readChar(path, file.info(path)$size)
        d <- fromJSON(s)
        return(d)
    } else {
        m <- paste("Unable to find manifest file", "'", path, "'")
        logger.info(msg, "ERROR")
        stop(m)
    }
}

manifestToObject <- function(d) {
    taskId <- d$task$task_id
    inputFiles <- d$task$input_files
    outputFiles <- d$task$output_files
    driverManifest <- new("DriverManifest", taskId=taskId, inputFiles=inputFiles, outputFiles=outputFiles, nproc=1)
    return(driverManifest)
}

loadManifest <- function(path) {
    return(manifestToObject(loadManifestFromPath(path)))
}


