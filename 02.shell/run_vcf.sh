chrom=(Chr1 Chr2 Chr3 Chr4 Chr5 Chr6 Chr7 Chr8 Chr9 Chr10 Mt Cp)
for i in ${chrom[@]}; do
    gatk HaplotypeCaller \
    -R /home/data/public/01.database/01.Database/01.genome_db/01.maize/03.B73_v2/gatk_index/B73_RefGen_v2.fa \
    -I ../dup/Sample_114_mark_dup.bam \
    -L $i \
    -O Sample_114.HC.${i}.vcf.gz
done && wait
merge_vcfs=""
for i in ${chrom[@]}; do
    merge_vcfs=${merge_vcfs}" -I Sample_114.HC.${i}.vcf.gz \\"\n
done && gatk MergeVcfs ${merge_vcfs} -O Sample_114.HC.vcf.gz


