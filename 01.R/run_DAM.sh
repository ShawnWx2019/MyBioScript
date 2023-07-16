while read id
do
	left=$(echo $id|cut -d"," -f 1)
	right=$(echo $id|cut -d"," -f 2)
	echo ${left} ${right}
	Rscript /Users/shawn/My_Repo/MyBioScript/01.R/run_DAM_analysis_v3.R  \
		--peakfile $2 \
		--group $3 \
		--meta_anno $4 \
		--kegg_db $5 \
		--left ${left} \
		--right ${right} \
		--VIP 1 \
		--pvalue 0.05 \
		--qvalue 1 \
		--log2fc 0.26 \
        	--test.method "t-test" \
        	--pls.method "pls-da"
done<$1
