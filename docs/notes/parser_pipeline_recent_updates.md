# Parser Pipeline Recent Updates

Date: 2026-04-27

## 项目方向

本项目是面向 Verilog/SystemVerilog 工程的代码手册生成系统。当前核心阶段仍然是：

- Parse Layer
- Knowledge Representation / Manual IR Layer

核心原则保持不变：

- parser 产物是事实来源
- Manual IR 基于 parser 事实构建
- 不依赖 LLM 推断源码结构事实
- 当前不把主要精力放在 agent orchestration、RAG、长期 memory、复杂 prompt engineering

## 本轮主要修改

### 1. Parser CLI 与只读流程

parser build 改为工程目录输入：

```bash
python -m parser.pipeline build \
  --inputs test_data/rtl \
  --output artifacts/parser_pipeline_rtl
```

行为约定：

- `--inputs` 是 RTL 工程目录
- 目录下必须存在 `read_rtl_list.tcl` 和 `rtl_top_list.tcl`
- `repo_root` 使用当前工作目录
- parser build 不自动写入 `//@cc`
- `cc_header_tools` 保持独立工具，不混入 parser build

### 2. 解析边界策略层

新增 `parser/pipeline/boundary_policy.py`，集中管理解析边界：

- `module`
- `component_leaf`
- `skip_helper`
- `ignored_external`
- `external_dependency`

当前 component leaf 规则包括：

- `cArbMerge`
- `cFifo`
- `cMutexMerge`
- `cPmtFifo`
- `cNatSplit`
- `cWaitMerge`
- `cSelSplit`
- 现有扩展形态如 `cSplit`、`cSplitter`、`cSelector`、`cCondFork`
- FIFO-like 名称，如 `lsu_cFifo1_lsu`、`xxxFifo`、`cMergeFifo1`
- `eventSource`

skip helper 规则：

- `delay<number>U`
- `delay<number>Unit`

skip helper 完全跳过：

- 不进入 `instances`
- 不进入 hierarchy
- 不进入 `project_index`
- 不进入 `build_report`

ignored external 保留实例并标记：

```json
"ignored_unresolved": true
```

但不计入 unresolved count，不进入 issues。

### 3. Component leaf 生成与 fallback

`component_leaf` 会生成 component JSON，但不递归展开内部层级。

如果某个 family 被识别为 component leaf，但 `family_level.json` 中暂时没有模板：

- 不再触发 `KeyError`
- 使用空 contract fallback
- `template_source` 为 `missing_family_template`
- warnings 中记录缺模板信息

随后已补充 `eventSource` family 模板，因此 `eventSource` 当前不再触发 fallback。

### 4. eventSource family 模板

在 `parser/schemas/json_templates/family_level.json` 中新增 `eventSource` 模板。

当前模板保持轻量，只确定骨架：

- trigger
- event_output/fire
- reset
- payload
- 最小 contract

具体语义细节后续由人工继续补充。

### 5. `//@cc` 优先级调整

由于当前 parser build 不自动补 `//@cc`，并且真实项目中大多数文件没有 `//@cc`，因此已删除 `//@cc` 对以下逻辑的优先覆盖：

- family 判断
- role_mapping 判断

当前策略：

- family 主要由 boundary policy 的模块名和文件名规则识别
- role_mapping 从 parser 解析到的端口事实推断
- `cc_header` 参数仍保留在部分函数签名中，仅用于兼容调用链，不作为优先事实来源

### 6. 非 ANSI 端口解析

`parser/pipeline/module_parser.py` 已支持非 ANSI 端口声明，例如：

```verilog
module cFifo1(
  i_drive, i_freeNext, rst,
  o_free, o_driveNext,
  o_fire_1
);

input i_drive, i_freeNext, rst;
output o_free, o_driveNext;
output o_fire_1;
endmodule
```

现在 parser 能解析：

- body 中的 `input/output/inout` 声明
- 多端口同一行
- 位宽
- `wire/reg/logic/signed/unsigned`
- 按 module header 中的端口顺序稳定输出

这个修改解决了大量 component JSON 中 `interface.ports` 和 `role_mapping` 为空的问题。

真实 RTL build 后统计：

- component 总数：149
- 空 `interface.ports`：0
- 空 `role_mapping`：0

### 7. `width_text` 标量宽度修复

声明出来的 1-bit 标量端口和局部信号不再输出 `null`，统一输出：

```json
"width_text": "1"
```

显式位宽继续保留源码 range，例如：

```json
"width_text": "[7:0]"
```

仍保留 `null` 的情况仅限宽度确实未知的隐式信号或表达式。

真实 RTL build 后统计：

