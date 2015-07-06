library(methods)
library(hash)

fileNamespace <- "pbsmrtpipeR"

# Package level logging
.log <- function(level, msg) {
  cat(paste("[", level, "] ", msg, "\n", sep = ""))
}

logger.info <- function(msg) {
  .log("INFO", msg)
}
# FIXME. Use partial application
logger.debug <- function(msg) {
  .log("DEBUG", msg)
}
logger.warn <- function(msg) {
  .log("WARN", msg)
}
logger.error <- function(msg) {
  .log("ERROR", msg)
}

setClass(
  "FileType", representation(
    fileTypeId = "character",
    baseName = "character",
    fileExt = "character",
    mimeType = "character"
  )
)
# Haw to define custom types
setClass(
  "MetaTask", representation(
    taskId = "character",
    taskType = "character",
    inputTypes = "list",
    outputTypes = "list",
    taskOptions = "list",
    nproc = "numeric",
    resourceTypes = "list",
    name = "character",
    description = "character"
  )
)

# How to generalize this to character, numeric
setClass(
  "TaskOption", representation(
    optionId = "character",
    jsonSchemaTypes = "list",
    displayName = "character",
    description = "character",
    defaultValue = "character"
  )
)

setClass("TaskTypes", representation(LOCAL = "character", DISTRIBUTED =
                                       "character"))


.toId <-
  function(prefix, s) {
    paste(fileNamespace, prefix, s, sep = ".")
  }

#' @export
toFileTypeId <-
  function(s) {
    return(paste("pbsmrtpipe", "files", s))
  }
#' @export
toTaskOptionId <- function(s) {
  return(.toId("task_options", s))
}
#' @export
toTaskId <- function(s) {
  return(.toId("tasks", s))
}

#' @export
TaskTypes <-
  new("TaskTypes", LOCAL = "pbsmrtpipe.task_types.local", DISTRIBUTED = "pbsmrtpipe.task_types.distributed")

.toFileTypes <- function() {
  # these are ported from pbsmrtpipe
  toF <- function(idx, baseName, fileExt, mimeType) {
    f <-
      new(
        "FileType", fileTypeId = toFileTypeId(idx), baseName = baseName, fileExt =
          fileExt, mimeType = mimeType
      )
    return(f)
  }
  fasta <-
    new(
      "FileType", fileTypeId = toFileTypeId("fasta"), baseName = "file", fileExt =
        "fasta", mimeType = "text/plain"
    )
  fasta <- toF("fasta", "file", "fasta", "text/plain")
  fastq <- toF("fastq", "file", "fastq", "text/plain")
  gff <- toF("gff", "file", "gff", "text/plain")
  pbrpt <- toF("report", "file.report", "json", "application/json")
  return(c(
    FASTA = fasta, FASTQ = fastq, GFF = gff, REPORT = pbrpt
  ))
}

#' @export
FileTypes <- .toFileTypes()

.toSymbolTypes <- function() {
  # Ported from pbsmrtpipe
  symbolTypes <-
    list(MAX_NPROC = "$max_nproc", MAX_NCHUNKS = "$max_nchunks")
  return(symbolTypes)
}

#' @export
SymbolTypes <- .toSymbolTypes()

.toResourceTypes <- function() {
  resourceTypes <-
    list(TMP_DIR = "$tmpdir", TMP_FILE = "$tmpfile", LOG_FILE = "$logfile")
  return(resourceTypes)
}

#' @export
ResourceTypes <- .toResourceTypes()

.registerTaskFunc <- function() {
  # dict of all registered metatasks
  xRegistry <- hash()

  registerTask <- function(metaTask) {
    logger.debug(paste("Registering task", metaTask@taskId))
    xRegistry[metaTask@taskId] <- metaTask
    return(metaTask)
  }

  getRegisteredTasks <- function() {
    return(values(xRegistry))
  }
  getRegisteredTaskById <- function(taskId) {
    logger.debug(paste("Getting task ", taskId, "\n"))
    return(xRegistry[[taskId]])
  }
  funcs <-
    c(
      "getRegisteredTasks" = getRegisteredTasks, "getRegisteredById" = getRegisteredTaskById, "registerTask" =
        registerTask
    )
  return(funcs)
}

# Global Regsitry
#' @export
registry <- .registerTaskFunc()

#' @export
toTaskOption <-
  function(taskOptionId, jsonSchemaTypes, displayName, description, defaultValue) {
    opts <- c("optionId" = taskOptionId)
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
#' @export
registerMetaTask <-
  function(taskId, taskType, inputTypes, outputTypes, taskOptions, nproc, resourceTypes, toCmd) {
    desc <- "Task Description"
    name <- paste("MetaTask", taskId)
    metaTask <- new(
      "MetaTask",
      taskId = taskId,
      name = name,
      description = desc,
      taskType = taskType,
      inputTypes = inputTypes,
      outputTypes = outputTypes,
      nproc = nproc, resourceTypes = resourceTypes
    )
    logger.debug(paste("Registering task", metaTask@taskId, "\n"))
    logger.debug(metaTask@taskId)
    #logger.debug(metaTask) # this fails
    #cat("Comand\n")
    #cat(toCmd())
    registry$registerTask(metaTask)
    return(metaTask)
  }

runTask <-
  function(taskId, inputFiles, outputFiles, nproc, resources) {
    # grab task from the registry by id and run the toCmd func
    cat(paste("Mock Running task id", taskId, "\n"))
    return(0)
  }

#' @export
setClass(
  "DriverManifest", representation(
    taskId = "character",
    inputFiles = "character",
    outputFiles = "character",
    taskOptions = "hash",
    nproc = "numeric",
    resources = "character"
  )
)


#' @export
loadManifestFromPath <- function(path) {
  logger.info(paste("Loading manifest from", path))
  if (file.exists(path)) {
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
  driverManifest <-
    new(
      "DriverManifest", taskId = taskId, inputFiles = inputFiles, outputFiles =
        outputFiles, nproc = 1
    )
  return(driverManifest)
}

loadManifest <- function(path) {
  return(manifestToObject(loadManifestFromPath(path)))
}

writeManifest <- function(metaTask, jsonPath) {
  logger.debug(paste("Writing static manifest", metaTask@taskId, "to", jsonPath))
}
