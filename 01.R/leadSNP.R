######################################
#       Prj: Extract lead SNP
#       Version: 0.02
#       Author: Shawn Wang
#       Date: Feb 24, 2020
######################################
if (!require('tidyverse')) BiocManager::install('tidyverse',update = FALSE)
if (!require('furrr')) BiocManager::install('furrr',update = FALSE)
if (!require('future')) BiocManager::install('future',update = FALSE)
if (!require('progressr')) BiocManager::install('progressr',update = FALSE)
suppressMessages(library(tidyverse))
suppressMessages(library(getopt))
suppressMessages(library(furrr))
suppressMessages(library(future))
suppressMessages(library(progressr))
plan(multisession,workers = 8)
options(stringsAsFactors = F)
command=matrix(c(
  'help', 'h', 0, 'logic', 'help information',
  'data', 'd', 1, 'character', 'inputfile: table with headers, the 1st column is label,the second is location',
  'binsize', 'b', 1, 'integer', 'Bin Size: the bin size, if you want set the bin size as 10kb ==>  eg:10000',
  'key', 'k', 1, 'character', 'Key: the lab name you want to extract,if you want calculate chr A01 ==> , eg: "A01"',
  'maxVal', 'm', 1, 'integer', 'Max value : the max value of selected key, such as the length of A01 is 115949770'
),byrow = T, ncol = 5)
args = getopt(command)
## help information
if (!is.null(args$help)) {
  cat(paste(getopt(command, usage = T), "\n"))
  #  q(status=1)
}

## name values
x <- args$data
binsize <- args$binsize
key = args$key
maxVal = args$maxVal

## test
 # x <- "~/20.other/zxm/test/403_allgene_A07_cutoff6.53_1(1).txt"
 # binsize = 100000
 # key = "A07"
 # maxVal = 115949770
## import data
data = read.table(x,header = T,
                  sep = "\t")
## 代谢物去重，有多少个代谢物
meta = unique(data$metaID)
# head(data)
# 数据分割
message("Step1. Split data by metabolites. ...")
step1_split_data = function(meta) {
  message("Start ...")
  p <- progressor(steps = length(meta))
  step_1_result = furrr::future_map(.x = meta,.f = function(.x) {
    p()
    Sys.sleep(0.005)
    a= data %>% filter(metaID == .x); return(a)
  })
  return(step_1_result)

}

with_progress({
  meta.list = step1_split_data(meta = meta)
})

message("Step1. data split finish!")


# function
getleadSNP = function(data ,binsize,key,maxVal){
  ## 先把有用的数据提取出来
  data1 = data[,c(2,3,5)]
  ## 筛选染色体
  tmp1 = data.frame(filter(data1,data1[,1] == key))
  ## 划分bin
  bin = seq(binsize,maxVal,by = binsize)
  tmp2 = data.frame(key = key,
                    bin = bin,
                    pvalue = 1,
                    Pos = 0)

  for (i in 1:length(bin)) {
    x = tmp1 %>%
      filter(pos > (bin[i] - binsize) & pos < bin[i]) %>%
      filter(P == min(P)) %>%
      select(pos,P)
    if (nrow(x) == 0) {
      tmp2[i,3] = tmp2[i,3]
      tmp2[i,4] = tmp2[i,4]
    } else if(nrow(x) > 1){
      x = x[1,]
      tmp2[i,3] =  as.numeric(x$P)
      tmp2[i,4] = as.numeric(x$pos)
    } else if(nrow(x) == 1) {
      tmp2[i,3] =  as.numeric(x$P)
      tmp2[i,4] = as.numeric(x$pos)
    }}
  # tmp2 = furrr::future_map2_dfr(.x = bin,.y = length(bin),.f = function(.x,.y) {
  #   bin_tmp = .x
  #   i_tmp = .y
  #   x = tmp1 %>% 
  #     filter(pos > (bin_tmp - binsize) & pos < bin_tmp) %>% 
  #     filter(P == min(P)) %>% 
  #     select(pos,P)
  #   if (nrow(x) == 0) {
  #     tmp2[i_tmp,3] = tmp2[i_tmp,3]
  #     tmp2[i_tmp,4] = tmp2[i_tmp,4]
  #   } else if(nrow(x) > 1){
  #     x = x[1,]
  #     tmp2[i_tmp,3] =  as.numeric(x$P)
  #     tmp2[i_tmp,4] = as.numeric(x$pos)
  #   } else if(nrow(x) == 1) {
  #     tmp2[i_tmp,3] =  as.numeric(x$P)
  #     tmp2[i_tmp,4] = as.numeric(x$pos)
  #   }
  #   return(tmp2)
  # })
  # i = length(bin)
  tmp2[i+1,1] = key
  tmp2[i+1,2] = maxVal
  tmp2[i+1,3] = as.numeric((filter(tmp1,tmp1[,2]>bin[i])[,-1]%>%filter(P == min(P)))[2])
  tmp2[i+1,4] = as.numeric((filter(tmp1,tmp1[,2]>bin[i])[,-1]%>%filter(P == min(P)))[1])
  tmp2 %>% filter(pvalue != 1) %>%
    rename(start = bin) %>%
    rename(chr = key) %>%
    mutate(metaID = unique(data[,1])) %>%
    mutate(end = start + binsize) %>%
    select(metaID,chr,Pos,start,end,pvalue)-> tmp3
  return(tmp3)
}


# step2 -------------------------------------------------------------------
message("Step2. Analysis lead SNP. ...")
batch_get_lead = function(meta.list) {
  p <- progressor(steps = length(meta.list))
  step2_out = furrr::future_map_dfr(.x = meta.list,.f = function(.x) {
    p()
    Sys.sleep(0.001)
    tmp_x = getleadSNP(
      data = .x,
      binsize = binsize,
      key = key,
      maxVal = maxVal)
    return(tmp_x)
  })
  return(step2_out)
}

with_progress({
  out = batch_get_lead(meta.list = meta.list)
})

message("Step2. done! ")

write.table(out,paste(key,"_",binsize,".lead.xls",sep = ""),
            row.names = F,
            col.names = T,
            sep = "\t",
            quote = F)
