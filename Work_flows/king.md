# 使用KING软件推算个体间亲缘关系

>亲缘关系较近的个体在后续的计算中会导致误差，例如群体历史推算和模拟等，因此需要删除一些亲缘关系较近的个体

软件版本为KING 1.4

## 使用VCF作为输入文件，转换为plink的map格式

```sh
vcftools --gzvcf All.pop.SNP.vcf.gz --keep Pop.list --plink -out Pop # 分群体的情况
```

## 使用Plink生成需要的文件

```sh
plink --file Pop --make-bed --out Pop
```

## 使用KING计算亲缘关系(在独立的文件夹中)

```sh
king -b Pop.bed --fam Pop.fam --bim Pop.bim -m Pop.map --related
```

## 结果分类

### 在king.kin0文件中的Kinship列:

> Thanks to [@yuanyuan309](https://github.com/yuanyuan309)!

```text
(, 0.0442]  Unrelated

(0.0442, 0.0884]    3rd Degree Relationship

(0.0884, 0.1774]    2nd Degree Relationship

(0.1774, 0.354]     1st Degree Relationship

(0.354, )           Duplicated
```
