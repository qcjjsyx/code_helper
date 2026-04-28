# Verilog Project Parser And Documentation Agent

这个项目的目标是把 Verilog/SystemVerilog 项目解析成结构化 JSON，再基于这些 JSON 组织知识、检索上下文，并生成代码手册。

当前目录按三层架构组织：

- `parser/`
  - `verilog/`: 底层 Verilog 解析能力
  - `pipeline/`: 工程级事实抽取、层级构建、JSON 产物输出
  - `families/`: family 模板与 `//@cc:` 相关模板
  - `schemas/`: parser 相关 JSON 模板
- `knowledge/`
  - `loaders/`: 读取 parser 产物
  - `indexes/`: 组件知识索引与文档索引构建
  - `manual_ir/`: 面向手册写作的中间表示
  - `retrieval/`: 检索与重排
- `agent/`
  - `context/`: session、context budget、context assembly 的接口层
  - `planner/`: 手册规划阶段
  - `writer/`: 生成阶段
  - `critic/`: 审校阶段
  - `prompts/`: Prompt 管理
  - `cli/`: 命令行入口
- `tools/`
  - `cc_header_tools/`: `//@cc:` header 生成与校验工具

辅助目录：

- `test_data/`: 测试用 Verilog 样例工程
- `tests/`: 单元测试与集成测试
- `docs/`: 项目说明文档
- `artifacts/`: 解析产物和生成结果

## Parser Pipeline

执行：

```bash
python -m parser.pipeline build \
  --inputs test_data/rtl \
  --output artifacts/parser_pipeline_rtl
```

输出：

- `artifacts/parser_pipeline_result/project_index.json`
- `artifacts/parser_pipeline_result/modules/<module_name>.json`
- `artifacts/parser_pipeline_result/components/<component_name>.json`
- `artifacts/parser_pipeline_result/build_report.json`

## Manual IR Export

Manual IR 从已有 parser pipeline 产物中加载知识库，再生成面向手册写作的中间表示。它不会重新运行 parser，也不会修改 RTL 源码。

单文件导出适合程序消费或保存完整快照：

```bash
python -m knowledge.manual_ir export \
  --artifacts-root artifacts/parser_pipeline_rtl \
  --top-module arm_soc_top \
  --output artifacts/manual_ir/arm_soc_top_manual_ir.json
```

输出文件包含完整 `ManualIR`：

- `objects.system_views`
- `objects.module_cards`
- `objects.component_contracts`
- `indexes`
- `warnings`

拆分目录导出适合人工逐类审核：

```bash
python -m knowledge.manual_ir export \
  --artifacts-root artifacts/parser_pipeline_rtl \
  --top-module arm_soc_top \
  --output-dir artifacts/manual_ir/arm_soc_top
```

输出目录：

- `manifest.json`：记录 schema、top module、对象数量、文件索引、indexes 和 warnings
- `system_views.json`：系统视图列表
- `module_cards/<module_name>.json`：每个模块一个 ModuleCard
- `component_contracts/<component_name>.json`：每个结构子一个 ComponentContract

## Recent Progress

这部分记录最近一轮对话中已经落地的 parser / manual_ir 相关改动，方便新对话快速接上下文。

### 1. Parser Layer

- 模块 JSON 新增了 `interface_summary`
- 当前 `interface_summary` 只保留确定性接口事实：
  - `signal_groups`
  - `control_signals`
  - `backpressure_signals`
- 之前试做过 `peer_relations`，但因为过度依赖端口命名风格、跨项目不稳定，已经删除
- 当前 parser 不再尝试从端口名推导模块级 `upstream/downstream peer`
- 当前 parser CLI 使用当前工作目录作为 repo root，`--inputs` 表示 RTL 工程目录
- `--inputs` 目录必须包含 `read_rtl_list.tcl` 和 `rtl_top_list.tcl`
- parser build 保持只读，不会自动写入 `//@cc`；已有 `//@cc` 只作为可选事实来源
- 解析边界策略集中在 `parser/pipeline/boundary_policy.py`
- 当前 parser 会把以下结构子类型作为层级解析边界：
  - `cArbMerge`
  - `cFifo`
  - `cMutexMerge`
  - `cPmtFifo`
  - `cNatSplit`
  - `cWaitMerge`
  - `cSelSplit`
  - FIFO-like 变体，例如 `lsu_cFifo1_lsu`、`ldwmFifo_lsu`、`cLastFifo1`、`cMergeFifo1`
  - 命中这些类型的实例会生成 component JSON，但不会继续向下展开为 module 层级

### 2. Manual IR Layer

- `ManualIR` 已经接入独立 builder：`knowledge/manual_ir/builder.py`
- 当前重点对象仍然是：
  - `SystemView`
  - `ModuleCard`
  - `ComponentContract`
- `ModuleCard` 现在会稳定映射这些确定性事实：
  - `document_role`
  - `responsibilities`
  - `key_interfaces.ingress_channels`
  - `key_interfaces.egress_channels`
  - `key_interfaces.control_signals`
  - `key_component_roles`
  - `backpressure_points`
  - `risk_points`
