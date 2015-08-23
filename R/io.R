# IO parsing for TCs and RTCs
library(jsonlite)

# Should grab this from DESCRIPTION
PB_COMMANDR_VERSION <- "0.2.1"

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
  tc <- d$tool_contract
  taskId <- tc$tool_contract_id
  inputFiles <- tc$input_types
  outputFiles <- tc$output_types
  nproc <- tc$nproc
  toolContractTask <- new("ToolContractTask", name = tc$name, description = tc$description, 
    taskId = taskId, inputTypes = inputFiles, outputTypes = outputFiles, nproc = nproc)
  driver <- new("ToolDriver", exe = d$driver$exe)
  toolContract <- new("ToolContract", task = toolContractTask, driver = driver)
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
  # TO FIX in the model - task options - task type - is distributed
  logdebug(paste("Writing tool contract", toolContract@task@taskId, "to", jsonPath))
  desc <- paste("Tool Contract from ", toolContract@task@taskId)
  authorComment <- paste("Created from pbcommandR version ", PB_COMMANDR_VERSION)
  isDistributed <- FALSE
  schemaOptions <- list()
  # The 'id' needs to be fixed. ft@fileTypeId_{index} this isn't really used in the
  # R 'quick' model, so it's fine.
  toInputType <- function(ft) {
    return(list(file_type_id = ft@fileTypeId, id = paste("id", ft@fileTypeId, 
      sep = "_"), title = paste("Display name ", ft@fileTypeId), description = paste("File type ", 
      ft@fileTypeId)))
  }
  toOutputType <- function(ft) {
    return(list(file_type_id = ft@fileTypeId, id = paste("id", ft@fileTypeId, 
      sep = "_"), title = paste("Display name ", ft@fileTypeId), default_name = paste(ft@baseName, 
      ft@fileExt, sep = "."), description = paste("File type", ft@fileTypeId)))
  }
  inputTypes <- Map(toInputType, toolContract@task@inputTypes)
  outputTypes <- Map(toOutputType, toolContract@task@outputTypes)
  jdriver <- list(serialization = "json", exe = toolContract@driver@exe)
  jt <- list(task_type = "pbsmrtpipe.task_types.standard", resource_types = list(), 
    description = desc, name = toolContract@task@name, nproc = toolContract@task@nproc, 
    is_distributed = isDistributed, schema_options = schemaOptions, tool_contract_id = toolContract@task@taskId, 
    input_types = inputTypes, output_types = outputTypes, comment = authorComment)
  
  j <- list(version = PB_COMMANDR_VERSION, driver = jdriver, tool_contract_id = toolContract@task@taskId, 
    tool_contract = jt)
  jsonToolContract <- toJSON(j, pretty = TRUE, auto_unbox = TRUE)
  cat(jsonToolContract, file = jsonPath)
  return(jsonToolContract)
}

#' Convert a dict to a Resolved Task Contract
dictToResolvedToolContract <- function(d) {
  
  t <- d$resolved_tool_contract
  taskId <- t$tool_contract_id
  inputFiles <- t$input_files
  outputFiles <- t$output_files
  nproc <- t$nproc
  taskType <- "NA"
  taskOptions <- list()
  resources <- c("/path/to/log")
  resolvedToolContractTask <- new("ResolvedToolContractTask", taskId = taskId, 
    taskType = taskType, inputFiles = inputFiles, outputFiles = outputFiles, 
    taskOptions = taskOptions, nproc = nproc, resources = resources)
  driver <- new("ToolDriver", exe = d$driver$exe)
  new("ResolvedToolContract", task = resolvedToolContractTask, driver = driver)
}

#' Load a Resolved Tool contract from json file
#' @export
loadResolvedToolContractFromPath <- function(path) {
  loginfo(paste("Loading resolved tool contract from ", path))
  return(dictToResolvedToolContract(loadJsonFromFile(path)))
}

 
