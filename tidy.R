#script to clean up code
library(formatR)

# MK.  lifted this from https://github.com/jeroenooms/jsonlite/blob/master/tidy.R

#see ?tidy.source
options(reindent.spaces=2)
options(replace.assign=TRUE)
lapply(list.files("R", full.name=TRUE), function(x){
  try(tidy.source(x, file=x, width.cutoff=80))
})
