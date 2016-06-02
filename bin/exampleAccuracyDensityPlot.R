#!/usr/bin/env Rscript
# Test Simple Comparison Script
# This script takes a set of conditions and produces a png for display

library(argparser)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(pbcommandR)

#' Helper function for verifying arguments
chkClass <- function (var, classname, msg) {
  if (class(var) != classname) {
    stop(msg)
  }
}

#' Helper function to combine loaded data frames.
combineConditions <- function(dfs, names) {
  # Verify args
  if(length(dfs) != length(names)) {
    stop("Names must be the same size as the number of data frames.")
  }
  chkClass(names, "character", "Names for data frames must be a character frame.")
  chkClass(dfs, "list", "Data frames must be a list")
  ncols = sapply(dfs, ncol)
  if (length(unique(ncols)) != 1){
    stop("All data frames must have the same number of columns.")
  }
  if (any(colnames(dfs[[1]])== "Condition")) {
    stop("Can't create a condition column as it already exists.")
  }
  n = length(dfs)
  Condition = factor(as.vector(sapply(1:n, function(i) rep(names[i], nrow(dfs[[i]])))),
                      levels = names)
  nd = data.table::rbindlist(dfs)
  nd$Condition = Condition
  nd
}

#' Main function to produce plots given a json file and output path
accPlotReseqConditionMain <- function(reseqConditions, reportOutputPath) {
  logging.info("Running Accuracy Denisty Plot with conditions ", reseqConditions)
  # Convert json into a data frame
  decoded <- loadReseqConditionsFromPath(reseqConditions)
  conds = decoded@conditions
  tmp = lapply(conds, function(z) data.frame(condition = z@condId,
                                             subreadset = z@subreadset,
                                             alignmentset = z@alignmentset,
                                             referenceset = z@referenceset
                                             ))
  cond_table = do.call(rbind, tmp)

  # Load the pbi index for each data frame
  dfs = lapply(as.character(cond_table$alignmentset), function(s) loadPBI(getBAMNameFromDatasetFile(s)))
  # Now combine into one large data frame
  cd = combineConditions(dfs, as.character(cond_table$condition))
  # Now calculate the accuracy
  cd$tlen = cd$tend - cd$tstart
  cd$errors = cd$mismatches + cd$inserts + cd$dels
  cd$Accuracy = 1 - cd$errors / cd$tlen

  # Now make a plot
  mkPlot = FALSE # Setting this to false will produce text output.
  if (mkPlot) {
    png(paste(reportOutputPath, ".png", sep=""))
    ggplot(cd, aes(x=Accuracy, fill=Condition)) + geom_density() + theme_bw(base_size=14) +
      labs(x="Accuracy (1 - Mean Errors Per Template Position)", title="Accuracy by Condition")
    dev.off()
  } else {
    res = aggregate(Accuracy ~ Condition, cd, function(z) mean(z, na.rm = TRUE))
    write.csv(res, file = reportOutputPath)
  }
  return(0)
}


accPlotReseqCondtionRtc <- function(rtc) {
    return(accPlotReseqConditionMain(rtc@task@inputFiles[1], rtc@task@outputFiles[1]))
}


# Example populated Registry for testing
#' @export
exampleReseqconditionRegistryBuilder <- function() {

  r <- registryBuilder("pbcommandR", "exampleAccuracyDensityPlot_R.sh run-rtc ")

  registerTool(r,
               "accplot_reseq_condition",
               "0.1.0",
               c(FileTypes$RESEQ_COND), c(FileTypes$TXT), 1, FALSE, accPlotReseqCondtionRtc)
  return(r)
}


q(status=mainRegisteryMainArgs(exampleReseqconditionRegistryBuilder()))
