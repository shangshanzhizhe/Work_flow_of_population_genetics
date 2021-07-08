# 结构变异检测

## 基于二代测序数据的结构变异检测

### Delly2

#### 对每个个体Call SV

```
delly call -g $reference  -o $name.bcf $name.bam
```

#### 合并所有个体产生的SV

```
delly merge -o all.sites.bcf $name1.bcf $name2.bcf $name3.bcf ...
```

#### 对所有的位点每个个体call genotype

```
delly call -g $reference -v all.sites.bcf -o $name1.geno.bcf $name1.bam
```

#### 如果使用Delly的结果，合并后转为vcf格式

```
bcftools merge -m id -O b -o merge.final.bcf $name1.geno.bcf $name2.geno.bcf $name3.geno.bcf ...
```

#### 要合并多个软件的结果，直接将个体bcf转为vcf格式

```
bcftools view $name1.bcf > $name1.vcf
```

### Lumpy

> 此处建议使用整合后的流程Smoove，可以根据样本情况选择Lumpy的参数，并去除重复序列的区域

#### 对每个个体Call SV

```
smoove call --outdir results-smoove/ --name $sample --fasta $reference -p 1 --genotype $name1.bam
```

#### 合并所有个体的VCF结果

```
smoove merge --name merged -f $reference --outdir ./ results-smoove/*.genotyped.vcf.gz
```

#### 对每个位点的所有个体Call Genotype

```
smoove genotype -d -x -p 1 --name $name1-joint --outdir results-genotped/ --fasta $reference --vcf merged.sites.vcf.gz $name1.bam
```

#### 如果使用Smoove的结果，合并所有个体的VCF

```
smoove paste --name $finalName results-genotyped/*.vcf.gz
```

#### 要合并多个软件的结果，解压个体的VCF即可

```
for file in results-genotyped/$.vcf.gz; do gunzip $file; done
```

### Manta

#### 对全部个体Call SV

```
${MANTA_INSTALL_PATH}/bin/configManta.py --bam $name1.bam --bam $name2.bam --bam $name3.bam ... --referenceFasta $reference --runDir Manta_dir
```

#### 编写脚本按照个体对VCF进行拆分或VCFtools

```
for $sample in {$samples}; do echo "$sample" > keep.list; vcftools --vcf manta.out.vcf --keep keep.list --recode --recode-INFO-all --mac 1 --out $sample.vcf
```

### 合并和过滤

####  每个个体合并三个方法得到的SV

```
for $sample in {$samples}; do echo "$sample.lumpy.vcf\n$sample.delly.vcf\n$sample.manta.vcf" > sample.list

SURVIVOR merge sample.list 1000 2 1 1 0 50 $sample.all.vcf
```

#### 过滤比对深度低的SV假阳性区域

```
samtools view -H $name.bam > $name.lowMQ.sam; samtools view 00.bam.files/DYGZ18123.realn.bam | awk '$5<5 {print $0}' >> $name.lowMQ.sam; samtools view -S -b -h $name.lowMQ.sam > $name.lowMQ.bam; rm -rf $name.lowMQ.sam; samtools depth $name.lowMQ.bam > $name.lowMQ.cov; SURVIVOR bincov $name.lowMQ.cov 10 2 > $name.lowMQ.bed

vcftools --vcf $sample.all.vcf --exclude-bed $name.lowMQ.bed --recode --recode-INFO-all --out $sample.final
```

#### 编写脚本删除多余的个体genotype信息

#### 使用SURVIVOR合并全部个体

