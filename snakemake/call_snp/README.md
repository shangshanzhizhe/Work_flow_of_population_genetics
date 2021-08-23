# SNP calling 的snakemake流程

> v1.0 只能使用基因组全长完成所有流程

## 依赖软件和环境

加粗为固定版本，其余版本为conda安装时使用的版本，经过测试没有问题

- **Python** == 3.6
- Snakemake >= 5.24.1
- fastq == 0.20.1
- fastq utils == 0.25.1
- bwa == 0.7.17
- samtools == 1.13
- gatk == 4.1.4.1
- snakemake-wrapper-utils==0.1.3

其他依赖环境在environment.yaml中

### Conda 安装依赖环境

```
conda env create-f environment.yaml
```

### 激活虚拟环境

```
conda activate snpcalling
```

### 建立如下所示的文件结构

```
[ 4.0K]  call_snp
    ├── [  236]  config.yaml
    ├── [  27K]  dag.svg
    ├── [ 7.4K]  enviroment.yaml
    ├── [ 4.0K]  raw_fastq
    │   ├── [ 1.2M]  E_rothschildi.1.fq.gz
    │   ├── [ 1.1M]  E_rothschildi.2.fq.gz
    │   ├── [ 1.1M]  E_rothschildi5.1.fq.gz
    │   └── [ 1.1M]  E_rothschildi5.2.fq.gz
    ├── [  423]  README.md
    ├── [ 4.0K]  reference
    │   └── [ 1.3G]  ref.fasta
    └── [ 7.0K]  Snakefile
```

### 修改config.yaml文件内容

```
samples:
    sample_name1: "dir/prefix1"
    sample_name2: "dir/prefix2"

reference: "reference/ref.fasta"

bwa_threads: 30
fastp_threads: 8

picard_path: "/somepath/picard.2.25.0.jar"
```
### 运行

```
snakemake --cores 10
```