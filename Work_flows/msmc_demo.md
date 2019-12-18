# MSMC算法推测群体历史

> 参考[MSMC官方文档](https://github.com/stschiff/msmc/blob/master/guide.md)

> 计算时一般选取平均深度较高且亲缘关系较远的个体代表群体，选择2-8个单倍型

## 获取每个个体对于参考基因组的深度信息(分染色体)

```sh
samtools depth -r $chr <i$sample.bam> | awk '{sum += $3} END {print sum / NR}' > 01.depth/$sample/$sample.$chr.depth.txt
```

## 准备生成输入文件需要的VCF文件

### 使用Samtools生成vcf文件 (可以使用全部个体提高phase精确度)

```sh
samtools mpileup -q 20 -Q 20 -C 50 -u -r $chr -f $reference $sample1.bam $sample2.bam ... | bcftools call -c -V indels | gzip -c > 02.vcf/$pop.$chr.vcf.gz
```

### 使用[Shapeit2](http://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.html#readaware)对VCF文件进行Phase

#### 生成每条染色体的bam list文件

文件格式为：

```
sample1\tbam1\tchr1
sample2\tbam2\tchr1
...
```

## 使用extractPIRs进行基因型信息读取(分染色体)

```sh
extractPIRs --bam $pop.$chr.bamlist --vcf 02.vcf/$pop.$chr.vcf.gz --out 03.extractPIRs/$pop.$chr.PIRsList --base-quality 20 --read-quality 20

```

#### 使用shapeit进行分型

```sh
shapeit -assemble --input-vcf 02.vcf/$pop.$chr.vcf.gz --input-pir 03.extractPIRs/$pop.$chr.PIRsList -O 04.assemble/$pop.$chr

shapeit -convert --input-haps 04.assemble/$pop.$chr --output-vcf 05.phased/$pop.$chr.phased.vcf.gz
```

### 合并Phase和原始的基因型信息(Phased基因型优先)

>编写脚本，得到06.final.vcf/pop.chr.final.vcf.gz


### 将合并得到的文件按照个体分开

>编写脚本，得到07.split.vcf/\$sample/\$sample.\$chr.final.vcf.gz


## 生成参考基因组的Mask bed参考文件

>参考[SNPable文档](http://lh3lh3.users.sourceforge.net/snpable.shtml)

### 将Fasta文件转换为Fastq文件

```sh
seqbility-20091110/splitfa ../Omu.final.fixname.assembly.flt.2k.fa  35 | split -l 20000000
```

### 将这些fastq文件分别比对到参考基因组

```sh
bwa aln -t 30 -R 1000000 -O 3 -E 3 01.Reads/xaa | bwa samse -f 02.sam/xaa.sam $reference  - 01.Reads/xaa
```

### 合并sam文件，注意只保留一个sam文件头

```sh
cat 02.sam/xaa.sam > $pop.cat.sam
cat 02.sam/xab.sam | grep -v "@" >> $pop.cat.sam
```

### 转换结果文件的格式

```sh
cat $pop.cat.sam | gen_raw_mask.pl > rawMask_35.fa  
gen_mask -l 35 -r 0.5 rawMask_35.fa > mask_35_50.fa  
```

### 生成mask bed文件

修改 脚本 [msmc-tools/makeMappabilityMask.py](https://github.com/stschiff/msmc-tools/blob/master/makeMappabilityMask.py)内容，运行并输出不同染色体的mask bed文件

## 使用脚本[msmc-tools/bamCaller.py](https://github.com/stschiff/msmc-tools/blob/master/bamCaller.py)生成代表群体的个体的输入VCF文件和mask bed文件

(填入之前计算的深度信息)

```sh
zcat 07.split.vcf/$sample/$sample.$chr.final.vcf.gz | bamCaller.py bamCaller.py <mean_cov> 07.input.mask.bed/$sample.$chr.mask.bed.gz | gzip -c > 08.input.vcf/$sample.$chr.vcf.gz
```

## 生成MSMC的输入文件，使用[msmc-tools/generate_multihetsep.py](https://github.com/stschiff/msmc-tools/blob/master/generate_multihetsep.py)

需要用几个单倍型计算就导入几个单倍型，下图是四个单倍型的情况

```sh
generate_multihetsep.py --mask=covered_sites_sample1_chr1.bed.txt.gz  --mask=covered_sites_sample2_chr1.bed.txt.gz --mask=mappability_mask_chr1.bed.txt.gz sample1_chr1.vcf.gz sample2_chr1.vcf.gz
```
