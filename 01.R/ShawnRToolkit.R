########################################
#	Prj: Shawn's R toolkit
#	Assignment: customized R functions
#	Author: Shawn Wang
########################################
## Usage: source "ShawnRToolkit"
## batch import files
BatchReadTable = function(path, type = "delim",pattern,sep = "\t", header = TRUE, quote = "",skip = 0, stringsAsFactors = FALSE){
  fileNames.raw <- dir(path, pattern = pattern) 
  filePath.raw <- sapply(fileNames.raw, function(x){ 
    paste(path,x,sep='/')})
  data.raw <- lapply(filePath.raw, function(x){
    if  (type == "delim") {
      read.delim(x, sep = sep,header = header,quote = quote,stringsAsFactors = FALSE,skip = skip)
    } else if (type == "csv") {
      read.csv(x)
    }
    }) 
  x = list(Name = fileNames.raw,
           file = data.raw)
  return(x)
}

updateWGCNAshiny = function() {
  devtools::install_github("ShawnWx2019/WGCNAShinyFun",ref = "master")
}