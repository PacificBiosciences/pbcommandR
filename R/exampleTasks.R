# Example Task for Development

# This needs to be globably unique, use the python package, or R package name for this.
PB_TOOL_NAMESPACE <- "pbcommandR"

#' Example Task for testing
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Fasta]
#' @export
examplefilterFastaTask <- function(pathToFasta, filteredFasta, minSequenceLength) {
  loginfo(paste("Writing filtered fasta to ", filteredFasta))
  return(0)
}

#' Example Task for Testing with emitting a report
#'
#' inputs = [FileTypes.Fasta]
#' outputs = [FileTypes.Report]
#' @export
examplefastaReport <- function(pathToFasta, report) {
  loginfo(paste("Writing report of fasta file ", pathToFasta))
  # Generate a report
  return(0)
}
