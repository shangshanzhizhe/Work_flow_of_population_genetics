# 使用SNP数据推断群体结构

## PCA 

### Plink

#### 转换vcf为plink格式的文件

```sh
vcftools --gzvcf $vcf --plink --out $vcf
```
#### 使用Plink进行PCA计算

```sh
plink --pca --file $vcf
```
最后生成两个文件：plink.eigenvec 和 plink.eigenval

plink.eigenvec 记录每个个体在不同主成分中的位置
plink.eigenval 记录每个主成分对数据的解释度
