while read id
do
	revigolist=$(echo $id | cut -d ' ' -f 1)
	raw=$(echo $id | cut -d ' ' -f 2)
	out=$(echo $id | cut -d ' ' -f 3)

	Rscript ~/02.MyScript/BioScript/01.R/reviMerge.R $revigolist $raw $out
done<$1