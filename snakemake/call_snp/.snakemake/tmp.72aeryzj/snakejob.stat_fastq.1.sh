#!/bin/sh
# properties = {"type": "single", "rule": "stat_fastq", "local": false, "input": ["raw_fastq/SRR15006267.1.fq.gz", "raw_fastq/SRR15006267.2.fq.gz"], "output": ["raw_stat/SRR15006267.stat.txt"], "wildcards": {"sample": "SRR15006267"}, "params": {}, "log": [], "threads": 1, "resources": {"tmpdir": "/tmp"}, "jobid": 1, "cluster": {"account": "user186", "c": 1, "n": 1, "partition": "pNormal", "mempercpu": "2G", "default": null}}
 cd /data/00/user/user186/Work_flow_of_population_genetics/snakemake/call_snp && \
/data/00/user/user186/miniconda3/envs/snp_calling/bin/python3.9 \
-m snakemake raw_stat/SRR15006267.stat.txt --snakefile /data/00/user/user186/Work_flow_of_population_genetics/snakemake/call_snp/Snakefile \
--force --cores all --keep-target-files --keep-remote --max-inventory-time 0 \
--wait-for-files /data/00/user/user186/Work_flow_of_population_genetics/snakemake/call_snp/.snakemake/tmp.72aeryzj raw_fastq/SRR15006267.1.fq.gz raw_fastq/SRR15006267.2.fq.gz --latency-wait 5 \
 --attempt 1 --force-use-threads --scheduler ilp \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
   --allowed-rules stat_fastq --nocolor --notemp --no-hooks --nolock --scheduler-solver-path /data/00/user/user186/miniconda3/envs/snp_calling/bin \
--mode 2  --default-resources "tmpdir=system_tmpdir"  && touch /data/00/user/user186/Work_flow_of_population_genetics/snakemake/call_snp/.snakemake/tmp.72aeryzj/1.jobfinished || (touch /data/00/user/user186/Work_flow_of_population_genetics/snakemake/call_snp/.snakemake/tmp.72aeryzj/1.jobfailed; exit 1)

