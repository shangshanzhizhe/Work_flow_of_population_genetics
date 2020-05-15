# Call_variants_and_filtering

> 获得遗传变异信息以及质量控制

## 获得遗传变异信息

### 将BAM文件转换成GVCF格式文件

```sh
java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R reference.fa -I 03.realign/sample.realn.bam -nct 15 -ERC GVCF -o 01.gvcf/sample.gvcf.gz -variant_index_type LINEAR -variant_index_parameter 128000
```

### 将GVCF格式文件转换为VCF文件 （合并多个个体的结果）

```sh
java -jar GenomeAnalysisTK.jar -T GenotypeGVCFs -R reference.fa -V sample1.gvcf.gz -V sample2.gvcf.gz -V (...) -o Pop.vcf.gz
```

### 将得到的遗传变异按照类型(SNP, INDEL)从VCF文件中分开

SNP

```sh
java -jar GenomeAnalysisTK.jar  -T SelectVariants -R reference.fa -V Pop.vcf.gz -selectType SNP -o Pop.SNP.vcf.gz
```

INDEL

```sh
java -jar GenomeAnalysisTK.jar  -T SelectVariants -R reference.fa -V Pop.vcf.gz -selectType INDEL -o Pop.INDEL.vcf.gz
```

## 遗传变异信息的质量控制(主要是SNP准确性)

### 利用GATK软件的Hard Filter算法进行初步过滤

SNP

```sh
/usr/bin/java -jar /home/share/users/yangyongzhi2012/tools/GATK/GenomeAnalysisTK.jar -T VariantFiltration -R reference.fa -V Pop.SNP.vcf.gz  --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0"  --filterName "my_snp_filter" -o Pop.HDflt.SNP.vcf.gz
```

INDEL

```sh
java -jar GenomeAnalysisTK.jar -T VariantFiltration -R reference.fa -V Pop.INDEL.vcf.gz --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filterName "my_indel_filter" -o Pop.HDflt.INDEL.vcf.gz
```

### 使用脚本过滤掉不符合条件的SNP和INDEL位点

> 脚本可以同时过滤multi-alternative的SNP位点 (对于二倍体)

### [remove.hdfilter.pl](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Scripts/remove.hdfilter.pl)

SNP

```sh
perl remove.hdfilter.pl --input Pop.HDflt.SNP.vcf.gz --out Pop.HDflted.SNP.vcf.gz --type SNP --marker my_snp_filter
```

INDEL

```sh
perl remove.hdfilter.pl --input Pop.HDflt.INDEL.vcf.gz --out Pop.HDflted.INDEL.vcf.gz --type INDEL --marker my_indel_filter
```

### vcffilter

```sh
vcffilter -f "DP > 10 & MQ > 30 & QD > 20" $vcf | gzip - > $vcf
```

### 编写脚本完成如下条件的过滤，提高SNP的准确率

> 参考网址：[http://www.ddocent.com/filtering/](http://www.ddocent.com/filtering/)

过滤条件根据实际情况确定

- INDEL附近: INDEL附近的位点不准确，删除位于INDEL位置周围5bp的SNP
- MAC/MAF: 最小的Minor Allele Frequency数量或者频率
  - 对应VCFtools : --mac --maf
- 深度: 过滤深度(DP)小于三分之一个体平均深度或大于两倍平均深度的Genotype
  - 对应VCFtools：--minDP --maxDP
- 质量: 过滤GQ值小于20的Genotype
  - 对应VCFtools：--minGQ
- 哈迪温伯格平衡: 过滤**同一群体**哈迪温伯格统计P_HWE<0.001的位点
  - 对应VCFtools：--hwe
- 位点频率：过滤在同一群体中支持Genotype小于20%(按照个体数量确定)的位点
  - 对应VCFtools：--max-missing
- 重复序列：过滤存在于重复序列区间内的位点，由于重复序列的比对深度和准确度都比较低，经过过滤一般不考虑重复序列，也可以借助基因组注释再次过滤