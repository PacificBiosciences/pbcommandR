
args <- commandArgs(TRUE)


#' Fundamental argument parser to emit tool contracts and
#' Run tool contracts
#' @export
getParser <- function() {
  p <- argparser::arg_parser("Round a floating point number")

  # Add command line arguments
  p <- argparser::add_argument(p, "mode", help = "Mode, emit-tc or run-rtc", type = "character")
  p <- argparser::add_argument(p, "rtc_or_output_dir", help = "run-rtc path/to/rtc.json OR emit-tc /path/to/output-dir",
    type = "character")
  return(p)
}

# Main function to emit the tool contracts stored in the registry or run a
# resolved tool contract.
#' @export
mainRegisteryMain <- function(registry, mode, rtcOrOutputDir) {
  exitCode <- -1

  if (mode == "run-rtc") {
    logging::loginfo(paste("attempting to load RTC from ", rtcOrOutputDir))
    rtcPath <- normalizePath(rtcOrOutputDir)
    exitCode <- registryRunner(registry, rtcPath)
  } else if (mode == "emit-tc") {
    outputDir <- normalizePath(rtcOrOutputDir)
    logging::loginfo(paste("Emitting tool contracts to dir ", outputDir))
    exitCode <- emitRegistryToolContractsTo(registry, outputDir)
  } else {
    cat(paste("Unsupported mode ", mode, " Suppored modes 'emit-tc', and 'run-rtc'"))
    exitCode <- -1
  }

  # run time in seconds
  runTime <- 1
  cat(paste("Exiting main with exit code ", exitCode, "in ", runTime, " secs\n"))
  return(exitCode)
}

#' CLI entry point. Parses CLI args and calls registery Runner
#' @export
mainRegisteryMainArgs <- function(registry) {
  logging::basicConfig(level = 10)
  logging::loginfo(paste("Running with args", args))
  cat("Starting main\n")
  cat(args)

  p <- getParser()
  # Parse the command line arguments
  argv <- argparser::parse_args(p)
  mode <- argv$mode
  rtcOrOutputDir <- argv$rtc_or_output_dir
  return(mainRegisteryMain(registry, mode, rtcOrOutputDir))
}