- component 端口 `width_text: null`：0
- module 端口 `width_text: null`：0
- module local signal `width_text: null`：0

### 8. Schema template 记录

新增 parser 产物模板：

- `parser/schemas/json_templates/project_index_template.json`
- `parser/schemas/json_templates/build_report_template.json`
- `parser/schemas/json_templates/module_template.json`

并同步更新：

- `parser/schemas/json_templates/component_template.json`
- `parser/schemas/json_templates/module_template.json`

用于记录当前 parser 输出格式。

## 重要验证

本轮最后一次验证：

```bash
pytest
```

结果：

```text
34 passed
```

真实 RTL build 也通过：

```bash
python -m parser.pipeline build \
  --inputs test_data/rtl \
  --output artifacts/parser_pipeline_rtl
```

## 新对话启动提示词

请在新对话中使用以下提示词：

```text
你现在在一个 Verilog/SystemVerilog 代码手册生成项目中工作，项目路径是 /Users/huangyuan/qcjjsyx/AI_Agent/code_helper。

请先阅读 README.md、PROJECT.md，以及 docs/notes/parser_pipeline_recent_updates.md，再开始分析任何问题。

项目定位：
- 这是一个面向 Verilog/SystemVerilog 工程的代码手册生成系统。
- 当前重点是 Parse Layer 和 Knowledge Representation / Manual IR Layer。
- 核心原则是 ground-truth-first：parser 产物才是事实来源，不让 LLM 直接猜源码语义。
- 系统核心竞争力在结构化程序分析、Manual IR、可控上下文装配，而不是 prompt engineering。

当前不要把主要精力放在：
- 多阶段 agent orchestration
- planner / critic / writer 的完整实现
- context manager 的高级功能
- RAG / 向量检索
- 长期 memory / session persistence
- 复杂 prompt engineering

最近 parser pipeline 已完成这些关键更新：
- parser build 使用工程目录输入：
  python -m parser.pipeline build --inputs test_data/rtl --output artifacts/parser_pipeline_rtl
- --inputs 目录下固定读取 read_rtl_list.tcl 和 rtl_top_list.tcl。
- parser build 是只读流程，不自动写入 //@cc。
- 新增 boundary_policy.py，集中管理 module、component_leaf、skip_helper、ignored_external、external_dependency。
- 结构子和 FIFO-like 模块作为 component_leaf，不再递归展开内部层级。
- delay<number>U 和 delay<number>Unit 是 skip_helper，完全跳过。
- ignored external 保留 instance 并标记 ignored_unresolved: true，但不进入 issues/count。
- eventSource 已作为新的 component family，并在 family_level.json 中有轻量模板。
- 如果新增 family 没有模板，component JSON 会用 missing_family_template fallback，不再 KeyError。
- 已删除 //@cc 对 family 和 role_mapping 的优先覆盖。当前 role_mapping 主要从 parser 解析出的端口事实推断。
- module_parser 已支持非 ANSI 端口声明。
- 声明出来的 1-bit 标量端口和局部信号 width_text 输出 "1"，不再输出 null。
- parser/schemas/json_templates 中已记录 project_index、build_report、module json 的模板格式。

重要文件：
- parser/pipeline/boundary_policy.py
- parser/pipeline/hierarchy_builder.py
- parser/pipeline/module_index.py
- parser/pipeline/module_parser.py
- parser/pipeline/family_json_builder.py
- parser/pipeline/family_inference.py
- parser/schemas/json_templates/family_level.json
- knowledge/manual_ir/builder.py
- knowledge/manual_ir/manual_context.py
- knowledge/manual_ir/models.py
- tests/test_parser_pipeline_boundary_policy.py
- tests/test_parser_pipeline_hierarchy.py
- tests/test_parser_pipeline_module_index.py
- tests/test_parser_pipeline_module_parser.py
- tests/test_parser_pipeline_family_inference.py
- tests/test_manual_ir_builder.py
- tests/test_ai_agent_manual_context.py

工作方式要求：
- 每次先读相关代码，再分析。
- 不要马上修改代码。
- 先给出问题分析和修改方案。
- 等我确认方案后，再进行代码修改。
- 修改必须小步推进，尽量补测试。
- 不要一次性大改很多模块。
- 不要强行补完预留接口。
- 不要把 parser / Manual IR 的核心逻辑交给 LLM 推断。

当我提出新问题时，请先说明：
1. 你理解的问题是什么。
2. 你准备查看哪些文件。
3. 你初步判断可能影响 parser 层、Manual IR 层，还是只是模板/文档层。
4. 给出修改方案和测试方案。
5. 等我确认后再实现。
```
