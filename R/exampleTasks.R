# taskOptions <- list()
# resourceTypes <- list()
#
# # Example Tasks
# myTask <- registerMetaTask(toTaskId("dev_task_01"),
#                            TaskTypes@LOCAL,
#                            list(FileTypes$FASTA, FileTypes$GFF),
#                            list(FileTypes$CSV),
#                            taskOptions, 1, resourceTypes,
#                            function(inputFiles, outputFiles, taskOptions, nproc, resources) {
#                              # this is where my custom function should be defined
#                              cat("Running task_01 command\n")
#                              return(1)
#                            })
#
# myTask2Cmd <-
#   function(inputFiles, outputFiles, taskOptions, nproc, resources) {
#     # Alternative way to do define it
#     cat("Running my task 2 custom command")
#     return(0)
#   }
#
# # non-inline Alternative way of writing a task
# myTask2 <- registerMetaTask(
#   toTaskId("task_02"), TaskTypes@LOCAL,
#   list(FileTypes$FASTA),
#   list(FileTypes$CSV, FileTypes$REPORT), taskOptions, 1, resourceTypes, myTask2Cmd
# )

#' Example Task for testing
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Fasta]
exampleTask01 <- function(pathToFasta, filteredFasta, minSequenceLength) {
  logger.info(paste("Writing filtered fasta to ", filteredFasta))
}

#' Example Task for Testing with emitting a report
#'
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Report]
#'
exampleTask02 <- function(pathToFasta, report) {
  logger.info(paste("Writing report of fasta file ", pathToFasta))
  # Generate a report
}
