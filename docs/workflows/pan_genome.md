# 泛基因组组装和变异检测

个人认为这部分难以理解的方面在于，原先使用线性参考基因组进行变异鉴定，我们的惯性思维是在比对或者变异鉴定结束后找某个染色体的某个位置，而泛基因组中，reference实际上是基因组图中的路径（path）。例如：一个插入在图形基因组中会被表示为: reference: node1->node3; alter: node1->node2->node3. node1: A, node3: T, node2: ATTTCG. 这样，图形基因组中就可能包含多种复杂的结构变异，例如节点之间的连接方向，多条伸出路径等。

但是客观上，图形基因组确实比线性基因组包含更多的信息，以及可以表示更复杂的变异，只是目前处理这些信息的一揽子工具还比较少。话说回来，克服恐惧的最好办法就是面对恐惧。

## 准备工作
假设你已经有了多个基因组组装，我自己的相关文件是1个HiC挂载后的参考基因组和5个Contig水平的基因组。考虑到我初次处理图形基因组数据，我还是用比对的方法将Contig水平的基因组挂载到了Scaffold水平（和参考基因组一致）。

> 如果你的组装是单倍体基因组组装，务必使用单倍体组装

### Scaffolding contig-level genomes

我的参考基因组序列是30044_12，其他基因组也是数字编号。只保留了参考基因组中挂载后的“染色体”序列。

```sh
ragtag.py scaffold 30044_12.scaffold.only_chr.fasta 30044_10/30044_10.asm.bp.p_ctg.fasta -o 30044_10/ragtag_output -t 8
```

结果文件是`30044_10/ragtag_output/ragtag.scaffold.fasta`

出于对后续步骤的未知和谨慎，我向每个样本的基因组序列名称前添加了前缀，例如`30044_10.scaffold_1`。

## 构建图形基因组

构建图形基因组我使用的是cactus-pangenome workflow，流行的方法是minigraph，不过cactus就是整合了minigraph并对复杂的路径进行过滤和修剪，在其软件中表示为"full", "filter"和”clip“。我不敢说完全明白，所以请自己再研究研究。类似工具还有PGGB，太消耗资源，我没尝试。

输入文件：sample_info.txt
每个基因组只保留了染色体的序列，未挂载上的全部去掉了。

```txt
30044_10        /mnt/shared/scratch/szhang/projects/07.T_oceanicus_six_genomes/00.genome_sequences_fixed_file_control/30044_10/scaffold/30044_10.scaffold.fasta
30044_11        /mnt/shared/scratch/szhang/projects/07.T_oceanicus_six_genomes/00.genome_sequences_fixed_file_control/30044_11/scaffold/30044_11.scaffold.fasta
30044_12        /mnt/shared/scratch/szhang/projects/07.T_oceanicus_six_genomes/00.genome_sequences_fixed_file_control/30044_12/pseudo-chrom/30044_12.chr.fasta
30044_13        /mnt/shared/scratch/szhang/projects/07.T_oceanicus_six_genomes/00.genome_sequences_fixed_file_control/30044_13/scaffold/30044_13.scaffold.fasta
30044_14        /mnt/shared/scratch/szhang/projects/07.T_oceanicus_six_genomes/00.genome_sequences_fixed_file_control/30044_14/scaffold/30044_14.scaffold.fasta
30044_15        /mnt/shared/scratch/szhang/projects/07.T_oceanicus_six_genomes/00.genome_sequences_fixed_file_control/30044_15/scaffold/30044_15.scaffold.fasta
```

Cactus-pangenome:
注意我指定了参考序列

```sh
#!/usr/bin/bash
#SBATCH --cpus-per-task=32
#SBATCH --mem=512G
#SBATCH --partition=himem
#SBATCH --mail-user=zhangshangzhe@yahoo.com
#SBATCH --mail-type=END,FAIL
#SBATCH --job-name=cactus.pangenome.sh.split.1
#SBATCH --output=slurm_mission.cactus.pangenome.sh.2024-05-24-18031716570224/cactus.pangenome.sh.split.1.sl.out
#SBATCH --error=slurm_mission.cactus.pangenome.sh.2024-05-24-18031716570224/cactus.pangenome.sh.split.1.sl.err
#SBATCH --get-user-env

export TOIL_SLURM_OPTIONS="--batchSystem slurm --mesos-slurm-partition=himem --maxJobs 32"

cactus-pangenome ./js ./sample_info.txt --outDir T_oceanicus_six_genomes --outName T_oceanicus_six_genomes --reference 30044_12 --vcf full clip filter --giraffe full clip filter --gfa full clip filter --gbz full clip filter --odgi full clip filter --draw full clip --maxCores 32 --consCores 1 --indexCores 16 --mapCores 4 --mapCores 8 --binariesMode local  --logFile T_oceanicus_six_genomes.log
```

想欣赏一下结果的话，就在输出文件下的prefix.viz 文件夹下面看看图，其实看也看不懂，装逼可以用，别给老板装逼，因为老板会让你解释一下。

主要是用的文件就是`<prefix>.vcf.gz`,其中包含了过滤后的图形基因组中的全部变异，包括SNP和SV，以及MNP（多个连续的SNP）。要统计不同变异的数量和长度等，就需要写一个python脚本来识别由路径表示的不同变异了，这里就不提供了，我写的有点烂。

其次就是可以看看图形基因组的大致情况，使用vg:

>vg 的工具都很费内存，怎么办？没办法。

```sh
vg stats -lz ./prefix.gbz
```

输出的内容表示节点，路径的数量以及线性图形基因组的总长度，这里可以比较一下和参考基因组长度的差异，看看多少新的序列被添加到泛基因组中。

```
nodes	 151,214,856
edges	 204,814,669 
length	 2,354,231,385 
```

因为我生成泛基因组主要是为了寻找SV，所以没有很关心添加的序列有什么特征等信息，需要的可以去翻一翻vg包里面的工具。