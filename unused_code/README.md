# Unused Code

这个目录用于存放当前主流程已经不再使用、但暂时保留以便追溯和参考的代码。

当前已迁入：

- `knowledge/indexes/docgen_components/`
  - 这是早期用于扫描结构子模板、生成 `.docgen/component_kb.json` 与 `docs/COMPONENTS.md` 的旧实现。
  - 现有主流程并不依赖它。
  - 当前结构子 JSON 的生成已经由 `parser/pipeline` 配合 `tools/cc_header_tools` 和 `parser/families` / `parser/schemas` 完成。

- `tests/test_components.py`
  - 这是针对上述旧实现的测试，已一并迁出主测试集。
