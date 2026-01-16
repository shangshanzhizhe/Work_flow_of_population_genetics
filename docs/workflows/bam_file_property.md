# 群体遗传分析中变异特征等计算

## 平均测序深度(粗略)

计算方法：碱基数除以基因组大小
### 使用[seqkit](https://github.com/shenwei356/seqkit)计算碱基数,可以批量（SeqKit也可以用作常用的fasta/q处理）
```sh
seqkit stats --all $fastq_file
```

## 平均比对深度(精确)

### 使用[mosdepth](https://github.com/brentp/mosdepth)
```sh
mosdepth $prefix $bam_file
```

## 比对率，Reads数等信息

```sh
samtools flagstat $bam_file
```

## SNV的个体缺失率
```sh
vcftools --vcf $vcf_file --missing-indv
```
生成的文件中包含每个个体的缺失率