##############################################
#	Prj: Enrichment
#	Assignment: revigo
#	Author: Shawn Wang
#	Date: Apr 1, 2021
##############################################

## step1
source ~/.bash_alias

while read id
do
    file=$(basename $id ) 
    sample=${file%%.*} 
    echo "processing:" $sample 
    ## extract GO_ID and Pvalue
    revigofilter $id $sample
    ## run revigo
    runRevigo revigo${sample}.txt ${sample}
    ## merge result
    Rscript ~/02.MyScript/BioScript/01.R/reviMerge.R bp.${sample}.csv $id $sample
done<$1

