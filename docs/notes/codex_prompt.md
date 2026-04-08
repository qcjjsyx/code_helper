# 历史提示词草稿

这个文件保留一份早期需求草稿，用于说明 `cc_header_tools` 最初是如何被提出的。

核心目标如下：

1. 实现一个独立工具包 `cc_header_tools/`
2. 为控制结构子生成 `//@cc:` YAML-in-comment 注释头
3. 提供 `lint`、`scan`、`autogen/skeleton` 等 CLI
4. 支持在 CI 中校验 header 的完整性和合法性
5. 不依赖外部服务或 LLM

约束点：

- `//@cc:` 必须出现在 `module` 声明之前
- family 必须落在既定集合中
- roles 中引用的端口必须能在模块端口列表里找到
- `ArbMergeN`、`MutexMergeN` 等 family 有额外契约要求
- `TODO` 默认作为 warning，`--strict` 模式下视为错误

这份草稿现在主要作为背景记录，不再作为当前实现的唯一规范。当前生效规范请以 [cc_header_spec.md](/e:/code_helper/docs/cc_header_spec.md) 和代码实现为准。
