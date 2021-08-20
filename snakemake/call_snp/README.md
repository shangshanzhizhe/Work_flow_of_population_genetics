# SNP calling 的snakemake流程 (不能用！)

## 依赖环境和软件

加粗为固定版本，其余版本为conda安装时使用的版本，经过测试没有问题

- **Python** == 3.6
- Snakemake >= 5.24.1
- fastq == 0.20.1
- fastq utils == 0.25.1
- bwa == 0.7.17
- samtools == 1.13

### Conda 安装依赖环境

```
conda env create --name snakemake-tutorial --file environment.yaml
```

### 
