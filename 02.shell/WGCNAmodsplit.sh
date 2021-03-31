#!/bin/bash
source ~/.bash_alias
set -e
## 提取模块做成配置文件
awk '{print $2}' $1 > tmp1 && cat tmp1 | sort | uniq > config && rm tmp1
## 删除表头
gsed -i '1d' config
## 按模块提取基因并命名
for i in `cat config`; do awk -v module=$i '{if($2 == module) print$1}' $1 > $i.tab;done
mkdir 03.enrich && cd 03.enrich && mv ../*.tab ./
## 制作配置文件并做富集分析
ls *.tab > config
TBenrich config &

