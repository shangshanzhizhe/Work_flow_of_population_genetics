# 比较转录组学分析

## 序列比对

### 原始数据质量控制

使用fastq

###  建立基因组索引

```sh
hisat2-build -c reference.fasta reference
```

### 比对和对BAM文件排序

```sh
hisat2 -p 8 --dta -x <path_to_reference> -1 sample.1.fastq.gz -2 sample.2.fastq.gz | samtools sort -@ 8 -o sample.sorted.bam; samtools index sample.sorted.bam
```

### Stringtie 转录本定量

#### 没有参考基因组注释的情况

```sh
stringtie -p 8 -o sample.gtf sample.sorted.bam
```

#### 