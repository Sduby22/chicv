# 自我介绍

1. 做什么：阿里国际 Lazada 业务线做电商的搜索&推荐广告投放引擎
    - 是什么： 触发 召回 过滤 粗排 精排 出价 定坑重排 透出给上游 结算
    - 主要负责：C++模块：召回过滤精排 是横向 owner

2. 工作内容：
    - 支持产品业务需求和算法同学迭代需求, 搜索推荐召回模块横向支持：技术选型 **架构设计** 开发测试。
        - 技术选型
            1. 工程合理性：新增的逻辑出现在该出现的地方，对公用的逻辑做抽象和复用。
            2. 性能考虑：并行化操作，不增加整体的 RT
            3. 资源和性能平衡：存算一体 / 存算分离。在离线
            4. 相关项目：DAG可视化 - 协助架构设计
        - 开发测试
            1. 灰度集群 发布规范
            2. 相关项目：引入单测，引入CICD 

    - 稳定性保障：日常 oncall，保障线上引擎和背后的 flink 实时链路稳定性，出问题快速定位具体模块找到算法负责人排查
        - 相关项目：降级配置中心，2%收入换取30%额外承载

    - 架构和性能优化：跟随算法迭代大版本上线的步伐，做性能优化腾出 RT 空间
        - 最近项目：通过架构优化平均 20ms，99RT 100ms
        - 相关项目
          - 性能优化数据分析：DAG 可视化内部工具，benchmark 方法
          - 性能优化：平均20ms，99RT 100ms

## 项目

### 并发架构性能优化

- 背景: 广告算法为了完成每个周期的提效目标，会在召回，排序等环节迭代，通常会导致RT快速膨胀。出于节省资源/控制RT等目的，会紧跟算法迭代的版本上线，做周期性的性能优化，为下个周期的算法迭代腾出空间

- 难点：无损性能优化空间有限，需要首先通过数据分析，线上profile等方式找到性能瓶颈，制定优化方案 / 估计优化空间，后通过实验集群尝试验证。不符合计划预期的情况时常发生，需要找到背后的原因并调整方案。有损性能优化难点则是寻找到合适的损失空间，保证损失空间对业务影响最小

- 首先观察到算法上线后召回模块99RT过高，通过数据分析，定位到可能的性能瓶颈是并发度不够，可以从并发架构的角度切入，提出了动态分批的优化方案取代原先的固定分批，制定了99RT 100ms的优化目标

    - 原先的架构为固定分N批请求计算较重的过滤+粗排，而每批内部还有固定的单机并行度N，统计了召回过滤模块中不同召回数的请求数量分布，发现大部分请求的召回数都较少，一批内可以解决。长尾请求可以多分几批次，相当于把小请求的算力挪给了大请求。同时发现了单批召回数的一个甜点，在这个点之前线性增长速度不快，可以作为理想的分批数。提出方案1: 不再固定分批，而是动态分批。且为了减少序列化开销不在分N批请求，而是单批请求且根据召回数动态调整单机并行度

    - 经过一些尝试，发现RT不降反升不符合预期 - 尝试从单机并发度限制，并发合并等待时间等角度解释深层次原因，调整方案并再次测试

    - 测试优化方案后，发现99RT不降反升，分析解释原因是RT的本质是等待时间，当单击并行数量大于机器核数时，需要额外等待一倍排队时间。提出方案2: 限制单机并行度，使其最大为物理核数的50%。

    - 实验后发现99RT 仍未达到优化预期。解释是因为单机的并行度已无法满足部分长尾流量的需求。提出方案3: 同时使用分批请求+单机并行的方式增加最大并行度。

    - 实验后仍然不够符合预期，发现单机的99RT仍然较高。分析原因是每次引入并行，其实都引入了分发任务+等待最长任务的时间。希望尽量减少分发+合并等待的过程。提出方案4: 不再使用单请求内并行，并发度全部使用分批请求的方式提供。这样分发+等待操作减少到1次

    - 实验后已基本符合预期，但是发现某个算子的99RT并不随分批增加而降低，经分析是该算子有与输入数量无关的前置计算，用支持sse指令的abseil hashmap替代了unordered_map，编译选项开启sse，该算子99RT降低了90%。此时已完全实现优化目标

- 结果是通过并发架构优化与算子数据结构优化，平均RT降低了20ms，99RT降低了100ms

### C++代码库健康度及工程健康度治理 

- 背景：作为跑步入场的业务线的，没有专门的C++ Owner做统一治理，未形成一套体系化的C++工程管理规范。由于不能直接带来业务收益，团队成员缺乏动力做出改变，代码库健康度较低，工程组织较混乱，开发环境搭建困难。开发流程中缺少了单测及自动化卡点的步骤，基本的代码质量难以保证。缺少一些基本的框架化抽象，导致了代码库的维护成本过高，新人需要学习大量的中台开发范式才能开始开发需求
- 目标：任何一位工程/算法新人，能够在1天内独立搭建整套开发环境，能够在不了解任何与业务无关的中台代码的情况下，只要明白C++语法就能开始开发需求，从多方面加速算法工程的迭代速度。
- 难点：需要在引入

### Flink 统一热库层内存优化

- 背景: 由于业务增长，广告库深度逐渐上升，但是经数据分析，过滤排序模块的内存索引表占用逐渐增加导致内存吃紧。出于为未来增长预期留下buffer，需要对内存占用进行优化。
- 难点: 