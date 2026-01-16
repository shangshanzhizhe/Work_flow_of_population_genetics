# 基因组组装和注释

## HiFi数据组装

```sh
hifiasm -o <prefix> -t 48 <input.fasta>
```

HiFi数据的单碱基准确度高，不需要进行reads过滤，直接进行组装