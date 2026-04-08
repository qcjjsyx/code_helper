# Agent 架构与目录重组方案

## 目标

最终目标不是“让模型读几个 JSON 然后写一篇概述”，而是构建一个可扩展的文档 agent：

1. 能根据 Verilog 项目自动生成代码手册
2. 生成结果达到模块级、连接级、结构子级粒度
3. 支持功能扩展、family 扩展、外部依赖扩展
4. 支持后续增加审校、差分更新、质量评分

## 当前问题

现有实现已经有基础分层：

- `parser_pipeline` 负责事实抽取
- `ai_agent` 负责检索和生成

但仍有几个关键缺口：

1. `ai_agent` 直接消费 parser JSON，缺少面向“手册写作”的中间表示层
2. 检索仍是轻量 token 匹配，不适合长文档生成
3. `generate_manual` 是一次性生成，缺少章节规划、逐段检索、事实校验
4. `external_dependency` 只有接口，没有补知识机制
5. 缺少文档质量评估与回归测试

## 建议的三层架构

### 1. Parse Layer

职责：把 Verilog 项目转成稳定、可追踪的结构化事实。

输入：

- Verilog/SystemVerilog 文件
- `//@cc:` header
- family 模板

输出：

- module JSON
- component JSON
- project index
- build report

这一层尽量不掺杂大模型逻辑，重点是稳定性和可测试性。

### 2. Manual IR Layer

职责：把 parser 的事实重新组织成“适合写手册”的知识对象。

建议新增对象：

- `module_card`
  - 模块职责
  - 上游/下游
  - 关键输入输出
  - 关键子模块
- `channel_card`
  - drive/data/free 成组通道
  - producer / consumer
  - payload 位宽
  - 握手关系
- `component_contract`
  - family
  - 语义
  - release rule
  - 常见背压行为
- `reading_path`
  - 建议的阅读顺序
  - 关键链路
  - 风险点

这层是后续扩展的核心，也是你项目从“QA agent”走向“文档 agent”的关键。

### 3. Agent Layer

职责：围绕 Manual IR 做规划、检索、生成、校验。

建议拆成多阶段：

1. `planner`
   - 根据 top module 规划手册目录
2. `retriever`
   - 针对每一章检索最相关的 module/card/channel/component
3. `writer`
   - 生成章节草稿
4. `critic`
   - 检查是否遗漏关键模块、关键结构子、关键流
5. `assembler`
   - 合并章节，输出最终 Markdown

## 目标目录结构

建议从当前目录重组为：

```text
code_helper/
├─ parser/
│  ├─ verilog/
│  ├─ pipeline/
│  ├─ families/
│  └─ schemas/
├─ knowledge/
│  ├─ loaders/
│  ├─ indexes/
│  ├─ manual_ir/
│  └─ retrieval/
├─ agent/
│  ├─ planner/
│  ├─ writer/
│  ├─ critic/
│  ├─ prompts/
│  └─ cli/
├─ tools/
│  └─ cc_header_tools/
├─ docs/
├─ tests/
└─ artifacts/
```

## 与现有目录的映射建议

### 保留并迁移

- `parser_pipeline/` -> `parser/pipeline/`
- `verilog_parser/` -> `parser/verilog/`
- `cc_header_tools/` -> `tools/cc_header_tools/`

### 新增

- `knowledge/manual_ir/`
  - 生成 `module_card`、`channel_card`、`component_contract`
- `knowledge/retrieval/`
  - 检索、重排、章节上下文组装
- `agent/planner/`
  - 章节规划
- `agent/writer/`
  - 分章节写作
- `agent/critic/`
  - 一致性检查和覆盖率检查
- `agent/prompts/`
  - 集中管理 prompt，避免散落在业务文件中

## 建议的数据流

```text
Verilog project
  -> parser pipeline
  -> parser JSON artifacts
  -> manual IR builder
  -> chapter retrieval packs
  -> planner/writer/critic
  -> final manual
```

## 最小可落地版本

第一阶段不必一次重构全部目录，可以先做最小闭环：

1. 保持 `parser_pipeline/` 不动
2. 在现有仓库新增 `manual_ir/`
3. 把 `ai_agent/generate_manual` 改成多阶段：
   - 先生成章节目录
   - 再逐章生成
   - 最后做覆盖检查
4. 新增文档测试，检查手册是否覆盖：
   - 顶层模块
   - 一级子模块
   - 关键结构子 family
   - event/data/backpressure 章节

## 推荐的渐进式重构顺序

### 第一步

修复文本编码和 prompt 质量问题。

### 第二步

新增 `manual_ir`，把 parser JSON 转成文档友好的中间层。

### 第三步

把 `generate_manual` 从单轮生成改成多阶段 agent。

### 第四步

增加 external dependency 补知识机制。

### 第五步

增加质量评测与回归测试。

## external dependency 的扩展策略

像 `cpuCache_top` 这类模块现在只有接口信息。建议支持三种补充方式：

1. `manual_stub`
   - 手工维护结构化补充 JSON
2. `adapter`
   - 给特定 family 或外部模块写定制解析器
3. `plugin`
   - 以后通过插件扩展新的知识来源

## 你这个项目最应该避免的方向

1. 直接把所有 JSON 全量塞给模型
2. 只靠 prompt 逼模型“写得更细”
3. 过早引入向量数据库，忽略结构化知识优势
4. 没有测试标准就反复调 prompt

## 结论

你的项目已经有了不错的解析基础，真正要补的是“手册生成中间层”和“多阶段 agent 编排”。目录重组也应该服务于这个目标：把解析、知识组织、agent 执行三层彻底分开。

如果继续沿这个方向推进，项目会从“能问答的 Verilog JSON 包装器”升级为“可扩展的代码手册生成平台”。
