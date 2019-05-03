# loongson_MIPS_demo
龙芯MIPS教学源码学习记录

* 使用vivado 2018.3版本构建，源代码中有详细注释
* 基于龙芯设计的赛灵思FPGA开发板
* 注意，直接simulation会报错，应当选择综合后simulation


[源码阅读笔记](https://blog.csdn.net/lgfx21/article/details/89715017)
[仿真记录](https://blog.csdn.net/lgfx21/article/details/89784746)

# 文件内容
* single_cycle_cpu  单周期CPU
* pipeline_cpu      五级流水线CPU
* pipeline_CU_cpu  控制逻辑集成为CU模块
* 6pipeline_CU_cpu 将五级流水线扩展为6级流水线

# 工作记录
* 2019.5.1 将五级流水线控制机构整理到CU模块 注释CU模块
* 2019.5.3 对五级流水CPU和集成CU的五级流水CPU进行仿真

