# GATK4 获取遗传变异信息的命令行

## 将bam文件转换为gvcf格式

```sh
gatk --java-options "-Xmx20g" HaplotypeCaller -R $ref -I $bam -O $name.g.vcf.gz --emit-ref-confidence GVCF
```

## 使用gvcf文件生成vcf格式的变异信息

> 第一种方法的计算资源占用极高，样本数量多时分染色体计算，gatk一般都有-L参数用来指定对象区域

### 先合并gvcf，再转换成vcf

#### CombineGVCFs

```sh
 gatk CombineGVCFs -R --variant Sample1.g.vcf.gz --variant Sample2.g.vcf.gz -O Merged.g.vcf.gz
```
#### GenotypeGVCFS

```sh
gatk --java-options "-Xmx4g" GenotypeGVCFs -R $ref -V Merged.g.vcf.gz -O Merged.vcf.gz
```
### 将gvcf存储为数据库

#### GenomicsDBImport

```sh
gatk GenomicsDBImport -V Sample1.g.vcf.gz -V Sample2.g.vcf.gz --genomicsdb-workspace-path my_database
```
#### GenotypeGVCFS
```sh
gatk GenotypeGVCFs  -R $ref -V gendb://my_database -G StandardAnnotation -newQual -O Merged.vcf.gz
```
## 分别获得SNP和INDEL信息

### SNP

```sh
gatk --java-options "-Xmx4g" SelectVariants -R $ref -V $name.vcf.gz -select-type SNP -O $name.SNP.vcf.gz
```

### INDEL

```sh
gatk --java-options "-Xmx4g" SelectVariants -R $ref -V $name.vcf.gz -select-type INDEL -O $name.INDEL.vcf.gz
```

## 过滤遗传信息 Hard Filter

### SNP

```sh
gatk --java-options "-Xmx4g" VariantFiltration -R $ref -V $name.SNP.vcf.gz --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 30.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filter-name "my_snp_filter" -O $name.filter.vcf.gz
```

### INDEL

```sh
gatk --java-options "-Xmx4g" VariantFiltration -R $ref -V $name.INDEL.vcf.gz -O $name.INDEL.filter.vcf.gz --filter-expression "QUAL < 50 || QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || DP < 15" --filter-name "my_indel_filter"
```
