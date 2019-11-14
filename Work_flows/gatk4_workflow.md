# GATK4 获取遗传变异信息的命令行

## 将bam文件转换为gvcf格式

```
gatk --java-options "-Xmx20g" HaplotypeCaller -R $ref -I $bam -O $name.g.vcf.gz --emit-ref-confidence GVCF
```

## 使用gvcf文件生成vcf格式的变异信息
```
gatk --java-options "-Xmx4g" GenotypeGVCFs -R $ref -V $name.g.vcf.gz -O $name.vcf.gz
```

## 分别获得SNP和INDEL信息
### SNP
```
gatk --java-options "-Xmx4g" SelectVariants -R $ref -V $name.vcf.gz -select-type SNP -O $name.SNP.vcf.gz
```
### INDEL
```
gatk --java-options "-Xmx4g" SelectVariants -R $ref -V $name.vcf.gz -select-type INDEL -O $name.INDEL.vcf.gz
```

## 过滤遗传信息 Hard Filter

### SNP

```
gatk --java-options "-Xmx4g" VariantFiltration -R $ref -V $name.SNP.vcf.gz --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 30.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filter-name "my_snp_filter" -O $name.filter.vcf.gz
```

### INDEL

```
gatk --java-options "-Xmx4g" VariantFiltration -R $ref -V $name.INDEL.vcf.gz -O $name.INDEL.filter.vcf.gz --filter-expression "QUAL < 50 || QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || DP < 15" --filter-name "my_indel_filter"
```