# Verilog Project Parser And Qwen Agent

这个项目的目标是把 Verilog/SystemVerilog 项目解析成结构化 JSON，再基于这些 JSON 让 AI agent 回答问题、生成代码手册，并为后续扩展打基础。

目前项目主要包含 5 个部分：

- `parser_pipeline/`
  - 递归解析 Verilog 工程
  - 生成模块级、结构子级、项目级 JSON
- `ai_agent/`
  - 读取 `parser_pipeline` 产物
  - 检索相关 artifact
  - 调用 Qwen API 生成问答或代码手册
- `cc_header_tools/`
  - 为控制结构子生成和校验 `//@cc:` 注释头
- `docgen_components/`
  - 对组件模板、组件知识进行整理
- `verilog_parser/`
  - 提供底层 Verilog 解析能力

辅助目录：

- `test_data/`: 测试用 Verilog 样例工程
- `tests/`: 单元测试与集成测试
- `docs/`: 项目说明文档
- `artifacts/`: 解析产物和生成结果

## 当前项目结构

- `parser_pipeline/`
  - 负责从输入工程中提取模块、实例、连接、层级、flow graph 等信息
- `ai_agent/`
  - 负责基于结构化 JSON 做检索和生成
- `cc_header_tools/`
  - 负责 `//@cc:` header 的补全、校验和扫描
- `docgen_components/`
  - 负责组件模板和文档辅助生成
- `verilog_parser/`
  - 负责底层文本解析
- `test_data/cpu/`
  - CPU 相关样例工程
- `test_data/base/`
  - primitive 基础组件
- `test_data/pipeline/`
  - 典型控制结构子模板
- `tests/fixtures/verilog/`
  - 解析测试样例
- `artifacts/parser_pipeline_result/`
  - `parser_pipeline` 输出的标准 JSON
- `artifacts/verilog_parser_outputs/`
  - `verilog_parser` 的输出结果
- `config/json_templates/`
  - JSON 模板配置
- `config/cc_headers/`
  - `//@cc:` header 模板

## Parser Pipeline

执行：

```bash
python -m parser_pipeline build \
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

## Qwen AI Agent

Agent 不直接重新解析 Verilog，而是读取 `parser_pipeline` 已经生成好的 JSON，并基于这些结构化信息进行问答或生成代码手册。

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

也可以直接导出：

```bash
export DASHSCOPE_API_KEY="your_api_key"
export QWEN_MODEL="qwen-plus"
export QWEN_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
```

### AI 使用方式

1. 结构问答

```bash
python -m ai_agent ask \
  --repo . \
  --question "解释 cpu_top 的主要模块组成，以及 Fetch_top 的关键事件流"
```

2. 输出结构化 JSON

```bash
python -m ai_agent ask \
  --repo . \
  --question "Fetch_top 由哪些结构子构成" \
  --json
```

3. 生成代码手册

```bash
python -m ai_agent generate-manual \
  --repo . \
  --top-module cpu_top \
  --output docs/manuals/cpu_top.md
```

可选参数：

- `--artifacts-root`
  - 指定 JSON 产物目录，默认 `artifacts/parser_pipeline_result`
- `--model`
  - 指定模型名称
- `--base-url`
  - 指定 API 地址
- `--previous-response-id`
  - 继续上一轮对话
- `--json`
  - 结构化输出
- `--output`
  - `generate-manual` 的 Markdown 输出路径

详细说明见 [AI_AGENT.md](/e:/code_helper/docs/AI_AGENT.md)。

## `cc_header_tools`

用于为控制结构子补全并校验 `//@cc:` 注释头：

```bash
python -m cc_header_tools autogen --repo . --inputs test_data/pipeline --only-missing --inplace
python -m cc_header_tools lint --repo . --inputs test_data/pipeline
```

主要能力：

- 根据 family 自动生成基础 header
- 校验 header 中端口、契约、字段是否合法

## 测试

执行：

```bash
pytest
```

`pytest.ini` 中当前配置：

- `pythonpath = .`
- `testpaths = tests`

## 当前 agent 的基本工作流

自动问答或生成手册时，系统会：

1. 加载 `project_index.json`
2. 按模块和结构子 JSON 构建知识库
3. 根据问题或目标模块选择相关 JSON
4. 将这些结构化上下文送给模型

当前版本已经能完成“结构抽取 + 检索 + 初步生成”的闭环，但距离“高质量、结构子粒度的代码手册 agent”还有明显差距，后续需要继续增强：

- 面向手册生成的中间表示层
- 更细粒度的检索与重排
- 多阶段 agent 编排
- 可扩展的 external dependency 接入机制
