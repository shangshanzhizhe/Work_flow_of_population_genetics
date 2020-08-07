# PSMC 估算群体历史

>PSMC 是使用单个个体的两条序列推断群体历史动态的方法，一般认为，测序深度大于10X的个体推算结果比较准确，在1000年内的结果不一定准确

## 将bam文件转换为fastq格式的一致性序列

```sh
samtools mpileup -C50 -uf ref.fa aln.bam | bcftools call -c - | vcfutils.pl vcf2fq -d $average_depth/3 -D $average_depth/3 -D 100 | gzip > diploid.fq.gz
```

## 将fastq文件转换为psmcfa格式

```sh
utils/fq2psmcfa -q20 diploid.fq.gz > diploid.psmcfa
```

## 使用psmc对每个个体进行100次bootstrap重复估算

```sh
for i in 1..100:
    psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o diploid.psmc diploid.psmcfa
done
```

或

```sh
seq 100 | xargs -i echo psmc -N25 -t15 -r5 -b -p "4+25*2+4+6" -o round-{}.psmc split.fa | sh
```

## 合并所有结果

```sh
cat roud-*.psmc > combined.psmc
```

## 画图

```sh
utils/psmc_plot.pl -pY50000 -u $mutation_rate -g $per_generation_time combined combined.psmc
```
