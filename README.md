# Verilog 原始模块注册表与控制组件头工具

本项目包含轻量级 Verilog 原始模块注册表生成器和选定流水线组件的知识库构建器。

## 命令使用说明

### 1. 原始模块注册表生成器（docgen_sv_primitive）

生成 Verilog 原始模块的注册表和文档。

```bash
# 初始化：扫描 base 目录下所有 Verilog 文件，生成初始注册表
python -m docgen_sv_primitive init --repo . --inputs base

# 更新：当某个文件修改后，更新该文件对应的注册信息
python -m docgen_sv_primitive update --repo . base/<changed_file.v>

# 渲染：生成最终的文档（PRIMITIVES.md）和注册表 JSON
python -m docgen_sv_primitive render --repo .
```

**参数说明：**
- `--repo`：项目根目录
- `--inputs`：要扫描的目录

### 2. 组件知识库构建器（docgen_components）

为流水线组件生成知识库和文档。

```bash
# 初始化：扫描 pipeline 目录，生成组件知识库
python -m docgen_components init --repo . --inputs pipeline

# 初始化（强制覆盖）：即使已存在也重新生成
python -m docgen_components init --repo . --inputs pipeline --force

# 更新：单个文件修改后更新知识库
python -m docgen_components update --repo . pipeline/<changed_file.v>

# 更新（强制覆盖）：强制覆盖该文件的知识库数据
python -m docgen_components update --repo . pipeline/<changed_file.v> --force

# 渲染：生成最终的组件文档（COMPONENTS.md）和知识库 JSON
python -m docgen_components render --repo .
```

**参数说明：**
- `--repo`：项目根目录
- `--inputs`：要扫描的目录
- `--force`：强制重新生成，覆盖已存在的数据

### 3. 控制组件头工具（cc_header_tools）

为控制组件生成、验证和管理 `//@cc:` YAML 注释头。

#### 3.1 检验头部合法性（lint）

```bash
# 检验 pipeline 目录下所有文件的 CC 头是否符合规范
python -m cc_header_tools lint --repo . --inputs pipeline

# 严格模式：把 TODO 字段当错误而非警告
python -m cc_header_tools lint --repo . --inputs pipeline --strict
```

**检验规则：**
- `//@cc:` 块必须存在且 `schema` 为 `cc_header_v1`
- `family` 必须是 7 种之一（ArbMergeN、MutexMergeN、SelSplit、NatSplitN、WaitMergeN、Fifo1、PmtFifo1）
- `roles` 中引用的端口必须在模块端口列表中存在
- `ArbMergeN` 必须定义 `contract.arb_policy`
- `MutexMergeN` 必须定义 `contract.mutex_model=environment_mutex_assumed`
- 若 `params.NUM_PORTS` 是整数，则 `roles.inputs/channels` 数量必须相匹配
- `TODO` 字段默认为警告，严格模式下为错误

#### 3.2 扫描问题文件（scan）

```bash
# 列出所有包含错误的文件路径（不显示具体错误信息）
python -m cc_header_tools scan --repo . --inputs pipeline
```

**用途：** 快速找出需要修复的文件列表。

#### 3.3 插入头骨架（skeleton）

```bash
# 为指定文件手动插入对应家族的 CC 头骨架
python -m cc_header_tools skeleton --repo . --family MutexMergeN \
  --file pipeline/cMutexMerge2.v --inplace
```

**工作流程：**
1. 读取 templates/cc_headers/{family}.txt 模板
2. 将模板插入到文件的 `module` 关键字前
3. `--inplace` 直接修改文件，否则输出到 stdout

**适用场景：** 新增模块时手动插入头骨架，需要逐一填写字段。

#### 3.4 自动生成头部（autogen）

```bash
# 为所有缺少 CC 头的文件自动生成
python -m cc_header_tools autogen --repo . --inputs pipeline --only-missing --inplace

# 对所有文件强制重新生成（会删除旧头，适合修改头模板后重新生成）
python -m cc_header_tools autogen --repo . --inputs pipeline --inplace --force

# 预览模式：输出到 stdout，不修改文件
python -m cc_header_tools autogen --repo . --inputs pipeline
```

**自动生成规则：**
- 扫描所有 Verilog 文件
- 自动推断模块名、端口、家族（根据文件名和模块名）
- 填充 schema、name、family、params 等字段
- 不可推断的字段标记为 `TODO`
- 按模板格式生成完整的 `//@cc:` 头

**参数说明：**
- `--only-missing`：仅处理缺少 CC 头的文件（默认跳过已有头的文件）
- `--force`：强制覆盖已存在的头（测试阶段修改头字段时使用）
- `--inplace`：直接修改文件，否则输出到 stdout
- `--strict`：生成后进行严格 lint 检验，错误返回非零状态码

#### 3.5 删除头部（strip）

```bash
# 移除所有文件的 //@cc: 头
python -m cc_header_tools strip --repo . --inputs pipeline --inplace

# 预览模式：输出不带头的文件内容
python -m cc_header_tools strip --repo . --inputs pipeline
```

**用途：** 测试或重置阶段，清除旧头后重新生成。

## 输出文件

- `.docgen/primitive_registry.json`：原始模块注册表数据
- `docs/PRIMITIVES.md`：分组的原始模块文档
- `docs/REGISTRY_SCHEMA.md`：注册表字段说明
- `.docgen/component_kb.json`：组件知识库数据
- `docs/COMPONENTS.md`：分组的组件文档
- `docs/cc_header_spec.md`：CC 头规范文档
- `templates/cc_headers/*.txt`：7 个家族的 CC 头模板文件

## 配置

在 `docgen_sv/config.json` 中覆盖分类和模块属性：

```json
{
  "kind_overrides": {
    "MyModule": "component"
  },
  "category_overrides": {
    "MyModule": "custom_category"
  }
}
```

## 工作流示例

### 新增一个控制组件的典型流程

1. **编写 Verilog 模块** → 文件名中包含家族标识（如 cMutexMerge2.v）

2. **自动生成 CC 头**
   ```bash
   python -m cc_header_tools autogen --repo . --inputs pipeline --inplace
   ```

3. **验证并编辑 CC 头**
   ```bash
   python -m cc_header_tools lint --repo . --inputs pipeline --strict
   ```

4. **发现问题后修复并重新生成**
   ```bash
   python -m cc_header_tools strip --repo . --inputs pipeline --inplace
   python -m cc_header_tools autogen --repo . --inputs pipeline --inplace --force
   ```

5. **最终验证**
   ```bash
   python -m cc_header_tools lint --repo . --inputs pipeline --strict
   ```

