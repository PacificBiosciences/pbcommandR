# Ported Quick Registry model from pbcommand
# https://github.com/PacificBiosciences/pbcommand
library(methods)

#' @export
PB_TOOL_NAMESPACE <- "pbcommandR"

#' @export
ToolRegistry <- setRefClass("ToolRegistry", fields = list(namespace = "character",
  driver = "character", rtcRunners = "list", toolContracts = "list"))

#' @export
registerTool <- function(registeryObj, idx, version, inputTypes, outputTypes, nproc,
  isDistributed, rtcRunnerFunc) {

  # FIXME isDistributed isn't used. TaskType needs to be updated to the new
  # pbcommand form
  taskId <- paste(registeryObj$namespace, "tasks", idx, sep = ".")

  name <- paste("Task Name ", taskId)
  desc <- paste("Description for ", taskId)
  taskOptions <- list()
  resources <- c(ResourceTypes$TMP_DIR)
  taskType <- "stuff"

  tcTask <- new("ToolContractTask", taskId = taskId, taskType = taskType, inputTypes = inputTypes,
    outputTypes = outputTypes, taskOptions = taskOptions, nproc = nproc, resourceTypes = resources,
    name = name, description = desc, version = version)
  # Need to clarify this.  {driver-base} run-rtc /path/to/rtc.json {driver-base}
  # emit-tool-contract /path/to/output-tool-contract.json
  driver <- new("ToolDriver", exe = registeryObj$driver)
  tc <- new("ToolContract", task = tcTask, driver = driver)

  logging::loginfo(paste("Registering tool contract ", taskId))
  registeryObj$toolContracts[[taskId]] <- tc
  # FIXME. I don't understand [[]] vs [] with funcs in R
  registeryObj$rtcRunners[[taskId]] <- rtcRunnerFunc
  return(tc)
}


# Locally scoped Registry
#' @export
registryBuilder <- function(toolNamespace, driverBase) {
  logging::loginfo("Creating new registry with ")
  r <- ToolRegistry$new(namespace = toolNamespace, driver = driverBase, toolContracts = list(),
    rtcRunners = list())
  return(r)
}

# Runs an RTC from a path to the JSON file and a Registry
#' @export
registryRunner <- function(registry, rtcPath) {
  # This needs to emit the tool-contract or run the TC

  # load RTC from file
  rtc <- loadResolvedToolContractFromPath(rtcPath)
  tid <- rtc@task@taskId
  func <- registry$rtcRunners[[tid]]
  logging::loginfo(paste("successfully loaded rtc runner func from ", tid))
  exitCode <- func(rtc)
  logging::loginfo("Running RTC ")
  return(0)
}

# Writes all Tool Contracts to Output dir
#' @export
emitRegistryToolContractsTo <- function(registry, outputDir) {
  logging::loginfo(c("Emitting all Registry tool contracts to ", outputDir))
  # paste(registry$toolContracts)
  for (name in names(registry$toolContracts)) {
    fileName <- paste(name, "tool_contract.json", sep = "_")
    jsonPath <- file.path(outputDir, fileName)
    logging::loginfo(paste("Writing tool contract to ", jsonPath))
    writeToolContract(registry$toolContracts[[name]], jsonPath)
    # print(registry$toolContracts[[name]])
  }
  logging::loginfo(paste("Completed writing tool contracts to ", outputDir))
  return(0)
}



