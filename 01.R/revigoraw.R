# R script for programtic access to Revigo. Run it with (last output file name is optional):
# Rscript revigo.R example.csv result.csv

library(httr)
library(stringi)

args = commandArgs(trailingOnly=TRUE)

# Read user data from a file
fileName <- args[1] #"example.csv"
userData <- readChar(fileName,file.info(fileName)$size)

# Default output file name is result.csv
if (length(args)>=2) {
    fileNameOutput <- args[2]
} else {
    fileNameOutput <- "result.csv"
}

# Submit job to Revigo
httr::POST(
  url = "http://revigo.irb.hr/StartJob.aspx",
  body = list(
    cutoff = "0.7",
    valueType = "pvalue",
    speciesTaxon = "0",
    measure = "SIMREL",
    goList = userData
  ),
  # application/x-www-form-urlencoded
  encode = "form"
) -> res

dat <- httr::content(res, encoding = "UTF-8")

jobid <- jsonlite::fromJSON(dat,bigint_as_char=TRUE)$jobid

# Check job status
running <- "1"
while (running != "0" ) {
    httr::POST(
      url = "http://revigo.irb.hr/QueryJobStatus.aspx",
      query = list( jobid = jobid )
    ) -> res2
    dat2 <- httr::content(res2, encoding = "UTF-8")
    running <- jsonlite::fromJSON(dat2)$running
    Sys.sleep(1)
}

# Fetch results
httr::POST(
  url = "http://revigo.irb.hr/ExportJob.aspx",
  query = list(
    jobid = jobid, 
    namespace = "1",
    type = "csvtable"
  )
) -> res3

dat3 <- httr::content(res3, encoding = "UTF-8")

# Write results to a file
dat3 <- stri_replace_all_fixed(dat3, "\r", "")
cat(dat3, file=fileNameOutput, fill = FALSE)
