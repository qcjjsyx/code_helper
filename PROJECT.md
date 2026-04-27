# Verilog Documentation Agent Project

## 1. 项目定位

本项目是一个面向 Verilog/SystemVerilog 工程的多阶段代码手册生成 Agent。

它的目标不是把源码一次性喂给大模型后直接生成文档，而是构建一个可扩展、可测试、可校验的 Agent 系统：

- 先用确定性的程序分析抽取结构化事实
- 再将事实重组为面向文档写作的中间知识表示
- 再由多阶段任务系统完成规划、上下文装配、章节生成与审校
- 后续逐步扩展到问答、差分更新、外部依赖补知识和质量评估

从系统设计角度看，本项目属于：

- ground-truth-first 的代码文档生成系统
- 以结构化知识表示为核心的 agentic workflow
- 面向大项目上下文管理和预算控制的 documentation agent

## 2. 关键设计准则

### 2.1 Ground Truth First

模型不是事实来源，解析产物才是事实来源。

所有问答、章节生成和审校都应基于 parser 产物与中间层对象，而不是让模型直接猜测源码语义。

### 2.2 Structured Over Prompt-Only

项目优先通过结构化知识对象表达系统，而不是依赖 prompt 强迫模型“写得更细”。

系统的核心竞争力在于：

- 结构化事实抽取
- 文档语义重组
- 任务驱动的上下文装配

而不是单次 prompt 设计。

### 2.3 Multi-Stage Over One-Shot

整篇手册生成不是单轮调用，而是一个多阶段任务流程：

- 解析
- 中间表示构建
- 目录规划
- 上下文选择
- 分章节生成
- 覆盖检查
- 最终组装

### 2.4 Budget-Aware Context Management

真实工程规模很大，上下文窗口一定是系统设计中的核心约束。

因此项目必须具备面向任务、面向预算的上下文装配与压缩能力，而不是默认“把所有信息都塞给模型”。

### 2.5 Progressive Extensibility

系统先实现最小闭环，但从一开始就预留以下扩展接口：

- context manager
- Manual IR
- task system
- stage interface
- future hybrid retrieval

这保证项目可以逐步演化为更完整的 Agent 系统。

## 3. Architecture Overview

### 3.1 Parse Layer

职责：把 Verilog/SystemVerilog 工程转成稳定、可追踪的结构化事实。

输入：

- Verilog/SystemVerilog 文件
- `//@cc:` header
- family 模板

输出：

- module JSON
- component JSON
- project index
- build report

特点：

- 确定性
- 可单测
- 不依赖 LLM
- 是整个系统的 ground truth 基座

这一层在 Agent 视角中属于 deterministic tools。

### 3.2 Knowledge Representation Layer

职责：把 parser 事实重组为面向代码手册写作的知识对象。

当前中间层核心对象包括：

- `SystemView`
- `ModuleCard`
- `ComponentContract`

后续扩展对象包括：

- `ChannelCard`
- `FlowPath`
- `ReadingPath`

这一层完成的是从“代码事实”到“文档语义”的转换：

- parser 回答“代码里有什么”
- Manual IR 回答“文档里该怎么理解这些内容”

这一层是整个项目最核心、最具可扩展性的设计部分。

### 3.3 Retrieval / Context Layer

职责：根据当前任务，从 Manual IR 中选择、裁剪、压缩最合适的上下文。

后续将逐步拆分为：

- `ContextSelector`
- `ContextCompressor`
- `ContextPacker`
- `SessionMemory`

这一层不是简单的文本检索，而是基于结构化对象的上下文装配系统。

### 3.4 Task System

职责：把复杂文档生成目标拆解成多个阶段任务，并显式管理依赖关系与执行顺序。

典型任务包括：

- `parse_project`
- `build_manual_ir`
- `plan_manual_outline`
- `assemble_context_for_section`
- `generate_section`
- `critic_review`
- `assemble_final_manual`

因此，本项目当前应被理解为：

一个带 task system 的多阶段 documentation agent。

### 3.5 Skill / Workflow Layer

职责：把一类完整目标任务封装成可复用工作流。

典型 skill 可以包括：

- `generate_project_manual`
- `answer_architecture_question`
- `review_manual_coverage`
- `explain_component_contract`
- `regenerate_changed_section`

这里需要明确区分：

- `parser`、`manual_ir_builder`、`retrieval` 属于 tools
- `generate_manual`、`critic_review`、`chapter_generation` 属于 skills / workflows

### 3.6 Agent Runtime / Orchestration Layer

职责：作为主 Agent 运行时，驱动整个流程。

主要职责包括：

- 接收用户目标
- 选择 skill
- 驱动 task system
- 管理 session / context
- 调用模型
- 聚合中间结果
- 输出最终结果

### 3.7 Evaluation / Governance Layer

职责：对生成结果做覆盖率和一致性检查。

