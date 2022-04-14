#########################################
#       Prj: GWF TE density
#       Assignment: TE density test
#       Author: Shawn Wang
#       Date: Apr 15, 2021
#########################################
setwd("~/20.other/gwf/01.src/")
options(scipen = 999)
options(stringsAsFactors = F)
library(tidyverse)
library(stringr)
library(ggplot2)

# 01. Import bed ----------------------------------------------------------

TE.bed = read.delim("~/20.other/gwf/02.rawdata/XYYC.TE.final.noContig.bed",
                    header = F,sep = "\t")
names(TE.bed) = c("Chr","Start","End")
Gene.Pos.raw = read.delim("~/20.other/gwf/02.rawdata/XYYC.final.noContig.Gene.pos.txt",
                      header = F,sep = "\t")
Gene.Pos.new = data.frame(Chr = Gene.Pos.raw$V1,
                          GeneID = Gene.Pos.raw$V9,
                          Start = Gene.Pos.raw$V3,
                          End = Gene.Pos.raw$V4)
test <- head(Gene.Pos.new,100)

TEdensity = function(GID,chr){
  ## catch gene position
  pos.gene = Gene.Pos.new %>% 
    filter(GeneID == GID)
  pos.gene %>% 
    mutate(left = Start-7000, right = End+7000)->pos.gene.range
  ## get TE located in gene flanking ±5k
  TE.bed %>% 
    filter(Chr == chr, Start > 7500) %>% 
    filter(Start %in% c(as.numeric(pos.gene.range$left):as.numeric(pos.gene.range$right)),
           End %in% c(as.numeric(pos.gene.range$left):as.numeric(pos.gene.range$right))) %>% 
    mutate(Start = case_when(
      Start <=  as.numeric(pos.gene.range$Start) ~ Start - as.numeric(pos.gene.range$Start),
      Start >= as.numeric(pos.gene.range$End) ~ Start - as.numeric(pos.gene.range$End)
    ),
    End = case_when(
      End <=  as.numeric(pos.gene.range$Start) ~ End - as.numeric(pos.gene.range$Start),
      End >= as.numeric(pos.gene.range$End) ~ End - as.numeric(pos.gene.range$End)
    )) %>% 
    na.omit() ->TE.gene 
  

  ## make a box with 100bp window by step: 10bp
  loc1 = seq(0,7000,10)
  loc2 = seq(-7000,0,10)
  loc3 = loc1+100
  loc4 = loc2-100
  x = c(loc4,loc1)
  y = c(loc2,loc3)
  box = data.frame(start = x,
                   end = y,
                   count = 0)
  
  ## merge TE pos in selected region
  TE.merge = TE.gene
  ## if the end position of formal TE > the start postion of later one, change the formal TE end value as NA, and change the later start value as formal start. then remove lines with NA value.
  for (i in 1:(nrow(TE.gene)-1)) {
    if (TE.gene[i,3] > TE.gene[i+1,2]) {
      TE.merge[i,3] = NA
      TE.merge[i+1,2] = TE.merge[i,2]
    } else if (TE.gene[i,3] < TE.gene[i+1,2]){
      TE.merge[i,2] = TE.merge[i,2]
      TE.merge[i,3] = TE.gene[i,3]
    }
  }
  ## remove na values
  TE.merge <- na.omit(TE.merge)
  # expand 
  TE.nucleotide.pos = list()
  for (i in 1:nrow(TE.merge)) {
    TE.nucleotide.pos[[i]] = data.frame(chr = chr,
                                        postion = seq(as.numeric(TE.merge[i,2]),as.numeric(TE.merge[i,3]),1),
                                        count = 1)
  }
  TE.pos = bind_rows(TE.nucleotide.pos)

  for (i in 1:nrow(box)) {
    box$count[i] = TE.pos %>% 
      filter(postion > box$start[i] & postion < box$end[i]) %>% 
      mutate(number = if_else(ncol(.) == 0,0,sum(count))) %>% 
      .[1,4]/100
  }
  box %>% 
    mutate(count = count+0.01) %>% 
    mutate_all(~replace(., is.na(.), 0)) -> plt.data
  return(plt.data)
}


test.1st <- list()

for (i in 1:nrow(test)) {
  test.1st[[i]] =data.frame(count = TEdensity(GID = as.character(test$GeneID[i]),chr = as.character(test$Chr[i]))[,3]) 
}

xx = bind_cols(test.1st)
xx$average = apply(xx,1,mean)

loc1 = seq(0,7000,10)
loc2 = seq(-7000,0,10)
loc3 = loc1+100
loc4 = loc2-100
x = c(loc4,loc1)
y = c(loc2,loc3)
box = data.frame(Start = x,
                 End = y)
plt = data.frame(postion = c(loc2,loc1),
                 percentage = xx$average)
box$end

ggplot(plt,mapping = aes(x = postion,y = percentage)) +
  geom_line()+
  xlim(c(-5000,5000))

