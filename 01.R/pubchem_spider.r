###########################################
#      Prj:  pubchem spider               #
#      Assignment:  function              #
#      Author:  Shawn Wang                #
#      Date:  Dec 08, 2021                #
###########################################

if (!require('rvest')) install.packages('rvest')
if (!require('tidyverse')) install.packages('tidyverse')
library(rvest)
library(tidyverse)
library(progress)
options(stringsAsFactors = F)
options("repos" = c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
args <- commandArgs(TRUE)

x_1 <- args[1]
x_2 <- args[2]

x_3 <- read.csv(x_1)

## get cid via compound name.
Pubchem_Wapper_cid = function(compound_name){
    compound_name1 = gsub(" ","-",compound_name) ## replace space as -
  url = paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/",compound_name1,"/cids/TXT?name_type=word")
  read_html(url) %>% 
      html_text() %>% 
      read.table(text = .,header = F,sep = "\t",quote = NULL) -> query_list
    query = as.numeric(query_list[1,1])
    x = list(
      query_list = query_list,
      query = query
    )
}

## get details via cid
Pubchem_Wapper_info = function(cid) {
  url = paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/",cid,"/property/MolecularWeight,MolecularFormula,IUPACName,inchikey/CSV")
  read_html(url) %>% 
    html_text() %>% 
    read.csv(text = .)-> tbl
  return(tbl)
}

## kegg waper


# Kegg_wapper = function(compound_name){
#   url = paste0("http://rest.kegg.jp/find/compound/",compound_name)
#   read_html(url) %>% 
#     html_text() %>% 
#     read.table(text = .,header = F,sep = "\t",quote = NULL) %>% 
#     mutate(
#       KEGG_CID = gsub(pattern = "cpd:","",V1),
#       KEGG_annotation = V2,
#       name = compound_name
#     ) %>% 
#     select(-V1,-V2) -> xx
#   kegg_tbl = xx[1,]
#   return(kegg_tbl)
# }


# batch wapper
Batch_Pubchem_Wapper = function(Input_file,sleep_time) {
  colnames(Input_file) = c("CompoundID","Name")
  Name = unique(Input_file$Name) 
  tmp_list = list()
  # kegg_list = list()
  cat("Start fetching information, please wait patiently... ")
  start_time <- Sys.time()
  ## 01.Set up a progress bar to record the progress of the task
  pb <- progress_bar$new(
    format = "Fetching data from uniprot [:bar] :percent in :elapsed",
    total = length(Name), clear = FALSE, width = 100
  )
 
  for (i in 1:length(Name)) {
    pb$tick()
    ## sleep for 2 second, prevent blocked by NCBI
    tryCatch({
      Sys.sleep(sleep_time)
      ## get cid by name
      name = as.character(Name[i])
      cid_tmp = Pubchem_Wapper_cid(compound_name = name)
      cid = cid_tmp$query
      ## get detail info by cid
      tmp_list[[i]] = Pubchem_Wapper_info(cid) %>% 
        add_column(name = Name[i],.before = "CID")
    #  print(paste0("The compound: ",Name[i]," searching finished"))
    }, error = function(e) {
       cat (paste0("The compound: ",Name[i]," has no search result in pubchem database"))
      }
    )
  }
  
  out = bind_rows(tmp_list)

  return(out)
}

outfile = Batch_Pubchem_Wapper(Input_file = x_3, sleep_time = x_2)

write.csv(outfile,file = paste0(gsub(" ","_", Sys.time()),".csv"))