#####################################
# 	Desc: DEseq2 pairwise-pipeline
# 	Date: Nov 29, 2020
#	Author: Shawn Wang
#####################################

##=======step1 import library==========
suppressMessages(library(getopt))
##=======step2 args setting============
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
  args$samplePerc = 1
}

if (is.null(args$log2fc)){
  args$log2fc = 0
}

## name args
readcount <- args$readcount
fpkm <- args$fpkm
left <- args$left
right <- args$right
pval <- args$pvalue
qvalue <- args$qvalue
log2fc <- args$log2fc
##===========step3 DEseq analysis==============
#############
## test
# readcount = "~/other/ZXM/04.DEseq/cottonADnew.readCount.txt"
# fpkm = "~/other/ZXM/04.DEseq/cottonADnew.readCount.txt"
# left = "A.Fib_10DPA"
# right = "A.Flo"
# pval = 1
# qvalue = 1
# log2fc = 0
#################
options(stringsAsFactors = F)
suppressMessages(library(DESeq2))
suppressMessages(library(dplyr))

rawcount <- read.table(readcount, header = T,
                       sep = "\t")
## sort rawcount ==> Dec 14, 2020
rawcount = rawcount[order(rawcount[,1]),]
# rawcount[1:6,1:6]
rawcount <- data.frame(row.names = rawcount[,1],
                       rawcount[,-1])
fpkm <- read.delim(fpkm, header = T,
                   sep = "\t")
## sort fpkm ==> Dec 14,2020
fpkm <- fpkm[order(fpkm[,1]),]
# fpkm[1:6,1:6]
fpkm <- data.frame(row.names = fpkm[,1],
                   fpkm[,-1])
Sample = colnames(rawcount)
Cultivar = gsub(pattern = ".$",replacement = "",Sample)
condition <- factor(Cultivar,levels = unique(Cultivar))
colData = data.frame(row.names = Sample,
                     condition = condition)
## index
A = which(colData$condition == left)
B = which(colData$condition == right)
## counts of each sample
countA = rawcount[,A]
countB = rawcount[,B]
name = c(left,right)
## DE analysis
count = cbind(countA,countB)
info = data.frame(sample = names(count),cultivar = rep(name,times = c(3,3)))
dds <- DESeqDataSetFromMatrix( countData = round(count,0), colData =info, design = ~ cultivar)
res = results(DESeq(dds),contrast = c("cultivar",left,right))
res = data.frame(GeneID = rownames(res),res)
## fpkm mean
fpkmA = fpkm[,A]
meanA = data.frame(meanA = apply(fpkmA, 1, mean))
fpkmB = fpkm[,B]
meanB = data.frame(meanB = apply(fpkmB, 1, mean))
updown = case_when(
  res$log2FoldChange > 0 ~"up",
  res$log2FoldChange < 0 ~"down",
  TRUE ~ as.character(res$log2FoldChange)
)
res = data.frame(res,
                 A = meanA,
                 B = meanB,
                 updown = updown)

##==============Step4 filter and output==================
x = dplyr::filter(res, abs(log2FoldChange) > log2fc) %>% dplyr::filter(.,pvalue < pval, padj < qvalue)

x = data.frame(GeneID = x$GeneID,
               A = x$meanA,
               B = x$meanB,
               log2fc = x$log2FoldChange,
               updown = x$updown,
               pvalue = x$pvalue,
               fdr = x$padj)
names(x) = c("GeneID",left,right,"log2fc","up/down","pvalue","fdr")

write.table(x = x,
            file = paste0(left,"_vs_",right,".xls"),
            sep = "\t",
            quote = F, row.names = F)
