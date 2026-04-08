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
  --repo . \
  --inputs test_data/cpu \
  --tops test_data/cpu/CPU/cpu_top.v test_data/cpu/CPUwithCache.v \
  --output artifacts/parser_pipeline_result
```

输出：

- `artifacts/parser_pipeline_result/project_index.json`
- `artifacts/parser_pipeline_result/modules/<module_name>.json`
- `artifacts/parser_pipeline_result/components/<component_name>.json`
- `artifacts/parser_pipeline_result/build_report.json`

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
