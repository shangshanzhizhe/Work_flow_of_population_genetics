# 三代测序Nanopore数据检测甲基化位点

> 参考Nanopolish官方文档

## 数据预处理

```sh
cat fastq_pass/*.fastq > sample.fastq
nanopolish index -d fast5_pass/ sample.fastq
```

## 将reads比对到参考基因组

```sh
minimap2 -a -x map-ont reference.fasta output.fastq | samtools sort -T tmp -o output.sorted.bam
samtools index output.sorted.bam
```

## 甲基化鉴定

```sh
nanopolish call-methylation -t 8 -r output.fastq -b output.sorted.bam -g reference.fasta > methylation_calls.tsv
```
