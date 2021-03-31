args <- commandArgs(T)
input = args[1]
out = args[2]
input = read.delim(input,
                   header = T,sep = "\t")
tbl.new = data.frame(GID = gsub("..$","",input$Gene),
                     log2fc = input$log2FoldChange)
tbl.new[is.na(tbl.new)]<- 0
write.table(tbl.new,paste0(out,".rnk"),row.names = F,sep = "\t",quote = F)