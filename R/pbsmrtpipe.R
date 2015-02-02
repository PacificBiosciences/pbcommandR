library(methods)
library(hash)

fileNamespace <- "pbsmrtpipeR"

toFileTypeId <- function(s) {
    return(paste(fileNamespace, "files", s, sep="."))
}


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

toFileTypes <- function() {
    fasta <- new("FileType", fileTypeId=toFileTypeId("fasta"), baseName="file", fileExt="fasta", mimeType="text/plain")
    fastq <- new("FileType", fileTypeId=toFileTypeId("fastq"), baseName="file", fileExt="fastq", mimeType="text/plain")
    return(c(fasta=fasta, fastq=fastq))
}

FileTypes <- toFileTypes()

toSymbolTypes <- function() {
    symbolTypes = c("MAX_NPROC"="$max_nproc", "MAX_NCHUNKS"="$max_nchunks")
    return(symbolTypes)
}

toResourceTypes <- function() {
    resourceTypes = c("TMP_DIR"="$tmpdir", "TMP_FILE"="$tmpfile", "LOG_FILE"="$logfile")
    return(resourceTypes)
}

registerTaskFunc <- function() {
    xRegistry <- hash()
    registerFunc <- function(metaTask) {
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
    funcs <- c("getRegisteredTasks"=getRegisteredTasks, "getRegisteredById"=getRegisteredTaskById)
    return(funcs)
}

# Global Regsitry
registery <- registerTaskFunc()

toTaskOption <- function(taskOptionId, jsonSchemaTypes, displayName, description, defaultValue) {
    opts <- c("optionId"=taskOptionId)
    return(opts)
}

registerMetaTask <- function(taskId, taskType, inputTypes, outputTypes, toCmd) {
    metaTask <- c("taskId"=taskId, "toCmd"=toCmd)
    cat(paste("Registering task", taskId, "\n"))
    cat("Comand\n")
    cat(toCmd())
    return(metaTask)
}

# Example Tasks
myTask <- registerMetaTask("task_01", "local",
                           c(FileTypes$FASTA, FileTypes$GFF), c(FileTypes$CSV),
                           function(inputFiles, outputFiles, nproc) {
                               cat("Running task_01 command\n")
                               return(1)
                           }
                          )

myTask2Cmd <- function(inputFiles, outputFiles, nproc) {
    cat("Running my task 2 custom command")
    return(0)
}

# non-inline Alternative way of writing a task
myTask2 <- registerMetaTask("task_02", "local", c("fastq"), c("csv"), myTask2Cmd)

runTask <- function(taskId, inputFiles, outputFiles, nproc, resources) {
    cat(paste("Running task id", taskId, "\n"))
    return(0)
}


main <- function() {
    # Function for running demo
    cat("Starting main\n")
                                        #cat(registery)
    x <- toTaskOption("myOptionId", c("null", "string"), "My Option", "My Option that does X", "Default value")
    cat(x)
    i <- toFileTypeId("bam")
    s <- toSymbolTypes()
    r <- toResourceTypes()
    cat(r)
    cat(s)
    cat(paste("\nFile type ", i, "\n"))
    cat("Exiting  main\n")
}



