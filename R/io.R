# IO parsing for TCs and RTCs
library(jsonlite)

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

  t <- d$resolved_tool_contract
  taskId <- t$tool_contract_id
  inputFiles <- t$input_files
  outputFiles <- t$output_files
  nproc <- t$nproc
  taskType <- "NA"
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
  loginfo(paste("Loading resolved tool contract from ", path))
  return(dictToResolvedToolContract(loadJsonFromFile(path)))
}
