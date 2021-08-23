#!/bin/bash
#
#SBATCH --job-name=snake_mapping
#SBATCH -c 1 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem=10G # Memory pool for all cores in MB (see also --mem-per-cpu)
#SBATCH --time 5-00:00:00 # 5 day runtime
#SBATCH -p pNormal # Partition to submit to
#SBATCH -o snake.out # File to which STDOUT will be written
#SBATCH -e snake.err # File to which STDERR will be written

cd /share/comailab/kramundson/potato-mapping # modify path as needed

source activate gatk-potato # 激活环境

snakemake -j 5 --cluster-config cluster.yaml --cluster "sbatch -p {cluster.partition} -n {cluster.n} -t {cluster.time} -c {cluster.c} --mem-per-cpu {cluster.mempercpu}" -k

source deactivate gatk-potato

date
