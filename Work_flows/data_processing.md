# 生信数据分析中常用Tips

按照样本切分VCF文件
```sh
for file in *.vcf*; do
  for sample in `bcftools view -h $file | grep "^#CHROM" | cut -f10-`; do
    bcftools view -c1 -Oz -s $sample -o ${file/.vcf*/.$sample.vcf.gz} $file
  done
done
```
按照区域切分VCF文件：tabix远比vcftools快
```
zcat all.vcf.gz | grep "^#" > vcf.header
tabix all.vcf.gz Chr1:1-1000 | cat vcf.header - > Chr1-1-1000.vcf.gz
```
生成基因组上的window bed文件
```
bedtools makewindows -g genome.chr.ln -w 100000 > 100K.genome.bed
```