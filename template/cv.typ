#import "@preview/cuti:0.2.1": show-cn-fakebold
#show: show-cn-fakebold

#show heading: set text(font: "KaiTi", weight: "bold")

#show link: underline

// Uncomment the following lines to adjust the size of text
// The recommend resume text size is from `10pt` to `12pt`
// #set text(
//   size: 12pt,
// )

// Feel free to change the margin below to best fit your own CV
#set page(
  margin: (x: 2cm, y: 2.5cm),
)

// For more customizable options, please refer to official reference: https://typst.app/docs/reference/

#set par(justify: true)

#let chiline() = {v(-3pt); line(length: 100%); v(-5pt)}

= 李子豪

supersduby\@gmail.com | 18683897591 | 
#link("https://github.com/Sduby22")[github.com/Sduby22] 

== 教育经历
#chiline()

*北京邮电大学* #h(1fr) 2019/09 -- 2023/09 \
计算机科学与技术专业 GPA 89.12 - 15%  #h(1fr) \

== 工作经历
#chiline()

#let duration-style = text.with(style: "italic", size: 0.8em)

*Alibaba 国际数字商业集团 Lazada&Daraz&Miravia* #h(1fr) 2023/04 -- Now #duration-style[(1y 6mo)] \
C++广告投放引擎工程师 #h(1fr) 2023/07 -- Now #duration-style[(1y 3mo)] \
C++广告投放引擎工程师 实习 #h(1fr) 2023/04 -- 2023/07 #duration-style[(3mo)] \
- 负责*多业务线搜索&推荐广告*召回、过滤、粗排的C++引擎研发迭代与运维工作，与算法合作完成需求讨论、技术选型、架构设计、开发验证、AB实验、后期性能优化、troubleshooting等工作，解决需求开发中的工程难题，护航算法提效与业务指标增长
- *C++工程规范与研发效能*: 
  - 大力推动C++工程规范，修复大量影响可维护性和运行效率的Bad Practice，使用模板元编程，std::variant重构大量运行时泛型处理冗余代码
  - 负责团队内C++ Code Review，构建基于gtest业务逻辑单侧框架，提升团队整体代码质量
  - 完成迁移clang-13 + mold的构建系统升级与编译产物一致性对比，代码编译速度提升2x
  - 镜像化开发环境，搭配一同维护的开箱即用VSCode配置极大提升工程算法整体研发效能。
  - 引入CI Worker完成自动化风格化检查与单测卡点，团队成为BU首个卓越工程团队
- *业务插件框架降低算法迭代门槛*: 从召回引擎业务特点抽象出基于行处理/表处理的业务插件框架。隐藏了输入输出处理、类型行名校验等重复性工作。插件可作为动态库单独发布。在线服务加载时，利用weak_ptr引用计数实现了同版本插件代码段共享&不同版本代码段共存，旧版本业务下线后自动释放。算法可以只关注过滤/排序等业务逻辑实现，提升了研发效率
- *在线索引实时更新内存优化*: 优化流处理Flink Join链路，在主表Join前新增一层热库层，将大部分可离线完成的Filter操作提前到数据处理链路完成，减少在线引擎数据表的无用行数。广告库数据量降低4x，引擎广告库索引表内存降低4x，节省了重复过滤的开销
- *系统稳定性与降级优化*: 设计了支持细粒度流量划分的降级系统，支持在大促高峰&系统异常等紧急场景，针对细粒度流量进行降级参数覆盖。基于微服务配置中心做配置分发，从WebUI到引擎生效时间为秒级。结合不同种类召回链路的归因分析，设计降级参数保障高效召回的同时舍弃长尾，用2%的效果损失换取30%额外承载能力
- *系统可观测性优化*: 
  - 建立多业务线召回服务统一Grafana监控大盘，添加大量性能与业务指标实时监控。提升发布效率
  - 为图DAG执行引擎添加自动性能埋点功能，每日定时Hive SQL聚合性能埋点，配合React WebUI展示各子图AVG/P99性能指标，为性能优化与性能变化追踪提供重要数据支撑
  - 为C++引擎开发了基于流量步进重放的自动benchmark，配合单独设计的Grafana Benchmark监控，可对系统进行多指标测试，为系统优化成果提供量化指标
// more space


*Momenta 高精地图&人机交互组* #h(1fr) 2021/10 -- 2022/02 #duration-style[(4mo)] \
C++研发实习生 #h(1fr)  \
- *车机地图渲染引擎开发* 为C++渲染引擎开发了Ray Picking世界元素选取，全局光照以及相机跟随控制等功能
- *GLTF三维模型合并工具* 为地图数据处理流水线开发GLTF模型合并工具，将碎片化模型合并为可增量更新的场景chunk文件，减少客户端并发请求压力

== 技能
#chiline()

*语言*  C++20 #duration-style[(Working)] / Python, Rust, Shell, TypeScript, SQL #duration-style[(Familiar)]
