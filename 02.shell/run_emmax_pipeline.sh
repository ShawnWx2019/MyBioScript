#!/bin/bash

############################################################
#       Prj: Emmax pipeline
#       Assignment: main pipeline
#       Author: Shawn Wang
#       Date: Apr 26 2023
############################################################

## getopts
set -e ## 报错打断，防止一直错下去

start_time=$(date +%s)

## 帮助内容
func(){
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mEmmax pipeline . From raw to Manhattan plot\033[0m"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mUsage:\033[0m"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[35mrun_emmax_pipline \ \n \033[31m-t [tpedf_prefix] \ \n \033[31m-o [out_prefix] \ \n \033[31m-p [phenof] \ \n \033[31m-k [kinf] \ \n \033[31m-a [anno] \ \n \033[33m-c [covf] (option) \ \n \033[33m-i [img_type] (option) \ \n \033[33m-s [point_size] (option) \ \n \033[33m-w [point_color] (option) \ \n\033[0m"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mAuthor\033[0m Shawn Wang (shawnwang2016@126.com)"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mDate\033[0m Web Apr 26, 2023"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mVersion\033[0m V.0.0.0.99 beta"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mDescription:\033[0m"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    echo -e "\033[32mRequired parameters:\n\033[0m"
    echo -e "\033[31m[-t]:tpedf_prefix\033[0m,   prefix for tped/tfam files\033[0m"
    echo -e "\033[31m[-o]:out_prefix\033[0m,  output file name prefix\033[0m"
    echo -e "\033[31m[-p]:phenof\033[0m,  3-column phenotype file with FAMID, INDID at the first two colmns, in the same order of .tfam file.\033[0m"
    echo -e "\033[31m[-k]:kinf\033[0m,  n * n matrix containing kinship values in the individual order consistent to [tpedf].tfam file. [tpedf].kinf will be used if not specified.\033[0m"
    echo -e "\033[31m[-a]:anno\033[0m,  SNP annotation file by vep.\n\033[0m"
    echo -e "\033[32mOptional parameters:\n\033[0m"
    echo -e "\033[33m[-c]:covf\033[0m,  multi-column covariate file with FAMID, INDID at the first two colmns, in the same order of .tfam fileOptional parameters.\033[0m"
    echo -e "\033[33m[-i]:img_type\033[0m,  output img file type, jpg or pdf.\033[0m"
    echo -e "\033[33m[-s]:point_size\033[0m,  point size of manhattan plot, default: cut_off 0_4_6 ==> 0.3_0.5_0.5.\033[0m"
    echo -e "\033[33m[-w]:point_color\033[0m,  point color of manhattan plot, default: cut_off 4_6 ==> red_green.\033[0m"
    echo -e "\033[32m\n-------------------------------\n\033[0m"
    exit -1
}
## 是否备份原始文件，如果不写-b默认不备份

## 设置各个参数
while getopts 'ht:o:p:k:a:c:i::s::w::' OPT;
do
    case $OPT in
        t) tpedf_prefix=`echo "$OPTARG"`;;
        o) out_prefix=`echo "$OPTARG"`;;
        p) phenof=`echo "$OPTARG"`;;
        k) kinf=`echo "$OPTARG"`;;
        a) anno=`echo "$OPTARG"`;;
        c) covf=`echo "$OPTARG"`;;
        i) img_type=`echo "$OPTARG"`;;
        s) point_size=`echo "$OPTARG"`;;
        w) point_color=`echo "$OPTARG"`;;
        h) func
           exit 1
           ;;
        ?) func
           exit 1
           ;;
    esac
done