- `upstream_modules` / `downstream_modules` 字段暂时保留在数据模型里，但当前不再填充语义推断结果，默认保持为空
- `knowledge/manual_ir/manual_context.py` 已切换为基于 `build_manual_ir()` 组装摘要，不再自己重复做 reachability walk

### 3. Ignored Helper Units

对于 parser pipeline 中的工程辅助单元，当前已经支持两类处理：

- `delay<number>U` / `delay<number>Unit` 会被完全跳过，不进入模块 JSON 的 `instances`，不生成 artifact，也不进入层级树
- 一部分 unresolved helper target 会被保留为 ignored unresolved，避免污染 `build_report.json`

当前 unresolved helper 规则在 `parser/pipeline/boundary_policy.py` 中维护：

- 精确匹配：
  - `contTap`
  - `freeSetDelay`
  - `IUMB`
  - `BUFM2HM`
  - `SHKB110_1024X8X8CM8`
  - `HKB110_4096X8X8CM8`

注意：

- `delay_free_cpu` 不会被 `delay<number>U` 规则忽略
- `delay1U`、`delay4U`、`delay16U`、`delay1Unit` 这类延迟 helper 会直接被跳过
- unresolved helper 实例仍然保留在模块 JSON 的 `instances` 中，并标记 `ignored_unresolved: true`
- ignored unresolved helper 不会进入 `build_report["issues"]`
- ignored unresolved helper 不会计入 `project_index["stats"]["unresolved_instance_count"]`

后续如果还要新增应忽略的工程辅助单元，优先按下面两种方式维护：

- 固定名字：加入 `IGNORED_UNRESOLVED_TARGET_EXACT`
- 稳定命名模板：优先封装成明确 helper 函数，不要用宽松子串匹配

### 4. Tcl File List Support

为了支持更接近真实项目结构的 `test_data/rtl`，parser pipeline 现在要求 `--inputs` 指向包含标准 Tcl 清单的 RTL 工程目录：

- `read_rtl_list.tcl` 用于构建 module index
- `rtl_top_list.tcl` 用于解析 top modules

示例：

```bash
python -m parser.pipeline build \
  --inputs test_data/rtl \
  --output artifacts/parser_pipeline_rtl
```

当前 Tcl 解析策略：

- 支持一行一个文件名
- 支持从行内提取 `.v` / `.sv` / `.vh` token
- `.vh` 只用于容忍工程清单，不进入 module index
- 文件名匹配要求“名字完全一致、大小写一致、后缀一致”
- 如果出现多个“完全同名”的候选文件，当前仍会做一个最小路径优先选择，以避免真实工程直接跑坏

### 5. Current Known Boundaries

- 目前 parser 对真实 `rtl` 工程已经能通过 Tcl 清单完成 build，但仍会遇到一些真实外部依赖或库单元的 unresolved warning
- 当前阶段不要把精力放在 planner / critic / RAG / 长期 memory 上
- 下一阶段应继续优先推进：
  - parser 的结构化事实补强
  - manual_ir 的稳定映射
  - 面向文档生成的核心中间层对象
- 暂时不要重新引入依赖命名习惯的强语义推断，尤其是模块级上下游关系推断

## Documentation Agent

先配置 `.env`：

```bash
cp .env.example .env
```

环境变量：

```env
DASHSCOPE_API_KEY=your_api_key
QWEN_MODEL=qwen-plus
QWEN_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
```

问答：

```bash
python -m agent ask \
  --repo . \
  --question "解释 cpu_top 的主要模块组成，以及 Fetch_top 的关键事件流"
```

生成手册：

```bash
python -m agent generate-manual \
  --repo . \
  --top-module cpu_top \
  --output docs/manuals/cpu_top.md
```

## Agent Context Management

这个项目的目标不仅是“调用一次模型生成文档”，而是逐步整理成一个更完整的 agent 项目。

因此当前版本已经预留了 `agent/context/` 这一层，用于承载后续会逐步补齐的 agent 基础设施：

- session 生命周期管理
- context window 的 budget 与裁剪
- 检索结果、Manual IR、对话摘要的统一装配
- 多阶段生成过程中的章节级上下文
- 后续可扩展的 memory / snapshot / persistence backend

当前状态：

- 当前默认实现是一个很轻量的 `InMemoryContextManager`
- 它主要用于保留统一接口和最基础的上下文选择入口
- 复杂的长期记忆、摘要压缩、跨轮持久化、context ranking 还没有实现

这样做的目的，是让项目在保持当前最小闭环可运行的同时，为后续扩展成更完整的 agent 系统预留稳定接口。

## `cc_header_tools`

```bash
python -m tools.cc_header_tools autogen --repo . --inputs test_data/pipeline --only-missing --inplace
python -m tools.cc_header_tools lint --repo . --inputs test_data/pipeline
```

## 测试

执行：

```bash
pytest
```
