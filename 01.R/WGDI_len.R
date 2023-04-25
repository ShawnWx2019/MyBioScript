args<-commandArgs(T)
library(tidyverse)
file_path1 <- args[1]
file_path2 <- args[2]
out <- args[3]
input <- read.delim(file_path1,header = F,sep = "\t")
input2 <- read.delim(file_path2,header = F,sep = "\t")

output = input %>% 
  group_by(V1) %>% 
  summarise(sum = n()) %>% 
  inner_join(input2) %>% 
  select(V1,V2,sum)

write.table(x = output,file = paste0(out,'.len'),row.names = F,col.names = F,quote = F,sep = "\t")