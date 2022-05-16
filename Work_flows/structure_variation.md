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

#### 过滤低质量的结构变异

过滤掉标记为IMPRECISE和LowQual的结果

```sh
for file in *geno.bcf.vcf;  do python3 fillter.py $file; done
```

fillter.py:

```python3
#!/usr/bin/python3
import sys
import re

infile = sys.argv[1]
name = re.search(r'(.*)\.vcf',infile)[1]
outfile = name + '.filter.vcf'
o = open(outfile, 'w')
with open(infile, 'r') as f:
    for line in f:
        line = line.strip()
        if line.startswith('#'):
            # print(line)
            o.write(line + '\n')
            continue
        content = line.split()
        if content[6] != "PASS" or re.match(r'IMPRECISE', content[7]):
            continue
        # print(line)
        o.write(line + '\n')
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

#### 过滤低质量的结果

使用脚本过滤掉VCF文件第6列（QUAL）值为0的SV

### Manta

#### 对全部个体Call SV

```
${MANTA_INSTALL_PATH}/bin/configManta.py --bam $name1.bam --bam $name2.bam --bam $name3.bam ... --referenceFasta $reference --runDir Manta_dir
```

#### 过滤低质量的结果

基本同上，删除QUAL值低于20的结果


### 合并结构变异结果
> 在实际使用中，使用SURVIVOR合并的效果并不好，合并会导致有些SV的信息丢失（具体是哪些忘记了），首先要注意个体VCF文件中的个体名称要一致。考虑到SVIMMER和Graphtyper出自同一作者，兼容性可能较好。因此使用这两个软件。

####  合并全部软件的VCF结果文件

```sh
svimmer --threads 10 all.vcf.list LG01 LG02 LG03 LG04 <......> # 染色体名称
all.vcf.list
```
#### Genotyping

```sh
./graphtyper genotype_sv reference.fasta input.vcf.gz --sams=bam.list --region=LG01:start-end
```

很多软件是无法Genotype insertion的，可以换软件试试。类似的软件还有Paragraph。

#### 合并

使用VCFtools或者GATK合并每个染色体的VCF文件


#### 过滤

- 过滤VCF文件没有确定的标准，我一般使用VCFtools过滤掉群体中频率比较低的SV。
- SV的质量高低，主要取决于支持SV存在的Reads数量，越高越可靠，可以根据这个标准找到个性化的过滤方法。
- 此外Graphtyper也会给出对每个SV确定基因型时的可靠程度，我忘记了，可以阅读文档并根据该软件的标准进行过滤。
- 原来版本中的，SURVIVOR建议过滤比对深度比较低的基因组区域的SV，这个可以酌情使用。

> 过滤比对深度低的SV假阳性区域

```
samtools view -H $name.bam > $name.lowMQ.sam; samtools view 00.bam.files/$name.realn.bam | awk '$5<5 {print $0}' >> $name.lowMQ.sam; samtools view -S -b -h $name.lowMQ.sam > $name.lowMQ.bam; rm -rf $name.lowMQ.sam; samtools depth $name.lowMQ.bam > $name.lowMQ.cov; SURVIVOR bincov $name.lowMQ.cov 10 2 > $name.lowMQ.bed

vcftools --vcf $sample.all.vcf --exclude-bed $name.lowMQ.bed --recode --recode-INFO-all --out $sample.final
```
