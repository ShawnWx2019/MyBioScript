if (!require('rvest')) install.packages('rvest')
if (!require('tidyverse')) install.packages('tidyverse')
library(rvest)
library(tidyverse)

# functions ---------------------------------------------------------------


## get cid via compound name.
Pubchem_Wapper_cid = function(compound_name){
  url = paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/",compound_name,"/cids/TXT?name_type=word")
  tryCatch({
    read_html(url) %>% 
      html_text() %>% 
      read.table(text = .,header = F,sep = "\t",quote = NULL) -> query_list
    query = as.numeric(query_list[1,1])
    x = list(
      query_list = query_list,
      query = query
    )
  }
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
  kegg_list = list()
  for (i in 1:length(Name)) {
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
      print(paste0("The compound: ",Name[i]," searching finished"))
    }, error = function(e) {
      print(paste0("The compound: ",Name[i]," has no search result in pubchem database"))}
    )
  }
  
  out = bind_rows(tmp_list)

  return(out)
}



# run --------------------------------------------------------------

## input and output
input_file = read.delim("~/20.other/zb/DW(1).txt",header = T,sep = "\t")
output_filepath = "~/20.other/zb/output.csv"
## run
xxxx = Batch_Pubchem_Wapper(Input_file = input_file,sleep_time = 2)

colnames(input_file) = c("raw_ID","name")
xx_out = left_join(input_file,xxxx,by= "name")
write.csv(xx_out,output_filepath)

