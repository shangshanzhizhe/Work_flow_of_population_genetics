# SNP calling 的snakemake流程

> v1.0 只能使用基因组全长完成所有流程

## 依赖软件和环境

- Python3
- picard

其他依赖环境在environment.yaml中

### Conda 安装依赖环境

```
conda env create -f environment.yaml
```

### 激活虚拟环境

```
conda activate snpcalling
```

## 建立如下所示的文件结构

示例如下：
```
[ 4.0K]  call_snp
    ├── config.yaml
    ├── enviroment.yaml
    ├── raw_fastq
    │   ├── prefix1.1.fq.gz
    │   ├── prefix1.2.fq.gz
    │   ├── prefix2.1.fq.gz
    │   └── prefix2.2.fq.gz
    ├── reference
    │   └── ref.fasta
    └── Snakefile
```

### 修改config.yaml文件内容

- 保持文件夹名称和文件后缀和默认一致
- 指定picard文件的位置
- 根据参考基因组大小，测序深度等经验来修改`--java-options`

## 运行

#### 本地运行

```
snakemake --cores 30
```

#### 使用slurm系统

1. 修改`cluster.yaml`文件内容
2. 修改`runSnakes.slurm`文件内容

```
sbatch runSnakes.slurm
```

### 注意

保持config文件和slurm提交中的cpu数、内存大小一致，防止任务中断

## LICENSE
MIT License
