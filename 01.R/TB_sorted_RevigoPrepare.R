args <- commandArgs(TRUE)
input <- args[1]
out <- args[2]
go = read.delim(input,
                header = T,sep = "\t")
gonew = go[,c(2,4)]
gonew = dplyr::filter(gonew, P_value <= 0.05)
write.table(gonew,file = paste0("revigo",out,".txt"),row.names = F,col.names = F,sep = "\t",quote = F)
