args<- commandArgs(T)
rawpath <- args[1]
out <- args[2]
raw = read.csv(rawpath)
raw = data.frame(raw)
raw = raw[c(1,ncol(raw))]
colnames(raw) = c("GO_ID","TorF")
write.table(raw,paste0(out,".xls"),row.names = F,sep = "\t",quote = F)