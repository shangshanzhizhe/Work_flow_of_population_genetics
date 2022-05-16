# Work_flow_of_population_genetics

<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fshangshanzhizhe%2FWork_flow_of_population_genetics&count_bg=%2379C83D&title_bg=%23555555&icon=microgenetics.svg&icon_color=%23E7E7E7&title=%E8%AE%BF%E9%97%AE%E9%87%8F&edge_flat=false"/></a>

记录相关流程和脚本方便自己和大家参考，佛系更新，独木难支，欢迎志同道合的小伙伴加入！

这个repo已经开通[Discussion](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/discussions)版块，希望可以成为大家学习交流的平台

### 贡献者们

<a href="https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=shangshanzhizhe/Work_flow_of_population_genetics" />
</a>

>[Mou Yin](https://github.com/yinm2018): 看看我写的基因组学研究流程！\
[Hermiolee1](https://github.com/Hermiolee1): 我占坑的，怎么了嘛

### 下一步

- [ ] 测试和更新bwa-mem2/minimap2比对流程
- [ ] 测试和更新二代测序SV鉴定流程

### 下亿步

- [ ] 下一步：将以下一些流程写为snakemake workflow
    - [x] SNP calling Snakemake 流程已经完成
- [ ] 下一步：将以下一些流程装进conda


### 更新记录

- 2022.5.16 更新了使用二代测序数据检测结构变异的流程，基本思路是使用不同软件对每个个体的SV进行鉴定，然后将SV全部合并为一个文件，之后再根据所有样本的比对结果确定SV的基因型。感谢兰州大学博士研究生[安绚](https://www.researchgate.net/profile/Xuan-An-3)的整理。

### 目录
- 生物信息工具——[我的关注](https://github.com/shangshanzhizhe?tab=stars)
- [常用数据处理Tips](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/data_processing.md)
- 重测序和群体遗传
    - 变异鉴定和变异特征 ([snakemake自动化](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/tree/master/snakemake/call_snp))
        - [序列过滤和比对](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/Reads_clean_and_Mapping.md)
            - **Nanopore**测序结果过滤:[Nanoflt](https://github.com/wdecoster/nanofilt)
            - **Nanopore**测序结果可视化:[NanoPlot](https://github.com/wdecoster/NanoPlot)
        - [获得遗传变异信息以及质量控制](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/Call_variants_and_filtering.md)
        - [比对特征统计](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/bam_file_property.md)
    - 群体历史推测
        - [MSMC算法](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/msmc_demo.md)
        - [PSMC算法](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/psmc.md)
    - 群体关系计算
        - [King计算个体间亲缘关系](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/king.md)
        - [PCA分析群体结构](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/pca_structure.md)
- 结构变异检测和群体遗传

    结构变异的检测，在模式生物中研究很多，很多结果也很漂亮，但是在非模式生物中尚未形和SNP一样的模式化流程，没有什么是“正确的”，我们只能尽量让它准确。流程也是我自己摸索的结果，仅供参考。
    
    - [二代测序 结构变异检测](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/structure_variation.md)
    - [三代测序 结构变异检测](https://github.com/shangshanzhizhe/YakPopulationSV)
    
        基于三代SV的结构变异鉴定可以参考[Jasmine](https://github.com/mkirsche/Jasmine)。我一直关注它从一个小工具成长为一个完整的流程，但是未能自己尝试使用，使用后可以更新流程。
- [Nanopore测序数据甲基化检测](https://github.com/shangshanzhizhe/Work_flow_of_population_genetics/blob/master/Work_flows/methylation.md)
- 植物基因组组装和个性化分析 (以[花苜蓿](https://onlinelibrary.wiley.com/doi/abs/10.1111/1755-0998.13363)基因组学研究为例)
    - [相关流程和命令行](https://github.com/yinm2018/Medicago_ruthenica_genome)
    
