args <- commandArgs(TRUE)
input <- args[1]
out <- args[2]
go = read.delim(input,
                header = T,sep = "\t")
gonew = go[,c(3,5)]
write.table(gonew,file = paste0("revigo",out,".txt"),row.names = F,col.names = F,sep = "\t",quote = F)
