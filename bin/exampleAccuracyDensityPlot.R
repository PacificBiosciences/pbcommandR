#!/usr/bin/env Rscript
# Test Simple Comparison Script
# This script takes a set of conditions and produces a png for display

library(argparser, quietly = TRUE)
library(data.table, quietly = TRUE)
library(jsonlite, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(pbcommandR, quietly = TRUE)
library(uuid, quietly = TRUE)

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
  Condition = factor(as.vector(
    unlist(sapply(1:n, function(i) rep(names[i], nrow(dfs[[i]]))))
  ), levels = unique(names))
  nd = data.table::rbindlist(dfs)
  nd$Condition = Condition
  nd
}

#' Main function to produce plots given a json file and output path
accPlotReseqConditionMain <- function(reseqConditions, reportOutputPath) {
  loginfo("Running Accuracy Denisty Plot with conditions ", reseqConditions)
  loginfo(paste("Output path is:", reportOutputPath))

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
  dfs = lapply(as.character(cond_table$alignmentset), function(s) {
    loginfo(paste("Loading alignment set:", s))
    pbi_name =getBAMNameFromDatasetFile(s)
    loginfo(paste("Loading PBI:", pbi_name))
    loadPBI(pbi_name)
  })
  # Now combine into one large data frame
  cd = combineConditions(dfs, as.character(cond_table$condition))
  # Now calculate the accuracy
  cd$tlen = cd$tend - cd$tstart
  cd$errors = cd$mismatches + cd$inserts + cd$dels
  cd$Accuracy = 1 - cd$errors / cd$tlen

  # Now make a plot
  mkPlot = TRUE # Setting this to false will produce text output.
  if (mkPlot) {
    reportDir <- dirname(reportOutputPath)
    loginfo(paste("Report directory:", reportDir))
    img_name = "acc_density_plot.png"
    img_path = file.path(reportDir, img_name)
    reportUUID <- uuid::UUIDgenerate()
    # Does this name have to match anything?
    reportId <- "pbcommandr_acc_plot"
    version <- "3.1.0"
    tables <- list()
    attributes <- list()

    # Create and add a plot group
    plotGroupId <- "plotgroup_a"
    tp = ggplot(cd, aes(x=Accuracy, fill=Condition)) + geom_density(alpha=.5) +
      theme_bw(base_size=14) +
      labs(x="Accuracy (1 - Mean Errors Per Template Position)", title="Accuracy by Condition")
    png(img_path)
    print(tp)
    dev.off()

    logging::loginfo(paste("Wrote image to ", img_path, sep = ""))
    # see the above comment regarding ids. The Plots must always be provided
    # as relative path to the output dir
    p1 <- methods::new("ReportPlot",
                       id = "acc_example",
                       image = img_name)
    pg <- methods::new("ReportPlotGroup",
                       id = plotGroupId,
                       plots = list(p1))

    plotGroups <- list(pg)

    report <- methods::new("Report",
                           uuid = reportUUID,
                           version = version,
                           id = reportId,
                           plotGroups = plotGroups,
                           attributes = attributes,
                           tables = tables)

    writeReport(report, reportOutputPath)
    logging::loginfo(paste("Wrote report to ", reportOutputPath))
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

  r <- registryBuilder(PB_TOOL_NAMESPACE, "exampleAccuracyDensityPlot.R run-rtc ")

  registerTool(r,
               "accplot_reseq_condition",
               "0.1.0",
               c(FileTypes$RESEQ_COND), c(FileTypes$REPORT), 1, FALSE, accPlotReseqCondtionRtc)
  return(r)
}

## Add this line to enable logging
basicConfig()
q(status=mainRegisteryMainArgs(exampleReseqconditionRegistryBuilder()))
