########################################
#	Prj: Shawn's R toolkit
#	Assignment: customized R functions
#	Author: Shawn Wang
########################################
## Usage: source "ShawnRToolkit"
## batch import files
BatchReadTable = function(path, pattern,sep = "\t", header = TRUE, quote = "", stringsAsFactors = FALSE){
  fileNames.raw <- dir(path, pattern = pattern) 
  filePath.raw <- sapply(fileNames.raw, function(x){ 
    paste(path,x,sep='/')})
  data.raw <- lapply(filePath.raw, function(x){
    read.table(x, sep = sep,header = header,quote = quote,stringsAsFactors = FALSE)}) 
  x = list(Name = fileNames.raw,
           file = data.raw)
  return(x)
}