# 使用SNP数据推断群体结构

## PCA 


2024.3 再次因为在老外的严谨拷问下发现PCA不考虑SNP过滤的时候的结果不准确。暂时不知道怎么改下面的流程，因为过滤不存在唯一标准。
但是一下是一些推荐阅读：
    
https://privefl.github.io/bigsnpr/articles/how-to-PCA.html

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7750941/

https://doi.org/10.1101/2021.04.11.439381


个人感觉看了上述内容以后，不建议用PCA的结果解释细致的群体结构和基因流等，除非你的研究是奔着群体结构去的。

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
