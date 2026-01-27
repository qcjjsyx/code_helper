
你是一个资深 RTL/EDA 工具工程师。请在当前仓库中实现一个“组件知识库生成器（Component Knowledge Base Builder）”，它只负责解析我给定的 7 个 Verilog 组件文件，生成组件级的语义知识库。要求与我之前的“结构子 registry 生成器”完全分离：独立目录、独立包名、独立 CLI、独立输出文件；不得 import 之前的代码（可以选择性读取之前输出的 JSON 作为数据，但不要共享代码实现）。

## 输入文件（仅这 7 个）

- cArbMergeN_modName.v
- cMutexMergeN_modName.v
- cNatSplitN_modName.v
- cSelSplitN_modName.v
- cWaitMergeN_modName.v
- cFifo1_modName.v
- cPmtFifo1_modName.v

这些文件位于仓库中（pipeline文件夹下），你需要通过扫描 inputs 找到它们。

## 目标产物

1) 生成 .docgen/component_kb.json
2) 生成 docs/COMPONENTS.md（按 component_type 分组输出）
3) 支持增量更新：文件 hash 未变则跳过；变更则仅更新该条目
4) 提供 CLI：
   - python -m docgen_components init --repo . --inputs <dir_or_files...>
   - python -m docgen_components update --repo . <changed_files...>
   - python -m docgen_components render --repo . （只渲染 md）

## component_kb.json 的 schema（必须包含）

顶层：

- meta: {generated_at, repo_root, entries_count}

每个条目（按 module name 作为 key 或 entries array 都可）至少包含：

- name: module 名（module xxx）
- file: 相对 repo 路径
- sha256: 文件 hash
- params: 提取 parameter/localparam（name + default_text）
- ports: 端口列表（name, direction, width_text_or_null）
- deps: {components: [...], primitives: [...], tech_cells: [...], unresolved: [...]}
  - components: 实例化到的组件名（如果在这 7 个里）
  - primitives: 实例化到的基础结构子名（sender/relay/receiver/contTap/freeSetDelay/pmtRelay/delay1U/eventSource/eventSink 等；可用白名单/正则判断）
  - tech_cells: INV/XOR/DRNQV/DEL 等工艺单元（按前缀规则归类）
  - unresolved: 不在上述集合里的实例化模块名（如 delay2U 等）
- component_type: 从 name 推断（枚举建议：arb_merge, wait_merge, mutex_merge, nat_split, sel_split, fifo, pmt_fifo）
- contract: 组件行为契约（结构化字段，v1 允许部分字段为空，但 key 必须存在）
  - handshake_style: "pulse_drive_free" 或 "toggle_2phase" 或 "unknown"
  - inputs: [{drive_port, data_port, free_port, index}]
  - outputs: {driveNext_port, data_port, free_port, freeNext_port, extra_ports: [...]}
  - arbitration_policy: 对 cArbMergeN 推断 "lowest-index-first"；其他为 null
  - selection_encoding: 对 cSelSplitN 推断 "one-hot in high bits"；其他为 null
  - join_condition: 对 cWaitMergeN/cNatSplitN 推断 "all-ports-ready"；其他为 null
- customization_guide: 从文件头注释中提取“Instantiation/Modification”段落（若不存在则空）
- semantics_1line: 你根据 component_type 自动填一个一句话描述（可用模板）
- gotchas: string array（用启发式填充：比如 one-hot 必须、*_n 命名歧义、delay 参数影响等；没有就空）
- updated_at: 时间戳
- parse_errors: 若解析失败，记录错误信息但不要崩溃

## 解析要求（轻量但鲁棒）

- 先去掉 // 和 /* */ 注释再做正则解析
- 解析 module header、端口、parameter
- 解析实例化：`<mod>` `<inst>`(...); 并统计依赖
- 对端口方向/位宽无法解析时填 unknown/null，不得崩溃

## 文档输出（docs/COMPONENTS.md）

按 component_type 分组，每个组件输出：

- name / file / params
- ports（简表）
- deps（components/primitives/unresolved）
- contract 的关键字段（inputs/outputs/仲裁或选择或 join）
- customization_guide（若有）

## 代码组织要求

- Python 3.10+
- 包目录：docgen_components/
- __main__.py 支持 python -m docgen_components
- 不依赖外部服务/LLM
- 提供最小单元测试：至少对 2 个文件解析，断言 component_type 与 deps/primitives 不为空

## 规则

1. **新增依赖归一化规则**

* 遇到实例化模块名匹配 `^delay\d+U$`，将其归一化为 `delay1U`，并记录 aliases。

2. **新增字段**

* `deps.primitives_raw` 与 `deps.aliases`

3. **读取 primitive registry（只读 JSON）**

* 若 `.docgen/primitive_registry.json` 存在，则把其中 `name` 集合加载为 `known_primitives`，依赖分类时优先使用它。

请直接输出所有新增文件的完整内容，并确保在 macOS/Linux 可运行。