后续重点能力包括：

- 检查顶层模块与一级子模块是否覆盖
- 检查关键 family 是否被解释
- 检查 event/data/completion/backpressure 是否遗漏
- 检查是否超出事实边界
- 为回归测试提供稳定标准

## 4. Standard Workflow

一个完整的代码手册生成流程应包括以下阶段：

### 4.1 Preparation

- 读取工程配置
- 读取已有解析产物
- 如果 artifacts 不存在或过期，则触发 parser pipeline

### 4.2 Knowledge Construction

- 加载 `ProjectKnowledgeBase`
- 构建 `ManualIR`
- 建立对象索引与可达图

### 4.3 Planning

- 根据 top module 规划手册目录
- 决定章节粒度
- 决定每章需要覆盖哪些对象

### 4.4 Context Assembly

- 按章节选择相关 `ModuleCard`
- 补入相关 `ComponentContract`
- 后续加入 `ChannelCard` / `FlowPath`
- 根据 budget 做上下文裁剪与压缩

### 4.5 Generation

- 逐章生成草稿
- 每章只消费该章节对应的上下文 pack
- 输出结构清晰、证据受控的章节内容

### 4.6 Critique / Validation

- 检查遗漏的模块
- 检查遗漏的 family
- 检查 event/data/completion/backpressure 覆盖
- 检查是否存在事实越界

### 4.7 Assembly

- 合并章节
- 输出最终 Markdown 手册

## 5. Context Management and Compression

对于真实大工程，上下文压缩是必要能力。

本项目不应采用“简单摘要所有内容”的方式，而应采用以下策略：

### 5.1 Structural Compression

优先通过 Manual IR 把原始 parser 事实重组为更高层对象。

这本身就是第一层压缩，因为它将：

- 大量实例连接
- 长 signal list
- flow graph edges
- family contract 模板

压缩为更适合文档任务消费的知识对象。

### 5.2 Task-Driven Assembly

不同任务使用不同上下文：

- QA 任务：少量高相关对象
- 手册规划：`SystemView` + `ModuleCard` 摘要
- 章节生成：当前章节相关模块、结构子、关键路径
- 审校任务：已写内容 + 应覆盖对象集合

### 5.3 Tiered Granularity

同一对象后续应支持多种粒度：

- `brief`
- `standard`
- `detailed`

超预算时优先降级粒度，而不是直接丢弃关键对象。

### 5.4 Session Compression

多轮交互时，对话历史不应保留为长文本，而应逐步压缩成结构化 session memory，例如：

- 已确认事实
- 已完成章节
- 当前焦点
- 用户偏好
- 未解决问题

## 6. RAG Strategy

### 6.1 Design Conclusion

本项目需要“广义 RAG”，但当前不应以传统向量数据库式 RAG 作为系统主干。

### 6.2 Why Not Vector-First RAG

本项目的核心知识来源是：

- module JSON
- component JSON
- hierarchy
- contract
- flow graph
- Manual IR objects

这些信息具有以下特点：

- 强结构化
- 强可追溯
- 强语义角色约束

因此，它们更适合：

- 结构化检索
- 规则化装配
- 面向任务的 context selection

而不是优先依赖向量相似度检索。

### 6.3 Current Recommendation

当前系统应采用：

- 结构化检索作为主检索层
- 规则化 context assembly 作为主装配层
- budget-aware compression 作为主压缩层

### 6.4 Future Hybrid Retrieval

当项目后续需要接入以下内容时，可以引入 hybrid retrieval：

- 外部依赖文档
- 非结构化设计说明
- 历史手册
- 变更记录
- 测试日志
- 模糊问题场景

因此，本项目对 RAG 的正式立场应是：

当前以结构化检索为核心；未来可扩展为结构化检索 + 非结构化语义检索的混合 RAG。

## 7. Current Scope and Future Evolution

### 7.1 Current Focus

当前阶段重点：

- 稳定 Parse Layer
- 完善 Manual IR
- 建立多阶段 task system 雏形
- 建立上下文管理接口
- 实现核心章节生成闭环

### 7.2 Next Steps

后续阶段重点：

- `ChannelCard`
- `FlowPath`
- `ReadingPath`
- context compression
- critic / evaluator
- hybrid retrieval for external knowledge
- diff-aware regeneration

## 8. Project Definition

本项目应被正式定义为：

一个面向 Verilog/SystemVerilog 工程的、以结构化程序分析为 ground truth、以 Manual IR 为知识中间层、以 task system 驱动的多阶段代码手册生成 Agent。

它的核心价值不在于“调用了大模型”，而在于：

- 把代码事实转成文档语义
- 把复杂生成任务拆成可控阶段
- 把大项目上下文管理变成一个结构化系统
- 为未来扩展问答、审校、差分更新和混合检索预留稳定架构
