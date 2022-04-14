args <- commandArgs(T)
library(tidyverse)
options(stringsAsFactors = F)
raw <- args[1]
name <- args[2]
name <- as.character(name)
read.delim(raw,sep = "\t",header = T) %>%
  select(GO_ID,P_value) %>%
  write.table(x = .,file = paste0(name,".txt"),row.names = F,col.names = F,sep = "\t",quote = F)

