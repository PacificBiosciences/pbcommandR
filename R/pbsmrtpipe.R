library(methods)
library(hash)
library(logging)

fileNamespace <- "pbsmrtpipeR"

setClass(
  "FileType", representation(
    fileTypeId = "character",
    baseName = "character",
    fileExt = "character",
    mimeType = "character"
  )
)

#' Tool Contract
#' @export
setClass(
  "ToolContractTask", representation(
    taskId = "character",
    taskType = "character",
    inputTypes = "vector",
    outputTypes = "vector",
    taskOptions = "hash",
    nproc = "numeric",
    resourceTypes = "vector",
    name = "character",
    description = "character",
    version = "character"
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

#' Tool Driver
#' has the driver exe and env (to be added)
#' @export
setClass("ToolDriver", representation(exe = "character"))

#' Tool Contract
#' @export
setClass(
  "ToolContract", representation(task = "ToolContractTask",
                                 driver = "ToolDriver")
)

#' Resolved Tool Contract Task
#' @export
setClass(
  "ResolvedToolContractTask", representation(
    taskId = "character",
    taskType = "character", # FIXME
    inputFiles = "vector",
    outputFiles = "vector",
    taskOptions = "hash",
    nproc = "numeric",
    resources = "vector"
  )
)

#' Resolved Tool Contract
#' @export
setClass(
  "ResolvedToolContract", representation(task = "ResolvedToolContractTask",
                                         driver = "ToolDriver")
)

#' Registered Tool Contract
#' @export
setClass("RegisteredToolContract",
         representation(
           toolContract = "ToolContract",
           toCmd = "function")
         )

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

#' PacBio Defined task types
#' @export
TaskTypes <-
  new("TaskTypes",
      LOCAL = "pbsmrtpipe.constants.local_task",
      DISTRIBUTED = "pbsmrtpipe.task_types.distributed_task")

.toFileTypes <- function() {
  # these are ported from pbsystem file types
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
  fasta <- toF("Fasta", "file", "fasta", "text/plain")
  fastq <- toF("Fastq", "file", "fastq", "text/plain")
  gff <- toF("Gff", "file", "gff", "text/plain")
  pbrpt <-
    toF("JsonReport", "file.report", "json", "application/json")
  return(c(
    FASTA = fasta, FASTQ = fastq, GFF = gff, REPORT = pbrpt
  ))
}

#' Registry for all the PacBio defined file types
#' @export
FileTypes <- .toFileTypes()

.toSymbolTypes <- function() {
  # Ported from pbsmrtpipe
  symbolTypes <-
    list(MAX_NPROC = "$max_nproc", MAX_NCHUNKS = "$max_nchunks")
  return(symbolTypes)
}

#' Symbol types used in Tool Contract and Resolved Tool Contracts
#'
#' max NPROC
#' @export
SymbolTypes <- .toSymbolTypes()

.toResourceTypes <- function() {
  resourceTypes <-
    list(TMP_DIR = "$tmpdir", TMP_FILE = "$tmpfile", LOG_FILE = "$logfile")
  return(resourceTypes)
}

#' Symbol types used in Tool Contract and Resolved Tool Contracts
#'
#' These are log, tmp files, and dirs.
#' @export
ResourceTypes <- .toResourceTypes()

# Utils to Register a Tool Contract
.registerTaskFunc <- function() {
  # dict of all registered metatasks
  xRegistry <- hash()

  registerTask <- function(metaTask) {
    logdebug(paste("Registering task", metaTask@taskId))
    xRegistry[metaTask@taskId] <- metaTask
    return(metaTask)
  }

  getRegisteredTasks <- function() {
    return(values(xRegistry))
  }
  getRegisteredTaskById <- function(taskId) {
    logdebug(paste("Getting task ", taskId, "\n"))
    return(xRegistry[[taskId]])
  }
  funcs <-
    c(
      "getRegisteredTasks" = getRegisteredTasks,
      "getRegisteredById" = getRegisteredTaskById,
      "registerTask" = registerTask
    )
  return(funcs)
}

# Global Registry for all R analysis tasks
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
registerToolContract <-
  function(toolContract, toCmd) {

    registeredToolContract = new("RegisteredToolContract", toolContract = toolContract, toCmd = toCmd)
    logdebug(paste("Registering task", toolContract@task@taskId, "\n"))
    logdebug(toolContract@taskId)
    registry$registerTask(registeredToolContract)
    return(toolContract)
  }

#' Run a R task
#' @export
runTask <-
  function(taskId, inputFiles, outputFiles, nproc, resources) {
    # grab task from the registry by id and run the toCmd func
    cat(paste("Mock Running task id", taskId, "\n"))
    return(0)
  }


#' General func to load JSON from a file
#' @export
loadJsonFromFile <- function(path) {
  loginfo(paste("Loading tool contract from", path))
  if (file.exists(path)) {
    s <- readChar(path, file.info(path)$size)
    d <- fromJSON(s)
    return(d)
  } else {
    m <- paste("Unable to find json file", "'", path, "'")
    loginfo(msg, "ERROR")
    stop(m)
  }
}

#' convert the json to ToolContract instance
dToToolContract <- function(d) {
  tc = d$tool_contract
  taskId <- tc$tool_contract_id
  inputFiles <- tc$input_types
  outputFiles <- tc$output_types
  nproc <- tc$nproc
  toolContractTask <-
    new(
      "ToolContractTask",
      name = tc$name,
      description = tc$description,
      taskId = taskId,
      inputTypes = inputFiles,
      outputTypes = outputFiles,
      nproc = nproc
    )
  driver <- new("ToolDriver", exe=d$driver$exe)
  toolContract <- new("ToolContract", task=toolContractTask, driver=driver)
  return(toolContract)
}

#' Load Tool Contract from Path
#' @export
loadToolContractFromPath <- function(path) {
  return(dToToolContract(loadJsonFromFile(path)))
}

#' Write Tool Contract to JSON file
#' @param toolContract Tool Contract
#' @export
writeToolContract <- function(toolContract, jsonPath) {
  logdebug(paste("Writing tool contract", toolContract@task@taskId, "to", jsonPath))
}

#' Convert a dict to a Resolved Task Contract
dictToResolvedToolContract <- function(d) {
  t <- d$tool_contract
  taskId <- t$tool_contract_id
  inputFiles <- t$input_files
  outputFiles <- t$output_files
  nproc <- t$nproc
  taskType <- t$tool_type
  taskOptions <- hash()
  resources <- c("/path/to/log")
  resolvedToolContractTask <-
    new(
      "ResolvedToolContractTask",
      taskId = taskId,
      taskType = taskType,
      inputFiles = inputFiles,
      outputFiles = outputFiles,
      taskOptions = taskOptions,
      nproc = nproc,
      resources = resources
    )
  driver <- new("ToolDriver", exe=d$driver$exe)
  new("ResolvedToolContract", task = resolvedToolContractTask, driver = driver)
}

#' Load a Resolved Tool contract from json file
#' @export
loadResolvedToolContractFromPath <- function(path) {
  logger.info(paste("Loading resolved tool contract from ", path))
  return(dictToResolvedToolContract(loadJsonFromFile(path)))
}
