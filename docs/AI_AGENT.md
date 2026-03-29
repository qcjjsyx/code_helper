# AI Agent With Qwen

## 目标

`ai_agent/` 的职责不是重新解析 Verilog，而是：

1. 读取 `parser_pipeline` 已生成的 JSON
2. 从中检索与问题最相关的模块和结构子
3. 调用阿里千问 API 生成回答

这样可以把“项目知识抽取”和“AI 问答”两层解耦。

## 依赖

安装：

```bash
pip install -r requirements.txt
```

当前最关键的 Python 依赖是：

- `openai`
  - 用于访问千问兼容 OpenAI 的接口

## 环境变量

推荐在项目根目录创建 `.env`，agent 会自动加载：

```bash
cp .env.example .env
```

然后填入你的真实 key。

也可以直接手工导出环境变量：

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

官方参考：

- [OpenAI compatible - Chat](https://www.alibabacloud.com/help/en/model-studio/compatibility-of-openai-with-dashscope)
- [Get an API key](https://www.alibabacloud.com/help/en/model-studio/get-api-key)

## 命令行

```bash
python -m ai_agent ask \
  --repo . \
  --question "解释 cpu_top 的主要模块组成和关键 event flow"
```

自动生成代码手册：

```bash
python -m ai_agent generate-manual \
  --repo . \
  --top-module cpu_top \
  --output docs/manuals/cpu_top.md
```

也可以输出结构化 JSON：

```bash
python -m ai_agent ask \
  --repo . \
  --question "Fetch_top 由哪些结构子构成" \
  --json
```

## 工作方式

agent 处理问题时会：

1. 加载 `artifacts/parser_pipeline_result/`
2. 对问题做本地检索
3. 选出最相关的模块/结构子 JSON
4. 将这些 JSON 和问题一起发送给千问
5. 返回回答，并附带本轮选用的 artifact 列表

生成代码手册时会：

1. 从 `project_index.json` 找到指定顶层模块
2. 收集该顶层模块可达的模块和派生结构子摘要
3. 组织成结构化上下文
4. 让千问生成 Markdown 手册
5. 按 `--output` 落到本地文件

## 多轮对话

如果你希望在调用层保留一份“上一轮标识”，可以把上一轮返回的 `response_id` 传回去：

```bash
python -m ai_agent ask \
  --repo . \
  --question "继续解释 Fetch_Logic 的 data flow" \
  --previous-response-id "<last_response_id>"
```

## 设计原则

- ground truth 只来自本地 JSON
- 不让模型直接猜 Verilog 细节
- 优先解释模块层级、结构子组成、event/data flow、完成关系
- 如果上下文不足，明确指出缺少哪个 JSON

## 当前实现说明

当前本地实现使用的是阿里官方文档给出的 OpenAI 兼容 `chat.completions` 方式，而不是 `responses` 接口。
这样配置更直接，也更贴近 DashScope 当前公开示例。
