## 计算exon length
gh.gff = read.delim("03.project/01.Heterosis/02.data/gene.Ghir.CRI.gff3",
                    header = F,
                    sep = "\t",comment.char = "#")
gh.gff %>% 
  select("V3","V4","V5","V9") %>% 
  rename("feature" = "V3","start" = "V4", "end" = "V5", "Gene" = "V9") %>% 
  group_by(feature) %>% 
  filter(feature == "exon") %>% 
  mutate(Gene = gsub("Parent=","",Gene)) %>% 
  group_by(Gene) %>% 
  mutate(length = (end-start+1)) %>% 
  select("Gene","length") %>% 
  summarise(full_length = sum(length),exon_number = n()) -> exon.length
