# 过滤序列文件和比对到参考基因组 Clean Reads and Mapping

>文中使用$符号表示作为参数的文件名，选项等内容
>文件和文件夹名称并不唯一指定，文中的文件夹和文件名称一般先后对应，使用时后缀一般按照参考命令行不变

## 过滤序列文件 Clean Reads

>以下三中方法选择一种

### 脚本过滤 Use scripts
[PairEndMultyReadsQualityFilter.pl](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Scripts/PairEndMultyReadsQualityFilter.pl)

```sh
perl 01.PairEndMultyReadsQualityFilter.pl $prefix $fastq1 $fastq2
```

### 使用Fastp进行过滤 Clean with [Fastp](https://github.com/OpenGene/fastp)

### 使用scythe和sickle进行过滤 Clean with [Scythe](https://github.com/vsbuffalo/scythe) and [Sickle](https://github.com/najoshi/sickle)

>流程较新，笔者推荐

## 将reads比对到参考基因组 Mapping Reads to the reference geome

### 为参考基因组建立索引 Build index for reference genome

>分别使用[bwa](https://github.com/lh3/bwa), [samtools](https://github.com/samtools/samtools), [picard](https://broadinstitute.github.io/picard/)建立索引以便后续流程使用

```sh
bwa index ref.fasta
samtools faidx ref.fasta
java -jar /home/share/software/picard/picard-tools-1.129/picard.jar CreateSequenceDictionary REFERENCE=ref.fasta OUTPUT=ref.dict
```

### 初次比对：使用BWA软件MEM模块，默认参数(双端测序) First mapping: Use the BWA MEM; default parameters (Pairwise sequenced file)

```sh
bwa mem -t 30 -R '@RG\tID:$samplename\tPL:illumina\tPU:illumina\tLB:$samplename\tSM:$samplename' ref.fasta sample.1.fq.gz sample.2.fq.gz | samtools sort -O bam -T /tmp/sample -o 01.bwa/sample.sort.bam
```

### 合并有多段序列的个体样品BAM文件 Merge the BAM files from different sequencing cell belongs to same sample

```sh
samtools merge sample.sort.bam sample.L1.bam sample.L2.bam ...
```

### 去除重复的比对序列 Remove the duplicated Reads

```sh
java -Xmx10g -jar picard.jar MarkDuplicates INPUT=01.bwa/sample.sort.bam OUTPUT=02.rmdup/sample.rmdup.bam METRICS_FILE=02.rmdup/sample.dup.txt REMOVE_DUPLICATES=true ; samtools index 02.rmdup/sample.rmdup.bam
```

>使用[GATK4](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/gatk4_workflow.md)可以跳过INDEL重新比对的部分

#### 获得INDEL的区间: 使用[GATK](https://software.broadinstitute.org/gatk/) Get intervals of INDEL with GATK

```sh
java -jar GenomeAnalysisTK.jar -nt 30 -R ref.fasta -T RealignerTargetCreator -o 03.realign/sample.realn.intervals -I 02.rehead/sample.rmdup.bam 2>03.realign/sample.realn.intervals.log
```

#### 对这些区间重新比对 Realign on the INDEL intervals

```sh
java -jar GenomeAnalysisTK.jar -R ref.fa -T IndelRealigner -targetIntervals 03.realign/sample.realn.intervals -o 03.realign/sample.realn.bam -I 2.rmdup/sample.rmdup.bam 2>03.realign/sample.realn.bam.log
```

