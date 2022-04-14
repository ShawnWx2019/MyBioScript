args <- commandArgs(T)
cis <- args[1]
exp <- args[2]
out <- args[3]

# import data -------------------------------------------------------------
library(stringr)

cistrans = read.table(cis,header = T,sep  = "\t",stringsAsFactors = F)
exppat = read.table(exp,header = T,sep = "\t",stringsAsFactors = F)

clean.cis = data.frame(GID = cistrans$gene_id,
                       cis_trans = cistrans$type)
x1 = clean.cis[1,1]
if (str_sub(x1,-2,-2) == ".") {
 clean.cis$GID = gsub("..$","",clean.cis$GID)
}
clean.exppat = data.frame(GID = exppat$circID,
                          type = exppat$category)
x1 = clean.exppat[1,1]
if (str_sub(x1,-2,-2) == ".") {
  clean.exppat$GID = gsub("..$","",clean.exppat$GID)
}

# data cleanning ----------------------------------------------------------


library(tidyverse)

clean.newexp = clean.exppat %>% 
  mutate(type2 = "NA") %>% 
  mutate(type2 = case_when(
    type == "4.Transgressive Up: Paternal higher" ~ "Transgressive",
    type == "4.Transgressive Up: Maternal higher" ~ "Transgressive",
    type == "5.Transgressive Down: Maternal higher" ~ "Transgressive",
    type == "5.Transgressive Down: Paternal higher" ~ "Transgressive",
    type == "2.Maternal-dominant, lower" ~ "ELD",
    type == "2.Maternal-dominant, higher" ~ "ELD",
    type == "3.Paternal-dominant, lower" ~ "ELD",
    type == "3.Paternal-dominant, lower" ~ "ELD",
  )) %>% 
  filter(type2 == "Transgressive" | type2 == "ELD") %>% 
  select(GID,type2)

merge.tbl = inner_join(clean.cis,clean.newexp,"GID")
head(merge.tbl)
clean.cis$type2 = "ASE"
merged.tbl = rbind(merge.tbl,clean.cis)
merged.tbl %>% 
  group_by(cis_trans,type2) %>% 
  summarise(n = n()) %>% 
  as.data.frame()-> merge.tbl.tmp
merge.tbl.tmp$cis_trans = factor(merge.tbl.tmp$cis_trans,levels = c("Only cis","Only trans","cis + trans(identical)","cis + trans(opposite)",
                                               "cis x trans","Compensatory","Conserved","Ambiguous"))
merge.tbl.tmp$type2 = factor(merge.tbl.tmp$type2,levels = c("ASE","ELD","Transgressive"))
unique(merge.tbl.tmp$cis_trans)
# plot --------------------------------------------------------------------
library(ggplot2)
library(ggprism)

p = ggplot(data = merge.tbl.tmp,mapping = aes(x = n,y = type2,fill = cis_trans))+
  geom_bar(stat="identity",position="fill",color = "black",width = 0)+
  theme_prism(palette = "candy_bright",border = T)+
  scale_fill_prism(palette = "floral")+
  xlab("")+
  ylab("")
out2 = merge.tbl.tmp %>% 
  pivot_wider(data = .,id_cols = cis_trans,names_from = type2,values_from = n) %>% 
  replace(is.na(.),0) %>% 
  as.data.frame()
write.table(x = out2,file = paste0(out,"cis-trans-exp.xls"),sep = "\t",row.names = F,quote = F)
ggsave(plot = p,filename = paste0(out,"cis-trans-exp.pdf"),width = 8,height = 4)

  

  
  
