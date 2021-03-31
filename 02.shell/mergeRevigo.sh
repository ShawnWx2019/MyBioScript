while read id
do
	tmp1=$(echo $id | cut -d" " -f 1)
	tmp2=$(echo $id | cut -d" " -f 2)

	Rscript ~/02.MyScript/BioScript/01.R/Rjoin.R -m inner -x $tmp1 -y $tmp2 -k "GO_ID"
done<$1