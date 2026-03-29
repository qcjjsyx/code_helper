请在当前仓库实现一个独立工具包 verilog_parser/（无外部依赖），核心功能为解析指定Verilog顶层文件，精准提取两类核心信息：
1. 顶层文件中定义的**顶层module名称**（如cpu_top）；
2. 该顶层module内部实例化的**所有结构子名称**（如Fetch_top、idu_top、exe_top等）。

### 背景
需解析仓库中CPU目录下的Verilog文件（如code_helper\CPU\CPU\cpu_top.v），快速提取顶层module名和其内部实例化的子模块名称，用于模块依赖梳理，无需复杂语法校验，仅聚焦名称提取。

### 目标产物
1) Python 包 verilog_parser/，提供CLI入口：
   - python -m verilog_parser parse --file <文件路径> [--output <输出路径>] [--format json/text]
   - 无--output时输出到stdout；支持json（机器可读）/text（人工可读）两种格式。
2) 输出核心内容（以cpu_top.v为例）：
   - 顶层module名：cpu_top；
   - 内部结构子名称列表：Fetch_top、idu_top、exe_top、lsu_top、mem_slot、writeBack。

### 核心解析规则
1. 文件适配：仅解析.v格式文件，自动忽略所有注释（// 单行、/* */ 多行）；
2. 顶层module提取规则：
   - 匹配Verilog中"module 名称"的声明语句（如module cpu_top），仅提取第一个/唯一的顶层module名称；
   - 排除嵌套module、interface等其他结构，仅保留最外层的顶层module名；
3. 结构子名称提取规则：
   - 匹配顶层module内部的子模块实例化语句（如Fetch_top u_Fetch_top();、idu_top u_idu_top();）；
   - 仅提取实例化语句中的**子模块类型名**（如Fetch_top、idu_top，而非实例别名u_Fetch_top）；
   - 去重处理：同一子模块多次实例化仅保留一次名称；
4. 容错处理：
   - 无顶层module时，标注「未识别到顶层module」；
   - 顶层module内无子模块实例化时，标注「无内部结构子名称」。

### 工程要求
- Python 3.10+，仅依赖Python标准库（re/os/sys等内置库），无第三方依赖；
- 工具独立：所有代码放在verilog_parser/目录下，不修改仓库其他文件；
- 错误处理（返回对应退出码+明确提示）：
  - 退出码1：文件不存在（提示：Error: 文件不存在 - <文件路径>）；
  - 退出码2：非.v格式文件（提示：Error: 仅支持.v格式文件 - <文件路径>）；
  - 退出码3：文件为空/无法读取（提示：Error: 文件读取失败 - <文件路径>）。

### 输出格式要求
- text格式示例（cpu_top.v解析结果）：
  解析文件：code_helper\CPU\CPU\cpu_top.v
  顶层module名称：cpu_top
  内部结构子名称（共6个）：
    1. Fetch_top
    2. idu_top
    3. exe_top
    4. lsu_top
    5. mem_slot
    6. writeBack
- json格式示例（cpu_top.v解析结果）：
  {
    "parsed_file": "code_helper\\CPU\\CPU\\cpu_top.v",
    "top_module_name": "cpu_top",
    "internal_subnames": ["Fetch_top", "idu_top", "exe_top", "lsu_top", "mem_slot", "writeBack"]
  }

### 测试要求
- 在tests/data/目录下放测试文件cpu_top.v（包含cpu_top模块及对应子模块实例化）；
- 单元测试需验证：正确提取顶层module名+所有内部结构子名称，无遗漏、无错误匹配。