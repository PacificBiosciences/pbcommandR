# Ported Quick Registry model from pbcommand
# https://github.com/PacificBiosciences/pbcommand
library(logging)
library(methods)

#' @export
PB_TOOL_NAMESPACE <- "pbcommandR"

#' @export
setClass(
  "Registry", representation(
    toolNamespace = "character",
    driverBase = "character",
    toolContracts = "hash",
    rtcRunners = "hash"
  )
)


#' @export
registerTool <- function(registeryObj, idx, version, inputTypes, outputTypes, nproc, isDistributed, rtcRunnerFunc) {

  # FIXME isDistributed isn't used. TaskType needs to be updated to the new
  # pbcommand form
  taskId <- paste(registeryObj@toolNamespace, 'tasks', idx, sep = '.')

  name <- paste("Task Name ", taskId)
  desc <- paste("Description for ", taskId)
  taskOptions <- hash()
  resources <- c(ResourceTypes$TMP_DIR)
  taskType <- "stuff"

  tcTask <- new(
    "ToolContractTask",
    taskId = taskId,
    taskType = taskType,
    inputTypes = inputTypes,
    outputTypes = outputTypes,
    taskOptions = taskOptions,
    nproc = nproc,
    resourceTypes = resources,
    name = name,
    description = desc,
    version = version
  )
  # Need to clarify this.
  # {driver-base} run-rtc /path/to/rtc.json
  # {driver-base} emit-tool-contract /path/to/output-tool-contract.json
  driver <- new("ToolDriver", exe=registeryObj@driverBase)
  tc <- new("ToolContract", task=tcTask, driver=driver)

  loginfo(paste("Registering tool contract ", taskId))
  registeryObj@toolContracts[taskId] <- tc
  # FIXME. I don't understand [[]] vs [] with funcs in R
  registeryObj@rtcRunners[[taskId]] <- rtcRunnerFunc
  return(tc)
}


# Locally scoped Registry
#' @export
registryBuilder <- function(toolNamespace, driverBase) {
  loginfo("Creating new registry with ")
  toolContracts <- hash()
  r <- new("Registry",
           toolNamespace = toolNamespace,
           driverBase=driverBase,
           toolContracts=toolContracts,
           rtcRunners = hash())
 return(r)
}

# Runs an RTC from a path to the JSON file and a Registry
#' @export
registryRunner <- function(registry, rtcPath) {
  # This needs to emit the tool-contract or run the TC

  # load RTC from file
  rtc <- loadResolvedToolContractFromPath(rtcPath)
  tid <- rtc@task@taskId
  hx <- as.list.hash(registry@rtcRunners[[tid]])
  func <- hx[[tid]]
  loginfo(paste("successfully loaded rtc runner func from ", tid))
  exitCode <- func(rtc)
  loginfo("Running RTC ")
  return(0)
}

# Writes all Tool Contracts to Output dir
#' @export
emitRegistryToolContractsTo <- function(registry, outputDir) {
  #loginfo(c("Emitting all Registry tool contracts to ", outputDir))
  loginfo("NOT IMPLEMENTED YET")
  return(-1)
}



