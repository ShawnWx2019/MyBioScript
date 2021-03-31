#################################
#   Prj: Rscript
#   Assignment: qPCR analysis
#   Date: Nov 30, 2020
#   Author: Shawn Wang
#################################
##=====Notice==========
## 01. Just for qPCR assay which have only one kind of replicates (biological or technical)
library(getopt)
library(dplyr)
library(ggplot2)
library(ggsignif)
## import data
x = read.table("~/03.project/03.circRNA/CircRNAVersion3/02.data/03.workingdir/result3.txt",
               sep = "\t",
               header = T)
ddeltaCt = function(reference, gene, material, Repl){
  ## ΔCt1: gene Ct value - reference Ct value.
  ## ΔCt2: average of ΔCt1 of control group.
  RG = list()
  TG = list()
  r = list()
  t = list()
  deltaCt1 = list()
  for (i in 1:length(material)) {
    RG[[i]] = filter(x,Primer == reference, Material == material[i])
    r[[i]] = mean(as.numeric(RG[[i]][,3]))
    TG[[i]] = filter(x,Primer == gene, Material == material[i])
    t[[i]] = mean(as.numeric(TG[[i]][,3]))
    ## ΔCt1 
    deltaCt1[[i]] = as.numeric(TG[[i]][,3]) - as.numeric(RG[[i]][,3])
  }
  ## average ct value of control group 
  ## gene
  r = r[[1]]
  meanr = mean(r)
  ## control
  t = t[[1]]
  meant = mean(t)
  deltaCt2 = meant - meanr
  ## delta delta ct
  deltaCt1 = unlist(deltaCt1)
  expmat = data.frame(Material = rep(material,each = Repl),
                      deltaCt1 = deltaCt1,
                      deltaCt2 = deltaCt2)
  expmat$NegddeltaCt = -(expmat$deltaCt2-expmat$deltaCt1)
  expmat$relativeExp = expmat$NegddeltaCt**2
  n = 1:length(material)
  m = list()
  for (i in 1:(length(n)-1)) {
    m[[i]] = n[-c(1:i)]
  }
  m = unlist(m)
  l = rep(c(1:(length(n)-1)),times = c((length(n)-1):1))
  compl = list()
  for (i in 1:length(m)) {
    compl[[i]] = c(l[i],m[i]) 
  }
  p =  ggplot(expmat,aes(x = Material,
                    y = relativeExp))+
    geom_boxplot()+
    geom_signif(comparisons = compl,map_signif_level = F,test = t.test)+
    theme_bw()+labs(title = gene, x = "",y = expression(2^-ΔΔct))
  a = list(expmat = expmat,
           plot = p )
  return(a)
}
unique(x$Primer)
reference = "UBQ"
material = c("BTF","JF","BTJF")
Repl = 3
gene = "circ_1639_2"
y =ddeltaCt(reference = reference,
         gene = gene,
         material = material,
         Repl = Repl)
y$expmat
y$plot
x
