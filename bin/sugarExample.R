#!/usr/bin/env Rscript

# An example file which shows how to implement a tool for analysis in SMRTLink.
# The user can copy this file, and implement their own tool by:
# 1 - Changing the implementation of makeReport
# 2 - Changing the function arguments in the penultimate line to match your desired name.


# Some example libraries we can load
library(data.table, quietly = TRUE)
library(logging)
library(ggplot2)
library(pbbamr)
library(pbcommandR, quietly = TRUE)
library(gridExtra)
library(dplyr, quietly = TRUE)
library(tidyr, quietly = TRUE)

# The core function, change the implementation in this to add new features.
makeReport <- function(report) {
  # Call this function to get a data frame of conditions, which is a data frame containing
  # four columns with the ConditionName, Subreadset, Alignmentset, Referenceset
  conditions = report$condition.table


  # To save a plot into the output report, we simply call this ggsave funciton
  # with some extra arguments to add captions, titles, etc.
  myplot = qplot(1:2, 3:4)
  report$ggsave("filename.png",
                myplot,
                id = "some_lame_id",
                title = "My Fantastic Plot!",
                caption = "This is really fantastic.")

  # To save a data.frame call this function, also with additional arguments
  report$write.table(conditions,
                     id = "some_lame_id",
                     title = "An important table")

  # At the end of this function we need to call this last, it outputs the report
  report$write.report()
}


# Now we need to wrap this tool using these two lines. Simply change the
# arguments here to match your desired filename, tool name and report id.
rpt = pbReseqJob("sugarExample.R", "my_tool_name", makeReport, reportid = "what report")

# Leave this as the last line in the file.
q(status = rpt())
