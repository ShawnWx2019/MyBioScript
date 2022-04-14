args<- commandArgs(T)
revigo1<-args[1]
goenrich <- args[2]
out <- args[3]
out <- as.character(out)
x = read.csv(revigo1)
tmp1 = read.delim(goenrich,
                  header = T,sep = "\t",stringsAsFactors = F)
y = data.frame(GO_ID = x$TermID,
               Eliminated = x$Eliminated)

z = dplyr::inner_join(tmp1,y,by = "GO_ID")
write.table(z,file = paste(out,"merge.xls",sep = ""),row.names = F,sep = "\t",quote = F)
