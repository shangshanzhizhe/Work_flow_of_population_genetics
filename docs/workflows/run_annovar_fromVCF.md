# 使用Annovar注释VCF格式的变异位点

## 需要文件：
- 参考基因组的fa和gff3 (test.fa / test.gff3)
- 所需注释的vcf (test.vcf)
## 需要安装
- gff3ToGenePred (conda install -c bioconda gff3ToGenePred)
- annovar


### 1. 创建annovar注释库
```sh
gff3ToGenePred test.gff3 test_refGene.txt
retrieve_seq_from_fasta.pl --format refGene --seqfile test.fa test_refGene.txt --out test_refGeneMrna.fa

# 注意目录名要和上两步的输出前缀一致
mkdir test
mv test_refGene.txt test
mv test_refGeneMrna.fa test

cd test/
pwd (获取test的绝对路径)
#/home/weihan/test
```

### 2. 转换vcf为annovar输入格式，annovar自带脚本可以实现
```sh
convert2annovar.pl -format vcf4 test.vcf -outfile test.avinput --allsample --withfreq
```

### 3. 注释
```sh
annotate_variation.pl -out test -buildver test test.avinput /home/weihan/test/
# -buildver跟着建注释库时的前缀， 最后跟着注释库目录的绝对路径，顺序莫乱
```
- 运行完后会输出两个文件：**test.exonic_variant_function** 和 **test.variant_function**
- 两个文件为包含关系，exonic_variant_function中的位点在variant_function注释为exonic，在exonic_variant_function中其实是将这些外显子中的变异功能进行了细分，如同义/非同义突变，stopgain，stoploss等

### 4. 此处我分享一个我自己写的R脚本，将两个结果合并，方便整理查阅
```R
#!/usr/bin/Rscript
# args[1]: prefix of *exonic_variant_function and *variant_function

args <- commandArgs(T)
library(data.table)
library(stringr)
library(dplyr)

raw.avinput <- fread(paste0(args[1],".raw.avinput"), header = F)
ef <- fread(paste0(args[1],".exonic_variant_function"), header = F)
vf <- fread(paste0(args[1],".variant_function"), header = F)

vf.dt <- data.table(SNP = paste(vf$V3, vf$V4, sep = "_"), Chr = vf$V3, Pos = vf$V4, Type = vf$V1, Gene = vf$V2)
ef.dt <- data.table(LINE = as.integer(gsub(pattern = "line", replacement = "", x = ef$V1)), SNP = paste(ef$V4, ef$V5, sep = "_"), Chr = ef$V4, Pos = ef$V5, Type2 = ef$V2, Gene2 = ef$V3)

vf.dt$Type[ef.dt$LINE] <- ef.dt$Type2
vf.dt$Gene[ef.dt$LINE] <- ef.dt$Gene2


vf.dt$SNP <- paste(raw.avinput$V1, raw.avinput$V2, sep = "_")
vf.dt$Chr <- raw.avinput$V1
vf.dt$Pos <- raw.avinput$V2
fwrite(vf.dt, file = paste0(args[1],".annovar.res.txt"), quote = F, row.names = F, col.names = T, sep = "\t")
```
- 将此脚本存为MergeAnnovar.R
- Rscript MergeAnnovar.R test即可
- 输出test.annovar.res.txt
