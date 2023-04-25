
# load packages -----------------------------------------------------------


library(rvest)
library(tidyverse)
library(progressr)
library(crayon)
library(writexl)
library(furrr)
plan(multisession,workers = 8)
msg_yes = green$bold$italic
msg_no = red$bold$italic
msg_run = blue$bold$italic$underline
msg_warning = yellow$bold$italic

args<-commandArgs(T)

ID_path = args[1]

out_name = args[2]

ID_df = read.table(ID_path,header = T,sep = "\t")


# functions ---------------------------------------------------------------


KNApSAcK_spider = function(ID) {
  url = 'http://www.knapsackfamily.com/knapsack_core/information.php?word='
  fake_df = data.frame(
    Info = c(
      "Name","Formula","Mw","CAS RN","C_ID","InChIKey","SMILES","Plantae"
    )
  )
  tryCatch({
    raw_table = 
      read_html(paste0(url,ID)) %>% 
      html_nodes(xpath = '//*[@id="my_contents"]/table') %>% 
      html_table() 
    clean_table = 
      raw_table[[1]][-1,c(1,3)] %>% 
      set_names("Info","value") %>% 
      filter(Info != "Organism") %>% 
      filter(!str_detect(Info,pattern = "Start")) %>% 
      mutate(value = case_when(
        Info == "C_ID" ~ str_extract(string = value,pattern = "C\\d+"),
        TRUE ~ value
      )) %>% 
      right_join(.,fake_df,by = "Info") %>% 
      group_by(Info) %>% 
      mutate(value = paste(value,collapse = " | ")) %>% 
      distinct() %>% 
      set_names("C_ID",ID) %>% 
      column_to_rownames("C_ID")
    return(clean_table)
#    message(msg_yes(paste0("Success: ",ID)))
  },error = function(e) {
    message(msg_no("Failed: ",ID))
  })
}


# running -----------------------------------------------------------------


message(msg_run("Running, please wait..."))
start_time <- Sys.time()
batch_run = function(ID_list) {
  p<- progressor(steps = length(ID_list))
  x = furrr::future_map_dfc(.x = ID_list,.f = function(.x) {
    Sys.sleep(0.1)
    p()
    KNApSAcK_spider(ID = .x)
  }) %>% 
    t() %>% 
    as.data.frame() 
  return(x)
}

with_progress({
  output = batch_run(ID_df$id)
})


writexl::write_xlsx(x = output,path = paste0(out_name,".xlsx"))

write.csv(x = output,file = paste0(out_name,".csv"))

end_time<-Sys.time()


# job done, output --------------------------------------------------------


running_time = end_time - start_time

message(msg_warning("Time consuming: ",round(running_time,2)," seconds."))
message(msg_yes("Jobs done!"))



