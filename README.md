# Parser Pipeline For Verilog Project Handoff

本仓库当前以 `parser_pipeline` 为主工作流，目标是把工程模块层级、派生结构子、以及关键 event/data flow 自动整理成 JSON，供后续 AI 按需读取并生成代码手册。

## 主工作流

统一入口：

```bash
python -m parser_pipeline build \
  --repo . \
  --inputs CPU \
  --tops CPU/CPU/cpu_top.v CPU/CPUwithCache.v \
  --output parser_pipeline_result
```

参数说明：

- `--repo`：项目根目录
- `--inputs`：扫描范围，可传目录或文件
- `--tops`：要递归展开的顶层模块文件
- `--output`：输出目录，默认 `parser_pipeline_result`

## 输出内容

构建完成后会生成：

- `parser_pipeline_result/project_index.json`
- `parser_pipeline_result/modules/<module_name>.json`
- `parser_pipeline_result/components/<component_name>.json`
- `parser_pipeline_result/build_report.json`

其中：

- `project_index.json`：项目级索引、顶层入口、层级树摘要、统计信息
- `modules/*.json`：普通工程模块的接口、实例、局部信号、flow graph、传递摘要
- `components/*.json`：派生结构子的 family 模板映射、contract、flow 语义

## 目录说明

- `parser_pipeline/`
  - 新的主实现
- `parser_pipeline_result/`
  - 生成结果
- `JSON_Template/family_level.json`
  - 派生结构子 family 语义模板
- `test/`
  - 新工作流测试
- `cc_header_tools/`
  - 旧的 `//@cc:` 头工具，当前保留作为辅助工具
- `docgen_components/`
  - 旧组件知识库代码，当前仅保留作参考，不是主运行链路

## `cc_header_tools`

如果你仍然需要为 `pipeline/` 或其他派生结构子文件维护 `//@cc:` 头，可继续使用：

```bash
python -m cc_header_tools autogen --repo . --inputs pipeline --only-missing --inplace
python -m cc_header_tools lint --repo . --inputs pipeline
```

当前行为：

- 对能识别出 family 的文件生成/校验 header
- 对普通模块默认跳过，不强制要求存在 `//@cc:`

## 测试

运行当前主测试集：

```bash
pytest
```

`pytest.ini` 已固定 `pythonpath = .`，并同时收集 `tests/` 与 `test/`。

## 推荐的 AI 交互方式

生成代码手册时，推荐按需提供 JSON：

1. 先提供 `project_index.json`
2. 再提供当前正在讲解的顶层或子模块 JSON
3. 当 AI 需要细看某个子模块或结构子时，再补对应 JSON

这样可以减少上下文噪声，也更适合项目持续演进。
