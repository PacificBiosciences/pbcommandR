# Common Datamodels
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
  txt <- toF("Txt", "file", "txt", "text/plain")
  fasta <- toF("Fasta", "file", "fasta", "text/plain")
  fastq <- toF("Fastq", "file", "fastq", "text/plain")
  gff <- toF("Gff", "file", "gff", "text/plain")
  pbrpt <-
    toF("JsonReport", "file.report", "json", "application/json")
  return(c(
    FASTA = fasta, FASTQ = fastq, GFF = gff, REPORT = pbrpt, TXT = txt
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
