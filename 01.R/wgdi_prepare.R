#####################################
#       Prj: WGDI
#       Assignment: prepare for wgdi
#       Author: Shawn
#       Date: Dec 24, 2022
#####################################

library(tidyverse)

args <- commandArgs(T)

input <- args[1]
input2 <- args[2]
output <- args[3]
chr_tag <- args[4]
gff <- read.delim(input,
                  header = F,sep = "\t")
length <- read.delim(input2,
                     header = F,sep = "\t")
gff.new <-
  gff %>%
  select(
   V1,V2,V3,V4,V5,V6,V7
  ) %>%
  filter(str_detect(V2,chr_tag)) %>%
  mutate(
    V6 = 1:nrow(.)
  )

write.table(x = gff.new,
            file = paste0(output,".gff"),sep = "\t",row.names = F,col.names = F,quote = F)
chr_tag_all <- str_extract(gff.new$V2,pattern = paste0(chr_tag,"[0-9][0-9]"))

gene_num = data.frame(
  chr_tag_all = chr_tag_all
) %>%
  group_by(chr_tag_all) %>%
  summarise(num = n())

if(str_detect(length[1,1],pattern = regex(pattern = "chr",ignore_case = T))) {
  new_tag <- str_extract(length[1,1],"^...")
} else {
  new_tag <- str_extract(length[1,1],"^.")
}

chr_len <-
  gene_num %>%
  mutate(chr_tag_all = str_replace(string = chr_tag_all,pattern = chr_tag,replacement = new_tag)) %>%
  setNames(c("V1","V3")) %>%
  inner_join(length,"V1") %>%
  select(V1,V2,V3)

write.table(x = chr_len,
            file = paste0(output,".len"),sep = "\t",row.names = F,col.names = F,quote = F)
