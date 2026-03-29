请在当前仓库实现一个独立工具包 cc_header_tools/（不要 import 或复用我之前的结构子 registry / 组件 KB 生成器代码），用于“控制组件注释头（//@cc:）”的生成与校验，并能在 CI 中使用。

### 背景

实验室控制组件（Verilog/SystemVerilog）由多人编写，端口命名与打包方式不统一。我们通过在 module 前添加 YAML-in-comment 注释头来固定契约与端口角色映射，供后续知识库/文档生成使用。

### 目标产物

1) docs/cc_header_spec.md：写入一份可读规范（简洁）
2) templates/cc_headers/：生成 7 个家族的 header 模板文件（.txt 或 .md），分别为：
   - SelSplit, NatSplitN, WaitMergeN, ArbMergeN, MutexMergeN, Fifo1, PmtFifo1
3) Python 包 cc_header_tools/，提供 CLI：
   - python -m cc_header_tools lint --repo . --inputs <files_or_dirs...>
   - python -m cc_header_tools skeleton --repo . --family `<FAMILY>` --file `<path>` [--inplace]
   - python -m cc_header_tools scan --repo . --inputs ...  （列出哪些文件缺 header/不合法）
4) 输出格式：lint 失败时返回非 0；打印明确错误（文件、原因、缺字段/端口不存在等）

### 注释头格式（必须支持）

以连续的行 `//@cc:` 开头，内容为 YAML key/value（允许缩进）。
示例字段：

- schema: cc_header_v1
- name: <module_name>
- family: <one of 7 families>
- params: {...}
- roles: {...}
- contract: {...}

### Lint 校验（MVP 必须实现）

1) 必须存在 //@cc: 块，且 schema=cc_header_v1
2) family 必须属于：SelSplit | NatSplitN | WaitMergeN | ArbMergeN | MutexMergeN | Fifo1 | PmtFifo1
3) roles 中引用的端口名必须存在于 module 端口列表（只需校验顶层端口名；对切片表达式如 i_data[7:0] 只取 i_data 校验）
4) ArbMergeN 必须含 contract.arb_policy 且非空
5) MutexMergeN 必须含 contract.mutex_model=environment_mutex_assumed
6) 若 header 声明了 params.NUM_PORTS 为字面量整数，则要求 roles.inputs/channels 列表 k 的数量一致（否则给 warning）

### 解析要求（轻量鲁棒）

- 先去除 /* */ 和 // 注释用于 module/ports 提取，但要保留 //@cc: 行作为 header 输入
- module/ports 提取可用轻量 regex：module 名 + ANSI 端口声明
- YAML 解析：优先使用 Python 标准库不可用的话就手写一个最小 YAML 子集解析器（只需支持 key/value、缩进 dict、list）

### skeleton 功能

- 给指定文件插入对应 family 的 header 骨架（从 templates/cc_headers 读取）
- 支持 --inplace 写回；否则输出到 stdout

### 工程要求

- Python 3.10+
- 包含最小单元测试：至少对一个示例 verilog（可放 tests/data/）验证 lint 能通过/能发现错误
- 不依赖外部服务/LLM
- 与之前工具完全分离（独立目录、独立输出）


新增 CLI：python -m cc_header_tools autogen --repo . --inputs <dirs/files...> [--inplace] [--only-missing]。
行为：

- 对每个 .v/.sv 文件，若文件顶部不存在 //@cc: 块，则自动生成并插入一个 header。
- header 使用 YAML-in-comment 格式，每行以 //@cc: 开头。
- header 内容必须“保守”：能从解析得到的事实就填；不确定的契约字段写 TODO。
- family 推断按 文件名/module名 pattern
- roles 端口映射：若无法可靠推断，写 TODO 并列出 ports 供人工填写。
- autogen 不能破坏原始代码格式：在 module 前插入即可，保持其余内容不动。
- lint 对 TODO 可配置：默认只 warning；提供 --strict 使 TODO 视为失败（CI 使用 strict）。

你可以分析pipeline文件夹下的文件，需要完成对他们的autogen测试。

请输出所有新增文件的完整内容，确保可直接运行。
