
# make annotation db ------------------------------------------------------
## ath database
library(tidyverse)
load("../../../PCK_Db_github/02.Rdata/ath.db")

kegg_t2n = ath.db_final %>% 
  select(PathwayID,Pathway) %>% 
  distinct()
kegg_t2c = ath.db_final %>% 
  select(PathwayID,KEGGID) %>% 
  distinct()

kegg_db <- ath.db_final
rm(ath.db_final)
save(kegg_db,kegg_t2c,kegg_t2n,file = "~/02.MyScript/PCK_Db_github/02.Rdata/zma.db")
## maize database

load("../../../PCK_Db_github/02.Rdata/zma.db")

kegg_t2n = maize.db_final %>% 
  select(PathwayID,Pathway) %>% 
  distinct()
kegg_t2c = maize.db_final %>% 
  select(PathwayID,KEGGID) %>% 
  distinct()

kegg_db <- maize.db_final
rm(maize.db_final)
save(kegg_db,kegg_t2c,kegg_t2n,file = "~/02.MyScript/PCK_Db_github/02.Rdata/zma.db")

## plant cyc ============

## ara_cyc

ath_db <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/ara_compounds.20210325.txt",quote = "")
ath_t2n <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/ara_term2name.txt",quote = "") %>% 
  distinct()
cyc_pathway_detail <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/Pathway_detail.txt")
cyc_db =
  ath_db %>% 
  filter(Chemical_formula != "") %>% 
  mutate(
    Chemical_formula = gsub(pattern = " ",replacement = "",Chemical_formula)
  ) %>% 
  inner_join(.,ath_t2n,c("Pathway" = "NAME"))
cyc_t2n = cyc_db %>% 
  select(TERM,Pathway) %>% 
  distinct()

cyc_t2g = cyc_db %>% 
  select(TERM,Compound_id) %>% 
  distinct()

save(cyc_db,cyc_t2g,cyc_t2n,cyc_pathway_detail,file = "~/02.MyScript/PlantCyc_MS1_DB/02.Rdata/ath_cyc.db")


## plant cyc

ath_db <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/plant_compounds.20210325.txt",quote = "")
ath_t2n <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/plant_term2name.txt",quote = "") %>% 
  distinct()
cyc_pathway_detail <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/Pathways_from_All_pathways_of_PlantCyc.txt")
cyc_db =
  ath_db %>% 
  filter(Chemical_formula != "") %>% 
  mutate(
    Chemical_formula = gsub(pattern = " ",replacement = "",Chemical_formula)
  ) %>% 
  inner_join(.,ath_t2n,c("Pathway" = "NAME"))
cyc_t2n = cyc_db %>% 
  select(TERM,Pathway) %>% 
  distinct()

cyc_t2g = cyc_db %>% 
  select(TERM,Compound_id) %>% 
  distinct()

save(cyc_db,cyc_t2g,cyc_t2n,cyc_pathway_detail,file = "~/02.MyScript/PlantCyc_MS1_DB/02.Rdata/plant_cyc.db")

## zma cyc

ath_db <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/corn_compounds.20210325.txt",quote = "")
ath_t2n <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/zma_term2name.txt",quote = "") %>% 
  distinct()
cyc_pathway_detail <- read.delim("~/02.MyScript/PlantCyc_MS1_DB/01.RawDB/zma_Pathway_detail.txt")
cyc_db =
  ath_db %>% 
  filter(Chemical_formula != "") %>% 
  mutate(
    Chemical_formula = gsub(pattern = " ",replacement = "",Chemical_formula)
  ) %>% 
  inner_join(.,ath_t2n,c("Pathway" = "NAME"))
cyc_t2n = cyc_db %>% 
  select(TERM,Pathway) %>% 
  distinct()

cyc_t2g = cyc_db %>% 
  select(TERM,Compound_id) %>% 
  distinct()

save(cyc_db,cyc_t2g,cyc_t2n,cyc_pathway_detail,file = "~/02.MyScript/PlantCyc_MS1_DB/02.Rdata/zma_cyc.db")
