configfile: "config.yaml" # 配置文件

rule all:
    input:
        "plots/quals.svg" # 要求生成该文件


def get_bwa_map_input_fastqs(wildcards): ## 将文件的获取移动到DAG阶段
    return config["samples"][wildcards.sample]


rule bwa_map:
    input:
        "data/genome.fa",
        get_bwa_map_input_fastqs ## 执行函数来获取路径
    output:
        temp("mapped_reads/{sample}.bam") #表示其为临时文件，全部任务结束后将删除
    params:
        rg=r"@RG\tID:{sample}\tSM:{sample}" ## 参数，可以直接加入命令行
    log:
        "logs/bwa_mem/{sample}.log" ## log文件
    threads: 8 # 使用的线程数
    shell: # 执行的脚本
        "(bwa mem -R '{params.rg}' -t {threads} {input} | "
        "samtools view -Sb - > {output}) 2> {log}"


rule samtools_sort:
    input:
        "mapped_reads/{sample}.bam"
    output:
        protected("sorted_reads/{sample}.bam")
    shell:
        "samtools sort -T sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output}"


rule samtools_index:
    input:
        "sorted_reads/{sample}.bam"
    output:
        "sorted_reads/{sample}.bam.bai"
    shell:
        "samtools index {input}"


rule bcftools_call:
    input:
        fa="data/genome.fa",
        bam=expand("sorted_reads/{sample}.bam", sample=config["samples"]), # 在初始化阶段就获取路径
        bai=expand("sorted_reads/{sample}.bam.bai", sample=config["samples"])
    output:
        "calls/all.vcf"
    params:
        rate=config["prior_mutation_rate"]
    log:
        "logs/bcftools_call/all.log"
    shell:
        "(samtools mpileup -g -f {input.fa} {input.bam} | "
        "bcftools call -mv -P {params.rate} - > {output}) 2> {log}"


rule plot_quals:
    input:
        "calls/all.vcf"
    output:
        "plots/quals.svg"
    script:
        "scripts/plot-quals.py"