# AI Agent With Qwen

## 目标

`ai_agent/` 的职责不是重新解析 Verilog，而是：

1. 读取 `parser_pipeline` 生成的 JSON
2. 检索与问题最相关的模块和结构子
3. 调用 Qwen API 生成回答或代码手册

这样可以把“项目知识抽取”和“AI 生成”解耦。

## 依赖

安装：

```bash
pip install -r requirements.txt
```

关键依赖：

- `openai`
  - 用于访问 DashScope 提供的 OpenAI 兼容接口

## 环境变量

推荐在项目根目录创建 `.env`：

```bash
cp .env.example .env
```

也可以直接导出环境变量：

```bash
export DASHSCOPE_API_KEY="your_api_key"
export QWEN_MODEL="qwen-plus"
export QWEN_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
```

说明：

- `DASHSCOPE_API_KEY`
  - 必填
- `QWEN_MODEL`
  - 默认 `qwen-plus`
- `QWEN_BASE_URL`
  - 默认 DashScope OpenAI 兼容地址

参考：

- [OpenAI compatible - Chat](https://www.alibabacloud.com/help/en/model-studio/compatibility-of-openai-with-dashscope)
- [Get an API key](https://www.alibabacloud.com/help/en/model-studio/get-api-key)

## 命令行

问答：

```bash
python -m ai_agent ask \
  --repo . \
  --question "解释 cpu_top 的主要模块组成和关键 event flow"
```

自动生成手册：

```bash
python -m ai_agent generate-manual \
  --repo . \
  --top-module cpu_top \
  --output docs/manuals/cpu_top.md
```

结构化 JSON 输出：

```bash
python -m ai_agent ask \
  --repo . \
  --question "Fetch_top 由哪些结构子构成" \
  --json
```

## 当前工作方式

处理问题时：

1. 加载 `artifacts/parser_pipeline_result/`
2. 构建本地知识库
3. 根据问题检索相关模块和结构子
4. 将相关 JSON 和问题一起发给模型
5. 返回答案，并附带本轮使用的 artifact 列表

生成手册时：

1. 根据 `project_index.json` 找到指定顶层模块
2. 收集该顶层模块可达的模块和结构子摘要
3. 组织成结构化上下文
4. 交给模型生成 Markdown
5. 写入 `--output`

## 多轮对话

如果你希望保留上下文，可以把上一轮返回的 `response_id` 传回去：

```bash
python -m ai_agent ask \
  --repo . \
  --question "继续解释 Fetch_Logic 的 data flow" \
  --previous-response-id "<last_response_id>"
```

## 设计原则

- ground truth 只来自本地 JSON
- 不让模型直接猜 Verilog 实现细节
- 优先解释模块层级、结构子组成、event/data flow、完成关系
- 如果上下文不足，明确指出缺失的 JSON

## 当前实现说明

当前实现使用的是 DashScope 提供的 OpenAI 兼容 `chat.completions` 接口，而不是 `responses` 接口。这样配置更直接，也更接近官方公开示例。
