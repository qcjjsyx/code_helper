# Verilog Project Parser And Qwen Agent

本仓库现在分成 5 类内容：

- `parser_pipeline/`、`ai_agent/`、`cc_header_tools/`、`docgen_components/`、`verilog_parser/`
  - Python 代码
- `test_data/`
  - 示例 Verilog 工程、结构子模板、测试样本
- `tests/`
  - 自动化测试
- `docs/`
  - 项目文档
- `docs/notes/`
  - 历史说明、需求记录、设计草稿
- `artifacts/`
  - 生成结果

## 目录说明

- `parser_pipeline/`
  - 顶层模块到模块/派生结构子 JSON 的主工作流
- `ai_agent/`
  - 基于阿里千问 API 的项目问答 agent
- `cc_header_tools/`
  - `//@cc:` 头生成与校验
- `docgen_components/`
  - 旧组件知识库代码，仅保留作参考
- `verilog_parser/`
  - 旧轻量解析器
- `test_data/cpu/`
  - CPU 示例工程
- `test_data/base/`
  - primitive 示例数据
- `test_data/pipeline/`
  - 派生结构子模板数据
- `tests/fixtures/verilog/`
  - 单元测试夹具
- `artifacts/parser_pipeline_result/`
  - `parser_pipeline` 生成的 JSON
- `artifacts/verilog_parser_outputs/`
  - 旧 `verilog_parser` 的输出
- `config/json_templates/`
  - JSON 模板
- `config/cc_headers/`
  - `//@cc:` header 模板

## Parser Pipeline

统一入口：

```bash
python -m parser_pipeline build \
  --repo . \
  --inputs test_data/cpu \
  --tops test_data/cpu/CPU/cpu_top.v test_data/cpu/CPUwithCache.v \
  --output artifacts/parser_pipeline_result
```

输出内容：

- `artifacts/parser_pipeline_result/project_index.json`
- `artifacts/parser_pipeline_result/modules/<module_name>.json`
- `artifacts/parser_pipeline_result/components/<component_name>.json`
- `artifacts/parser_pipeline_result/build_report.json`

## Qwen AI Agent

Agent 基于 `parser_pipeline` 结果做本地检索，再调用千问 API 回答问题。

推荐先在项目根目录准备 `.env`：

```bash
cp .env.example .env
```

然后填写：

```env
DASHSCOPE_API_KEY=your_api_key
QWEN_MODEL=qwen-plus
QWEN_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
```

也可以直接手工导出环境变量：

```bash
export DASHSCOPE_API_KEY="your_api_key"
export QWEN_MODEL="qwen-plus"
export QWEN_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
```

### AI 命令行用法

1. 问答模式

```bash
python -m ai_agent ask \
  --repo . \
  --question "解释 cpu_top 的整体层级，以及 Fetch_top 为什么能完成取指"
```

2. 输出 JSON 格式结果

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
  - 指定 JSON 目录，默认 `artifacts/parser_pipeline_result`
- `--model`
  - 覆盖默认模型
- `--base-url`
  - 覆盖 API 地址
- `--previous-response-id`
  - 继续上一轮对话
- `--json`
  - 返回结构化输出
- `--output`
  - 仅 `generate-manual` 使用，指定生成的 Markdown 文件路径

更多说明见 [AI_AGENT.md](/Users/huangyuan/qcjjsyx/AI_Agent/code_helper/docs/AI_AGENT.md)。

## `cc_header_tools`

如果你仍然需要为派生结构子文件维护 `//@cc:` 头，可继续使用：

```bash
python -m cc_header_tools autogen --repo . --inputs test_data/pipeline --only-missing --inplace
python -m cc_header_tools lint --repo . --inputs test_data/pipeline
```

当前行为：

- 对能识别出 family 的文件生成/校验 header
- 对普通模块默认跳过，不强制要求存在 `//@cc:`

## 测试

安装依赖后运行：

```bash
pytest
```

`pytest.ini` 当前固定：

- `pythonpath = .`
- `testpaths = tests`

## 推荐的 AI 交互方式

生成代码手册时，推荐按需提供 JSON：

1. 先提供 `project_index.json`
2. 再提供当前正在讲解的顶层或子模块 JSON
3. 当 AI 需要细看某个子模块或结构子时，再补对应 JSON

这样可以减少上下文噪声，也更适合项目持续演进。
