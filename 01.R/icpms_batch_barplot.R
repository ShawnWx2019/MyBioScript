## 导入excel的包
library(readxl)
## 导入数据清洗的包
library(tidyverse)
## 读取文件
xx <- read_xlsx("~/Downloads/Copy of ICP-MS nacl.xlsx",col_names = T)
## 数据透视 宽边长
xx %>% pivot_longer(
  -c(1,2),names_to = "ion",values_to = "value"
) %>% 
  mutate(
    ion_1 = str_split(ion,"_",n = 2,simplify = T)[,1],
    danwei = str_split(ion,"_",n = 2,simplify = T)[,2]
  )-> yy

## 设置时间和离子信息，用于写if嵌套循环
time = unique(yy$time)
ion = unique(yy$ion_1)

## 类似prism 的主题包
library(ggprism)

## 画单个图的代码
get_plot = function(df,time_t,ion_t) {
  ## 目标数据提取
  df %>% 
    filter(time == time_t & ion_1 == ion_t) ->new_df
  ## 数据对应的单位
  danwei = unique(new_df$danwei)
  ## 画图
  a = ggplot(new_df) +
    geom_bar(aes(x = treatment,y = value,fill = treatment),stat = "identity",width = 0.4) + theme_bw()+
    labs(y = paste("Relative content of",ion_t,danwei),x = "")+
    ggtitle(time_t)+
    ggprism::theme_prism()+theme(legend.position = "")
  ## 保存图片
  ggsave(plot = a,filename = paste0("~/15.PostDoc/02.Project/22.zx/",time_t,"-",ion_t,".png"),width = 8,height = 5,dpi = 300)
  return(a)
}

## 画第一个时期第一个离子测试下结果
get_plot(df = yy,time_t = time[1],ion_t = ion[1])

## 嵌套循环
for (i in 1:2) {
  # 第一层循环先循环时间
  for (j in 1:length(ion)) {
    # 第二层循环 循环离子
    get_plot(df = yy,time_t = time[i],ion_t = ion[j])
  }
  
}
