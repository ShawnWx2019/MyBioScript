drawGeneStructure = function(gff,size,lcolor,snp_bed){
  names(gff) = c("chr","source","type","start","end","score","strand","phase","attributes")
  chr = unique(gff$chr)
  strand = unique(gff$strand)
  a = filter(gff,type == "gene")$attributes
  desc = strsplit(a,split = ";")%>%unlist(.)
  tpm1 = filter(gff,type == "exon")
  tpm3 = filter(gff,type == "five_prime_UTR"| type == "three_prime_UTR")
  if (strand == "-"){
    tpm2 = data.frame(type = paste(tpm1$type,seq(1:nrow(tpm1)),sep = ""),
                      end = tpm1$start,
                      start = tpm1$end,
                      y = 2)
    xend = tpm2$end[1]-100
  } else {
    tpm2 = data.frame(type = paste(tpm1$type,seq(1:nrow(tpm1)),sep = ""),
                      start = tpm1$start,
                      end = tpm1$end,
                      y = 2)
    xend = tpm2$end[1]+100
  }
  p = ggplot(tpm2,aes(x = start,y = y))+
    geom_segment(aes(x = tpm2$start[1],y = 2, xend = tpm2$end[nrow(tpm2)], yend = 2),
                 color = lcolor)+
    geom_segment(data = tpm2,
                 mapping = aes(x = start,xend = end,y = 2, yend = 2,color = type),
                 size = size)+
    geom_segment(aes(x = tpm2$end[1],y = 2, xend = xend, yend = 2),
                 arrow = arrow(length = unit(0.2,"cm")),
                 color = "red")+
    xlab(chr)+
    theme(axis.ticks.y.left = element_blank(),
          axis.ticks.y = element_blank(),
          axis.line.y = element_blank(),
          axis.line.x.top = element_blank(),
          panel.grid = element_blank(),
          axis.text.y = element_blank(),
          plot.background = element_blank(),
          panel.background = element_blank(),
          axis.title.y = element_blank(),
          axis.line = element_line(colour = "black",size = 1),
          legend.position = "none")

  if(nrow(tpm3) != 0){
    p = p +
      geom_segment(data = tpm3,
                   mapping = aes(x = start,xend = end,y = 2, yend = 2),
                   size = size,
                   color = "grey")
  } else {
    p = p
  }

  p =
  p + geom_text(data = snp_bed,mapping = aes(x = location,y = 2,label = ref,vjust = -1.5))+
    geom_text(data = snp_bed,mapping = aes(x = location,y = 2,label = alt,vjust = 2))+
    geom_text(data = snp_bed,mapping = aes(x = location,y = 2,label = "↓",vjust = -4))+
    geom_text(data = snp_bed,mapping = aes(x = location,y = 2,label = location,hjust = -1,angle = 90))+
    geom_segment(data = snp_bed,mapping = aes(x = location,xend = location+10,y = 2,yend = 2),size = 4)

  return(p)
}


# run ---------------------------------------------------------------------


snp_bed = read.table("~/My_Repo/MyBioScript/01.R/snp.bed",header = T,sep = "\t")


gff <- read.table("~/My_Repo/MyBioScript/01.R/test.gff",header = F,sep = "\t")
library(tidyverse)
drawGeneStructure(gff = gff,size = 4,lcolor = "black",snp_bed = snp_bed)


