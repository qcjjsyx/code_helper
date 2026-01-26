你是一个资深 EDA/RTL 工程工具开发者。请在当前工程中实现一个“结构子注册表生成器（Primitive Registry Builder）”，用于扫描并解析我项目中上传的 11 个 Verilog 文件（基础结构子/基础组件），生成并维护一个结构化注册表文件。请严格按以下要求实现，不要写多余解释，直接输出可运行的代码文件与必要的 README。

### 目标与产物

1. 生成 `.docgen/primitive_registry.json`（或 `.yaml`，优先 json），记录每个结构子/组件的条目。
2. 支持增量更新：当文件内容未变化时跳过；变化时仅更新相关条目。
3. 生成 `docs/PRIMITIVES.md`（Markdown）：按 `category` 分组输出每个条目的信息（v1 简版）。
4. 提供命令行入口：
   - `python -m docgen_sv init --repo <path> --inputs <file_or_dir...>`
   - `python -m docgen_sv update --repo <path> <changed_file...>`
   - `python -m docgen_sv render --repo <path>`（仅从 registry 渲染文档，不重新解析）
5. 提供 `docs/REGISTRY_SCHEMA.md`：解释 registry 字段含义（简洁即可）。

### 输入范围（你必须覆盖）

这些 Verilog 文件已存在于项目（路径以实际 repo 为准，你需要通过扫描发现；但它们的文件名如下）：

- sender.v
- receiver.v
- relay.v
- contTap.v
- delay1U.v
- eventSource.v
- cFifo1.v
- pmtRelay.v
- freeSetDelay.v
- eventSink.v
- cPmtFifo1.v

说明：其中 `cFifo1` / `cPmtFifo1` 属于“基础组件（component）”，其余属于“结构子（primitive）”。但 registry 里统一用字段 `kind` 来区分：`primitive` 或 `component`。

### 注册表字段（必须实现）

每个条目至少包含：

- `name`: module 名（从 `module <name>` 解析）
- `kind`: `"primitive"` 或 `"component"`（见后文分类规则）
- `file`: 相对 repo 根目录的路径
- `sha256`: 文件内容 hash
- `language`: 固定 `"verilog"`
- `ports`: 端口列表数组；每个端口包含 `{name, direction, width}`
  - `direction` 解析 `input/output/inout`；若无明确方向就写 `"unknown"`
  - `width` 若无法解析就写 `null`；能解析就写类似 `"[7:0]"` 或整数位宽
- `params`: 参数列表数组（名称 + 默认值文本）；解析 `parameter` / `localparam`（能拿多少拿多少，解析失败可空）
- `deps_primitives`: 该模块实例化了哪些“本项目结构子/组件”的模块名（不含工艺库单元）
- `tech_cells`: 该模块实例化的“工艺库单元/标准单元”（例如 INV*/XOR*/DRNQV*/DEL* 等），以模块名列表形式记录
- `reset`: `{present: bool, signal: string|null, active_low: bool|null}`
  - 若端口存在 `rstn` 或 `resetn` 等低有效 reset 名称，设为 `present=true`；否则 false
- `category`:（v1 可先按规则自动填默认；允许 `"unknown"`）
- `protocol`:（v1 允许 `"unknown"`）
- `port_roles`: dict，把端口名映射到角色（v1 可留空 `{}`）
- `semantics_1line`:（v1 允许空字符串）
- `constraints`: string array（v1 可空）
- `gotchas`: string array（v1 可空）
- `updated_at`: ISO 时间戳

registry 顶层还需要 `meta`：

- `generated_at`
- `repo_root`
- `entries_count`

### 分类规则（必须实现）

- 如果 `name` 以 `c` 开头且文件名包含 `Fifo`（如 cFifo1/cPmtFifo1），默认 `kind="component"`；否则 `kind="primitive"`。
- 但允许用户在 `docgen_sv/config.json` 中覆盖分类（你需要实现 config 覆盖机制，默认配置可自动生成）。
- `category` 自动填充的默认规则（v1 简单即可）：
  - name 包含 `Relay` → `handshake_relay`
  - name 包含 `Fifo` → `base_pipeline`
  - name 包含 `delay` 或 `Delay` → `delay`
  - name 包含 `event` 或 `Event` → `event`
  - name 包含 `Tap` → `toggle`
  - 否则 `"unknown"`

### 解析要求（鲁棒性优先，v1 可轻量）

不要引入重量级 SV parser。v1 使用“轻量解析”即可，但要满足：

- 能正确识别 `module ... ( ... );` 的模块名
- 能从 ANSI 风格端口声明中解析端口方向与位宽（常见写法）
- 能识别实例化语句：`<mod> <inst>(...);` 或 `<mod> <inst> (...);`
- 能忽略注释与字符串中的误命中（至少要先去掉 `//` 与 `/* */` 注释再做正则）
- 对于解析失败的文件：不得崩溃；要记录 `parse_errors` 到条目里（新增字段允许），并继续处理其他文件

### 增量更新要求（必须实现）

- registry 存储在 `.docgen/primitive_registry.json`
- `init`：全量扫描 inputs（文件/目录），生成/更新全部条目
- `update <changed_files...>`：仅对指定文件重新计算 hash 并重建该条目；然后重渲染 docs
- 如果文件被删除：registry 标记 `deleted=true`（新增字段）并在文档中注明

### 文档输出（必须实现）

生成 `docs/PRIMITIVES.md`，按 category 分组，每个条目输出：

- name、kind、file
- ports（列表）
- deps_primitives、tech_cells（列表）
- reset 信息
- semantics_1line（若为空就不输出）

### 代码结构与质量要求

- Python 实现（3.10+），不要依赖外部服务/LLM
- 代码组织成包：`docgen_sv/`，包含 `__main__.py` 便于 `python -m docgen_sv ...`
- 需要有单元测试：至少测试 2 个文件解析（可以用项目内真实文件路径）
- 必须在 macOS/Linux 上可运行
- 所有输出路径使用 repo_root 相对路径，并确保目录存在

### 验收标准

运行：

- `python -m docgen_sv init --repo . --inputs src test rtl .`（inputs 允许包含 repo 根目录）
   应能在 `.docgen/` 和 `docs/` 下生成上述文件，且 registry 里至少包含 11 个条目（或更多，如果目录里有更多 `.v`）。

请开始实现：输出所有新增/修改的文件内容（完整文件），并确保可直接运行。