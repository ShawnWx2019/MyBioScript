###########################################
#     Prj: GSEA enrichment
#     Assignment: gmt file
#     Date: Dec 25, 2020
###########################################
## install.packages("tidyverse)
## system("for i in `ls *.txt`; do gsed -i 's/"//g' $i;done") remove " in shell first
source("~/02.MyScript/BioScript/01.R/ShawnRToolkit.R")
library(tidyverse)
## import data
gene2go = BatchReadTable(path = "~/20.other/pz/gsea/",pattern = "*.txt",sep = "\t",header = T,quote = NULL,stringsAsFactors = F)
## name the file in import order
name1 = gsub(gene2go$Name,pattern = "_GO_BP.txt",replacement = "")
## the table
gene2goTable = gene2go$file

head(gene2goTable$Ga_CRI_GO_BP.txt)
## convert function
rawdata = gene2goTable$Ga_CRI_GO_BP.txt
convertGMT = function(rawdata){
  x = data.frame(Gene_ID = rawdata[,1],
                 GOterm = paste(rawdata[,2],rawdata[,3],sep = "|"))
  head(x)
  z = aggregate(x, by = list(x$GOterm), c) %>% transmute(GO_ID = .$Group.1, Gene_ID = .$Gene_ID)
  View(z)
  tmp1 = data.frame(GO_ID = z$GO_ID,
                    Gene_ID = 0)
  goname = ""
  goid = ""
  ## unlist and paste them in one line
  for (i in 1:nrow(z)) {
    goid[i] = as.character(unlist(strsplit(z[i,1],split = "|",fixed = T)))[1] ## split GO_ID
    goname[i] = as.character(unlist(strsplit(z[i,1],split = "|",fixed = T)))[2] ## split GO_Name
    a = unlist(z$Gene_ID[i])
    b = 0
    ## if only one gene in this go term then the gene left, if more than one paste them with "+"
    ## The key step is to traverse the entire row, pasting the n-1 and n with "+" together each time, and the last one contains all geneids
    if (length(a) == 1) {
      b[1] = a[1]
    } else{
      for (j in 2:length(a)) {
        b[1] = a[1]
        b[j] = paste(b[j-1],a[j],sep = "|")
      }
    }
    b = b[length(b)]
    tmp1[i,2] = b
  }
  ## make final df
  a = data.frame(GO_ID = goid,
                 GO_Name = goname,
                 Gene_ID = tmp1[,2])
  c = list(split = a)
 return(c)
}

outlist = list(
  Ga_CRI = convertGMT(rawdata = gene2goTable$Ga_CRI_GO_BP.txt),
  Gh_CRI = convertGMT(rawdata = gene2goTable$Gh_CRI_GO_BP.txt),
  Gh_NAU = convertGMT(rawdata = gene2goTable$Gh_NAU_GO_BP.txt),
  Gr_JGI = convertGMT(rawdata = gene2goTable$Gr_JGI_GO_BP.txt)
)
for (i in 1:length(outlist) ) {
  x = data.frame(a = outlist[[i]])
  write.table(x = x,
              file = paste("~/20.other/pz/gsea/",name1[i],"gmtfile.xls",sep = ""),
              row.names = F,
              col.names = F,
              sep = "\t")
}
###########==========KEGG===============
gene2kegg = BatchReadTable(path = "~/20.other/pz/gsea/",pattern = "*pathways.txt",sep = "\t",header = T,quote = NULL,stringsAsFactors = F)
## name the file in import order
name1 = gsub(gene2kegg$Name,pattern = "_KEGG_pathways.txt",replacement = "")
## the table
gene2keggTable = gene2kegg$file

head(gene2keggTable$Ga_CRI_KEGG_pathways.txt)
## convert function
outlist1 = list(
  Ga_CRI = convertGMT(rawdata = gene2keggTable$Ga_CRI_KEGG_pathways.txt),
  Gh_CRI = convertGMT(rawdata = gene2keggTable$Gh_CRI_KEGG_pathways.txt),
  Gh_NAU = convertGMT(rawdata = gene2keggTable$Gh_NAU_KEGG_pathways.txt),
  Gr_JGI = convertGMT(rawdata = gene2keggTable$Gr_JGI_KEGG_pathways.txt)
)
for (i in 1:length(outlist1) ) {
  x = data.frame(a = outlist1[[i]])
  write.table(x = x,
              file = paste("~/20.other/pz/gsea/",name1[i],"kegg.gmtfile.xls",sep = ""),
              row.names = F,
              col.names = F,
              sep = "\t")
}


