########################################
#       Prj: MyScript
#       Assignment: dplyr-join
#       Author: Shawn
#######################################
##=======step1 import library==========
suppressMessages(library(getopt))
##=======step2 args setting============
command=matrix(c(
  'help', 'h', 0, 'logic', 'help information',
  'method', 'm', 1, 'character', 'JoinMethod: left, right, inner, full; default: left(equals excel vlookup)',
  'left', 'x', 1, 'character', 'left_file: the 1st file',
  'right', 'y', 1, 'character', 'right_file: the 2nd file',
  'key', 'k', 1, 'character', 'key(by): the colnames of key columns, makesure leftfile and rightfile have the same colnames of key column',
  'out', 'o',1, 'character', 'output name'
),byrow = T, ncol = 5)
args = getopt(command)

## help information
if (!is.null(args$help)) {
  cat(paste(getopt(command, usage = T), "\n"))
  q(status=1)
}

## default value
if (is.null(args$method)){
  args$method = "left"
}

## functions
suppressMessages(library(dplyr))
options(stringsAsFactors = F)
method <- args$method
left <- args$left
right <- args$right
key <- args$key
out <- args$out
Rjoin = function(method,left,right,key,out){
  ## input data
  x = read.delim(file = left, header = T,
                 sep = "\t", quote = NULL)
  x = data.frame(x)
  y = read.delim(file = right, header = T,
                 sep = "\t", quote = NULL)
  y = data.frame(y)
  ## join
  if (method == "left") {
    z = left_join(x,y, by = key)
  } else if (method == "right") {
    z = right_join(x,y, by = key)
  } else if (method == "inner") {
    z = inner_join(x,y, by = key)
  } else if (method == "full") {
    z = full_join(x,y, by = key)
  } 
  ## output
  write.table(z,file = paste0(out,".xls"),
              sep = "\t",
              quote = F,
              row.names = F)
}

Rjoin(method = method,
      left = left,
      right = right,
      key = key,
      out = out)









