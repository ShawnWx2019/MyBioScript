#####################################
# 	Desc: DEseq2 pairwise-pipeline
# 	Date: Nov 29, 2020
#	Author: Shawn Wang
#####################################
logfile = paste(Sys.time(),"test.log",sep = "_")
con <- file(logfile) 
sink(con, append=TRUE) 
sink(con, append=TRUE, type="message") 
# Setting R script parameters ---------------------------------------------
suppressMessages(library(getopt))
command=matrix(c(
  'help', 'h', 0, 'logic', 'help information',
  'readcount', 'r', 1, 'character', 'inputfile: readcount matrix, geneID in row, sample names in column',
  'left', 'a', 1, 'character', 'pariwise-A: sample A vs sample B, the character which could represented SampleA',
  'right', 'b', 1, 'character', 'pariwise-D: sample A vs sample B, the character which could represented SampleD',
  'fpkm', 'f', 1, 'character', 'inputfile: readcount matrix, geneID in row, sample names in column',
  'pvalue', 'p', 2, 'double', 'pval cutoff: default pval = 1',
  'qvalue', 'q', 2, 'double', 'qval cutoff: default qval = 1',
  'log2fc', 'l', 2, 'double', 'log2fc cutoff: abs(log2fc) dont equal zero, default log2fc = 0'
),byrow = T, ncol = 5)
args = getopt(command)




## help information
if (!is.null(args$help)) {
  cat(paste(getopt(command, usage = T), "\n"))
  q(status=1)
}

## default value
if (is.null(args$readcount)){
  q(status = 1)
}
if (is.null(args$pvalue)){
  args$pvalue = 1
}

if (is.null(args$qvalue)){
  args$qvalue = 1
}

if (is.null(args$log2fc)){
  args$log2fc = 0
}


# naming parameters -------------------------------------------------------

readcount <- args$readcount
fpkm <- args$fpkm
left <- args$left
right <- args$right
pval <- args$pvalue
qvalue <- args$qvalue
log2fc <- args$log2fc

# test
# readcount <- "../../384test/4FB_600.readcount"
# fpkm <- "../../384test/4FB_600.tpm"
# left = "G10FB"
# right = "G15FB"
# log2fc = 0
# pval = 1
# qvalue = 1
# analysis ----------------------------------------------------------------
## packages and defalut setting
options(scipen = 20)
options(stringsAsFactors = F)
suppressMessages(library(DESeq2))
suppressMessages(library(tidyverse))

## import count matrix and fpkm matrix
rawcount <- read.delim(readcount,header = T,sep = "\t")
fpkm <- read.delim(fpkm,header = T,sep = "\t")

## functions
getTargetMat = function(x,left,right) {
  x %>% 
    arrange(colnames(x)[1]) %>% 
    column_to_rownames(colnames(x)[1]) %>% 
    select(starts_with(left),starts_with(right)) -> b
  return(b)
}



## set colData 

setCondition = function(x){
  Sample = colnames(x)
  Cultivar = gsub(pattern = "\\..*$",replacement = "",x = Sample)
  condition = factor(Cultivar,levels = unique(Cultivar))
  colData = data.frame(row.names = Sample,
                       condition = condition)
  return(colData)
}

DE_Analysis = function(mat,coldata,left,right){
  dds <- DESeqDataSetFromMatrix(countData = round(mat,0),
                                colData = coldata,
                                design = ~ condition)
  res = results(DESeq(dds),contrast = c("condition",right,left))
  res = data.frame(GeneID = rownames(res),
                   res)
  return(res)
  
}


get_FPKM_mean = function(x) {
  fpkm_mean = x %>% 
    rownames_to_column("GeneID") %>% 
    pivot_longer(!GeneID,names_to = "sample",values_to = "value") %>% 
    mutate(group = gsub(pattern = "\\..*$",replacement = "",x = sample)) %>% 
    select(-sample) %>% 
    group_by(GeneID,group) %>% 
    summarise(FPKM = mean(value)) %>% 
    pivot_wider(names_from = group,values_from = FPKM) %>% 
    as.data.frame() 
  return(fpkm_mean)
}


outPutFile = function(result,fpkm,log2fc,pval,qvalue){
  result %>% 
    left_join(.,fpkm,by = "GeneID") %>% 
    mutate(
      updown = case_when(
        log2FoldChange > 0 ~ "up",
        log2FoldChange < 0 ~ "down",
        TRUE ~ as.character(log2FoldChange)
      ) 
    ) %>% 
    dplyr::select("GeneID",left,right,"log2FoldChange","updown","pvalue","padj") %>% 
    rename("Log2FC" = "log2FoldChange" ,
           "up/down" = "updown",
           "fdr" = "padj") %>% 
    dplyr::filter(abs(Log2FC) > log2fc) %>% 
    dplyr::filter(pvalue < pval, fdr < qvalue)
}


# run ---------------------------------------------------------------------

## Data cleaning
count.clean <- getTargetMat(x = rawcount,left = left,right = right)
fpkm.clean <- getTargetMat(x = fpkm,left = left,right = right)
## get coldata
coldata = setCondition(x = count.clean)
fpkm_mean = get_FPKM_mean(x = fpkm.clean)
## DE analysis
res <- DE_Analysis(mat = count.clean,coldata = coldata,left = left,right = right)
## make output table.
res_out <-outPutFile(result = res,fpkm =  fpkm_mean,log2fc = log2fc,pval = pval,qvalue = qvalue)
head(res_out)
## write
write.table(x = res_out,file = paste(left,"vs",right,"DE_result.xls",sep = "_"),
            row.names = F,quote = F,sep = "\t")

sink()
sink(type="message")

cat(readLines(logfile), sep="\n")
write.table(cat(readLines(logfile), sep="\n"), "log.txt")

