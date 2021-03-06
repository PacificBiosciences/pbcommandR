# Common Datamodels
fileNamespace <- "pbsmrtpipeR"


#' File Type
#' @export
setClass(
  "FileType",
  representation(
    fileTypeId = "character",
    baseName = "character",
    fileExt = "character",
    mimeType = "character"
  )
)

#' Tool Contract Task Input File Type
#' @export
setClass(
  "InputFileType",
  representation(
    title = "character",
    description = "character",
    id = "character",
    fileTypeId = "character"
  )
)

#' Tool Contract Task Input File Type
#' @export
setClass(
  "OutputFileType",
  representation(
    title = "character",
    description = "character",
    baseName = "character",
    id = "character",
    fileTypeId = "character"
  )
)


#' Tool Contract
#' @export
setClass(
  "ToolContractTask",
  representation(
    taskId = "character",
    taskType = "character",
    inputTypes = "vector",
    outputTypes = "vector",
    taskOptions = "list",
    nproc = "numeric",
    resourceTypes = "vector",
    name = "character",
    description = "character",
    version = "character",
    isDistributed = "logical"
  )
)

# How to generalize this to character, numeric
setClass(
  "TaskOption",
  representation(
    optionId = "character",
    jsonSchemaTypes = "list",
    displayName = "character",
    description = "character",
    defaultValue = "character"
  )
)

setClass("TaskTypes",
         representation(LOCAL = "character", DISTRIBUTED =
                          "character"))

#' Tool Driver
#' has the driver exe and env (to be added)
#' @export
setClass("ToolDriver", representation(exe = "character"))

#' Tool Contract
#' @export
setClass("ToolContract",
         representation(task = "ToolContractTask",
                        driver = "ToolDriver"))

#' Resolved Tool Contract Task
#' @export
setClass(
  "ResolvedToolContractTask",
  representation(
    taskId = "character",
    taskType = "character",
    # FIXME
    inputFiles = "vector",
    outputFiles = "vector",
    taskOptions = "list",
    nproc = "numeric",
    resources = "vector"
  )
)

#' Resolved Tool Contract
#' @export
setClass(
  "ResolvedToolContract",
  representation(task = "ResolvedToolContractTask",
                 driver = "ToolDriver")
)

#' Registered Tool Contract
#' @export
setClass(
  "RegisteredToolContract",
  representation(toolContract = "ToolContract",
                 toCmd = "function")
)

.toId <-
  function(prefix, s) {
    paste(fileNamespace, prefix, s, sep = ".")
  }

# Create a PacBio file type id. This must be compatible with
# the reference library pbcommand
# https://github.com/PacificBiosciences/pbcommand/blob/master/pbcommand/models/common.py
#' @export
toFileTypeId <-
  function(s) {
    return(paste("PacBio", "FileTypes", s, sep = '.'))
  }
toDataSetId <-
  function(s) {
    return(paste("PacBio", "DataSet", s, sep = '.'))
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
  methods::new("TaskTypes",
               LOCAL = "pbsmrtpipe.constants.local_task",
               DISTRIBUTED = "pbsmrtpipe.task_types.distributed_task")

.toFileTypes <- function() {
  # these are ported from pbsystem file types
  toF <- function(idx, baseName, fileExt, mimeType, idConverter = toFileTypeId) {
    f <-
      methods::new(
        "FileType",
        fileTypeId = idConverter(idx),
        baseName = baseName,
        fileExt =
          fileExt,
        mimeType = mimeType
      )
    return(f)
  }
  fasta <-
    methods::new(
      "FileType",
      fileTypeId = toFileTypeId("fasta"),
      baseName = "file",
      fileExt =
        "fasta",
      mimeType = "text/plain"
    )
  txt <- toF("txt", "file", "txt", "text/plain")
  fasta <- toF("Fasta", "file", "fasta", "text/plain")
  fastq <- toF("Fastq", "file", "fastq", "text/plain")
  gff <- toF("Gff", "file", "gff", "text/plain")
  ds_align <- toF("AlignmentSet", "file", "alignmentset.xml", "application/xml",
                  idConverter = toDataSetId)
  ds_ref <- toF("ReferenceSet", "file", "referenceset.xml", "application/xml",
                idConverter = toDataSetId)
  csv <- toF("csv", "file", "csv", "application/xml")
  pbrpt <-
    toF("JsonReport", "file.report", "json", "application/json")

  reseqCond = toF("COND_RESEQ",
                  "reseq-conditions",
                  "json",
                  "application/json")

  return(c(
    FASTA = fasta,
    FASTQ = fastq,
    GFF = gff,
    REPORT = pbrpt,
    TXT = txt,
    RESEQ_COND = reseqCond,
    CSV = csv,
    DS_ALIGN = ds_align,
    DS_REF = ds_ref
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
    list(TMP_DIR = "$tmpdir",
         TMP_FILE = "$tmpfile",
         LOG_FILE = "$logfile")
  return(resourceTypes)
}

#' Symbol types used in Tool Contract and Resolved Tool Contracts
#'
#' These are log, tmp files, and dirs.
#' @export
ResourceTypes <- .toResourceTypes()


#' Model For Reseq Condition
#' @export
#'
setClass(
  "ReseqCondition",
  representation(
    condId = "character",
    subreadset = "character",
    alignmentset = "character",
    referenceset = "character"
  )
)

#' Model for ReseqConditions
#' @export
setClass("ReseqConditions",
         representation(pipelineId = "character",
                        conditions = "list"))
