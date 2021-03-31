#!/bin/bash
##################################################
#       Project:  TBtools Enrichment
#       Date: Jun 28,2020
#       Author: Shawn Wang
##################################################
## create a dir to store results
mkdir 01.GOEnrich 02.KEGGEnrich
source ~/.bash_alias
## go enrichment
while read id 
do
	file=$(echo $id| cut -d" " -f 1)
	cp ${file} 01.GOEnrich/${file}
	cd 01.GOEnrich
	TBgo --oboFile /Users/shawnwang/02.MyScript/OneStepWGCNA/02.TBtools/go-basic.obo --gene2GoFile /Users/shawnwang/02.MyScript/OneStepWGCNA/02.TBtools/CRI.TM1.V2.TBtools.gene2go --selectionSetFiles $file
	rm ${file}
	cd ../
done<$1
cd 01.GOEnrich 
mkdir 01.final 02.detail
mv *final.xls* 01.final 
mv *.xls 02.detail
cd 01.final
## GO plot
GOplot
echo "GO富集分析完成"
cd ../../
## kegg enrichment
while read id 
do
	file=$(echo $id| cut -d" " -f 1)
	cp ${file} 02.KEGGEnrich/${file}
	cd 02.KEGGEnrich
	TBkegg --inKegRef /Users/shawnwang/02.MyScript/OneStepWGCNA/02.TBtools/TBtools.Plants.KEGG.Backend --Kannotation /Users/shawnwang/02.MyScript/OneStepWGCNA/02.TBtools/CRI.TM1.V2TBtools.gene2ko --selectedSet $file --outFile $file
	rm ${file}
	cd ../
done<$1
cd 02.KEGGEnrich
mkdir 01.final 02.detail
mv *.final* 01.final
cd 01.final
## KEGG plot
KEGGplot
cd ../../
echo "KEGG富集分析完成"
