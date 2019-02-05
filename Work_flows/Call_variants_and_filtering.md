# 获得遗传变异信息以及质量控制
## 获得遗传变异信息
### 将BAM文件转换成GVCF格式文件
```
java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R reference.fa -I 03.realign/sample.realn.bam -nct 15 -ERC GVCF -o 01.gvcf/sample.gvcf.gz -variant_index_type LINEAR -variant_index_parameter 128000
```
### 将GVCF格式文件转换为VCF文件 （合并多个个体的结果）
```
java -jar GenomeAnalysisTK.jar -T GenotypeGVCFs -R reference.fa -V sample1.gvcf.gz -V sample2.gvcf.gz -V (...) -o Pop.vcf.gz
```
### 将得到的遗传变异按照类型(SNP, INDEL)从VCF文件中分开
SNP
```
java -jar GenomeAnalysisTK.jar  -T SelectVariants -R reference.fa -V Pop.vcf.gz -selectType SNP -o Pop.SNP.vcf.gz
```
INDEL
```
java -jar GenomeAnalysisTK.jar  -T SelectVariants -R reference.fa -V Pop.vcf.gz -selectType INDEL -o Pop.INDEL.vcf.gz
```
## 遗传变异信息的质量控制(主要是SNP准确性)
### 利用GATK软件的Hard Filter算法进行初步过滤
SNP
```
/usr/bin/java -jar /home/share/users/yangyongzhi2012/tools/GATK/GenomeAnalysisTK.jar -T VariantFiltration -R reference.fa -V Pop.SNP.vcf.gz  --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0"  --filterName "my_snp_filter" -o Pop.HDflt.SNP.vcf.gz
```
INDEL
```
java -jar GenomeAnalysisTK.jar -T VariantFiltration -R reference.fa -V Pop.INDEL.vcf.gz --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" --filterName "my_indel_filter" -o Pop.HDflt.INDEL.vcf.gz
```
#### 使用脚本过滤掉不符合条件的SNP和INDEL位点 
>脚本可以同时过滤multi-alternative的SNP位点
##### [remove.hdfilter.pl](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Scripts/remove.hdfilter.pl)
SNP
```
perl remove.hdfilter.pl --input Pop.HDflt.SNP.vcf.gz --out Pop.HDflted.SNP.vcf.gz --type SNP --marker my_snp_filter
```
INDEL
```
perl remove.hdfilter.pl --input Pop.HDflt.INDEL.vcf.gz --out Pop.HDflted.INDEL.vcf.gz --type INDEL --marker my_indel_filter
```
#### 编写脚本完成如下条件的过滤，提高SNP的准确率
>使用的条件是经验条件，可以自行调整
- 深度：过滤深度大于个体平均深度2倍或小于三分之一的为点
- 质量: 过滤质量值(QUAL)小于20的位点
- 哈迪温伯格平衡: 过滤统一群体哈迪温伯格统计P_HWE<0.01的位点
- 位点频率：过滤在同一群体中位点频率小于0.2(按照个体数量确定)的位点
- 重复序列：过滤存在于重复序列区间内的位点(少见)
###### 哈迪温伯格平衡统计
使用[VCFtools](http://vcftools.sourceforge.net/)
```
vcftools --gzvcf IN.vcf.gz --keep Pop.list --hardy --out Pop.hardy
```

