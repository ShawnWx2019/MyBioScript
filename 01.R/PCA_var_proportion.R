########################################################
#             Prj: EMMAX Downstream analysis
#             Assignment: emmax-pca
#             Author: Shawn Wang
#             Date: Tue Apr 18
#             Location: HENU
#########################################################
#

# Prepare  ----------------------------------------------------------
TEST = "FALSE"
options(stringsAsFactors = F)
options(warn = -1)
suppressMessages(if (!require('getopt')) install.packages('getopt'))
suppressMessages(if (!require('crayon')) install.packages('crayon'))
suppressMessages(if (!require('parallel')) install.packages('parallel'))
# Args ------------------------------------------------------------------
##> crayon
msg_yes = green$bold$italic
msg_no = red$bold$italic
msg_run = blue$bold$italic$underline
msg_warning = yellow$bold$italic
message(msg_yes(
  paste0("\n#=========================================================#\n",
         "#        Prj: EMMAX-mate ver 0.0.1\n",
         "#        Assignment: PCA analysis \n",
         "#        Author: Shawn Wang <shawnwang2016@126.com>\n",
         "#        Date: Wed 19 Apr, 2023\n",
         "#=========================================================#\n\n"
  )
))
##> getopt
command=matrix(c(
  'help', 'h', 0, 'logic', 'help information',
  'prefix', 'p', 1, 'character', 'Prefix of plink file. ',
  'thread', 't', 2, 'numeric','Threads used for analysis',
  'K', 'k', 2, 'numeric','Number of k'
),byrow = T, ncol = 5)
args = getopt(command)

##> help information
if (!is.null(args$help)) {
  message(msg_yes(paste(getopt(command, usage = T), "\n")))
  q(status=1)
}

##> default value
if (is.null(args$prefix)){
  message(msg_no("Need plink files! please read help carefully!"))
  message(msg_yes(paste(getopt(command, usage = T), "\n")))
  q(status = 1)
}
if (is.null(args$thread)){
  message(msg_warning("Use all threads!"))
  args$thread = parallel::detectCores()
}
if (is.null(args$K)){
  message(msg_warning("Use default K number: K = 30 !"))
  args$K = 30
}
# library for data cleaning and visualize ---------------------------------
suppressMessages(if (!require('devtools')) install.packages('devtools'))
suppressMessages(if (!require('tidyverse')) install.packages('tidyverse'))
suppressMessages(if (!require('gdsfmt')) install_github("zhengxwen/gdsfmt"))
suppressMessages(if (!require('SNPRelate')) install_github("zhengxwen/SNPRelate"))

if(TEST == "TRUE") {
  prefix = "Gh_383"
  thread = parallel::detectCores()
  K = 30
} else {
  prefix = args$prefix
  thread = args$thread
  K = args$K %>% as.numeric
}

# 输入 PLINK 文件路径
bed.fn <- paste0(prefix,".bed")
fam.fn <- paste0(prefix,".fam")
bim.fn <- paste0(prefix,".bim")

message(msg_run(paste0(
  "Start running ..."
)))
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))
message(msg_yes("Step1 running PCA analysis"))
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))

# 将 PLINK 文件转为 GDS 文件
snpgdsBED2GDS(bed.fn, fam.fn, bim.fn, "test.gds")

# 读取 GDS 文件
genofile <- snpgdsOpen("test.gds")

# 根据 LD 过滤 SNPs，阈值根据需要设定
set.seed(1000)
snpset <- snpgdsLDpruning(genofile, ld.threshold=0.2)

# 选择 SNP pruning 后要保留的 SNP
snpset.id <- unlist(unname(snpset))

# 计算 PCA，num.thread 是并行的线程数
pca <- snpgdsPCA(genofile, snp.id=snpset.id, num.thread=thread)

# 以百分比形式输出 variance proportion
print(pca$varprop*100)
# 绘制前 30 个主成分的碎石图
# from shiyanhe and zhaozhuji.net
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))
message(msg_yes("Step2 Draw scree plot"))
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))
scree_plot <- 
	qplot(x = 1:K, y = (pca$varprop[1:K]), col = "red", xlab = "PC", ylab = "Proportion of explained variance") + 
	  geom_line() + guides(colour = FALSE) +
	    ggtitle(paste("Scree Plot - K =", K))+
	      theme_bw()+
	        theme(
		          axis.title = element_text(size = 12,colour = 'black'),
			  axis.text.x = element_text(size = 12,colour = 'black')
			   #   panel.border = element_line(size = 1,colour = 'black')
			        
		)
ggsave(plot = scree_plot,filename = paste0(prefix,"_screeplot.png"),width = 12,height = 9)
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))
message(msg_yes("Step3 Export pca eigenvec in plink format"))
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))

pca_tbl = pca$eigenvect %>% 
			as.data.frame %>% 
			setNames(paste0("PCA",c(1:ncol(.))))

			

write.table(x = pca_tbl,file = paste0(prefix,"_pca_eigenvec.txt"),row.names = F,sep = " ",col.names = F,quote = F)

message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))
message(msg_yes("Finish!"))
message(msg_yes("\n-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-·-\n"))
