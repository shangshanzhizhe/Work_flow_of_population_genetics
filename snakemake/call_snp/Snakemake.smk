configfile: "config.yaml"
print (config['samples'])

rule all:
    input:
        expand("raw_stat/{sample}.{num}".stat.txt, sample=config["samples"], num=['1', '2']),
        expand("clean_stat/{sample}.{num}".stat.txt, sample=config["samples"], num=['1', '2']),
        expand("sorted_reads/{sample}.sort.bam", sample=config["samples"])
        expand("sorted_reads/{sample}.sort.bam.bai", sample=config["samples"])
        
rule stat_fastq:
    input: 
        fw=lambda wildcards: expand("raw_fastq/{sample}.1.fq.gz", sample=wildcards.sample),
        re=lambda wildcards: expand("raw_fastq/{sample}.2.fq.gz", sample=wildcards.sample)
    output:
        fwo="raw_stat/{sample}.1.stat.txt",
        reo="raw_stat/{sample}.2.stat.txt"
    shell:
        "fastqutils stats {input.fw} > {output.fw}",
        "fastqutils stats {input.re} > {output.re}"

rule clean_fastq:
    input:
        fw=lambda wildcards: expand("raw_fastq/{sample}.1.fq.gz", sample=wildcards.sample),
        re=lambda wildcards: expand("raw_fastq/{sample}.2.fq.gz", sample=wildcards.sample)
    output:
        fwo="clean_reads/{sample}.1.clean.fq.gz",
        reo="clean_reads/{sample}.2.clean.fq.gz"
    threads: 8
    shell:
        "fastp -i {input.fw} -I {input.re} -o {output.fwo} -O {output.reo} --thread {threads}"

rule stat_clean:
    input: 
        fw=lambda wildcards: expand("clean_reads/{sample}.1.clean.fq.gz", sample=wildcards.sample),
        re=lambda wildcards: expand("clean_reads/{sample}.2.clean.fq.gz", sample=wildcards.sample)
    output:
        fwo="clean_stat/{sample}.1.stat.txt",
        reo="clean_stat/{sample}.2.stat.txt"
    shell:
        "fastqutils stats {input.fw} > {output.fw}",
        "fastqutils stats {input.re} > {output.re}"

rule bwa_index:
    input:
        "reference/{ref}.fasta"
    output:
        done=touch("{ref}.bwa_index.done")
    shell:
        "bwa index -p reference/ref {input}"

rule faidx_index:
    input:
        "reference/{ref}.fasta"
    output:
        "reference/{ref}.fasta.fai"
    shell:
        "samtools index {input}"

rule bwa_mem:
    input:
        "reference/ref",
        "clean_reads/{sample}.1.clean.fq.gz"
        "clean_reads/{sample}.2.clean.fq.gz"
    output:
        temp("mapped_reads/{sample}.bam")
    params:
        rg=r"@RG\tID:{sample}\tPL:illumina\tPU:illumina\tLB:{sample}\tSM:{sample}"
    log:
        "logs/bwa_mem/{sample}.log"
    threads: 8
    shell:
        "(bwa mem -R '{params.rg}' -t {threads} {input} | "
        "samtools view -Sb - > {output}) 2> {log}"

rule samtools_sort:
    input:
        "mapped_reads/{sample}.bam"
    output:
        protected("sorted_reads/{sample}.sort.bam")
    shell:
        "samtools sort -T sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output}"

rule samtools_index:
    input:
        "sorted_reads/{sample}.sort.bam"
    output:
        "sorted_reads/{sample}.sort.bam"
    shell:
        "samtools index {input}"