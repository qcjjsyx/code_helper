# `cpu_top` 代码手册（异步流水线架构）

> **本手册面向新接手该异步 CPU 项目的工程师**，聚焦于快速建立系统级认知。所有内容严格基于提供的 JSON 上下文生成，不引入外部假设或未验证实现细节。

---

## 模块概览

`cpu_top` 是整个异步 RISC-V CPU 的**顶层模块**，采用**事件驱动（event-driven）+ 数据分离（data-split）** 的异步设计范式，无全局时钟信号，依赖 `drive`/`free` 握手协议协调各子模块间通信。

### 核心特征

| 维度 | 描述 |
|------|------|
| **架构风格** | 全异步、无时钟（clockless）、基于握手的流水线（fetch → decode → execute → memory → retire） |
| **通信协议** | `drive`（请求/启动） + `free`（释放/完成）双线握手；`data` 信号仅在 `drive` 有效时携带有效载荷 |
| **数据通路宽度** | 多级可变宽：IFU→IDU（97b）、IDU→EXE（343b）、EXE→LSU（246b）、LSU→WB（246b）、WB→GRF/CSR（69b/76b）等，体现功能定制化 |
| **关键外设接口** | TPU（Tensor Processing Unit）、TS（Trace System）、I-cache、D-cache、Mem（统一内存总线） |
| **重置机制** | 同步低电平复位（`rst` active-low），所有模块均接入 `rst` |

### 主要职责

- **集成中枢**：连接并协调 Fetch、IDU、EXE、LSU、WB、Mem 子系统；
- **跨域桥接**：提供 TPU/TS/Icache/Dcache/Mem 等外部模块的标准化握手接口；
- **事件路由与仲裁**：通过 `cMutexMerge`/`cArbMerge`/`cSelSplit` 等结构子实现多源事件合并、选择与广播；
- **背压传播**：将下游 `free` 信号逐级反向传递至源头，形成天然流控闭环。

> ✅ **关键认知**：这不是传统同步 CPU 的“取指-译码-执行”单周期模型，而是一个由**事件流驱动、数据流承载、背压流约束**的三维异步系统。理解 `drive`/`free` 的生命周期比理解“时序”更重要。

---

## 层级结构

`cpu_top` 构成一个清晰的五级流水线主干 + 外设桥接层：

```text
                            ┌───────────────────┐
                            │     cpu_top       │ ← Top-level integration & I/O
                            └────────┬──────────┘
                                     │
          ┌───────────────┐   ┌──────▼──────┐   ┌──────────────┐   ┌──────────────┐
          │   Fetch_top   │   │   idu_top   │   │   exe_top    │   │   lsu_top    │
          │ (IFU)         │   │ (Decoder +  │   │ (ALU/AGU/    │   │ (Load/Store  │
          └───────┬───────┘   │  GRF/CSR)   │   │  BRU/etc.)   │   │  Unit)       │
                  │           └───────┬─────┘   └───────┬──────┘   └───────┬──────┘
                  │                   │                 │                  │
                  └───────────────────┼─────────────────┼──────────────────┘
                                      │                 │
                              ┌───────▼──────┐   ┌──────▼──────┐
                              │  mem_slot    │   │  writeBack  │
                              │ (Memory Arb  │   │ (Retire +   │
                              │  & Format)   │   │  Writeback) │
                              └──────────────┘   └─────────────┘
```

### 直接子模块说明（按数据流向）

| 模块名 | 角色 | 关键输入/输出信号（缩写） | 备注 |
|--------|------|---------------------------|------|
| `Fetch_top` | 取指单元（IFU） | `i_driveFromTPUtoCPU`, `o_dataCPUtoTS_128`, `o_dataFetchtoDecoder_97` | 接收 TPU 指令、发往 TS 跟踪、输出给 IDU；含 `cMutexMerge_2_WB` 处理 WB 回馈 |
| `idu_top` | 译码与寄存器读取（IDU） | `i_dataFetchtoDecoder_97`, `o_dataToExe_343`, `o_driveWbToGrf` | 包含 `grf`/`csrf`，使用 `cFifo1_idu` 缓冲指令流 |
| `exe_top` | 执行单元（EXE） | `i_decoderExeBus_343`, `o_exeLSUBus_246`, `o_driveNextToLsu` | 含 ALU/AGU/BRU 等功能单元，通过 `cSelSplit_6_exe` 分发到不同执行路径 |
| `lsu_top` | 加载/存储单元（LSU） | `i_dataFromExe_246`, `o_dataToMem_136`, `o_dataToRetire_246` | 处理访存请求格式化（`lsu_memReqFormat_comb`）、仲裁（`cArbMerge2_lsu`） |
| `mem_slot` | 内存桥接与仲裁（MEM） | `i_dataLSUtoMem_136`, `o_dataMemtoIcache_136`, `o_dataMemtoDcache_136` | 统一处理 IFU/Dcache/LSU 的访存请求，含 `cArbMerge_2_memslot` |
| `writeBack` | 写回与退休（WB） | `i_dataLSUToWb_246`, `o_dataWbToGrf_69`, `o_dataWbToFetch_64` | 将 LSU 结果写回 GRF/CSR，并反馈异常/跳转信息给 Fetch |

> ⚠️ 注意：`mem_slot` 不是传统意义上的“内存控制器”，而是**访存请求聚合器与格式转换器**，它本身不包含存储阵列，只负责将来自 IFU/LSU/Icache/Dcache 的请求分发到真实内存（外部）并返回响应。

---

## 关键结构子与作用

`cpu_top` 及其子模块大量复用一组标准化的异步结构子（components），它们是理解数据/事件流的关键“积木”。以下为最核心的 5 类：

| 结构子名 | 所属家族 | 核心语义 | 典型用途 | 在 `cpu_top` 中出现次数 |
|----------|-----------|------------|-------------|--------------------------|
| `cFifo1_*` | `Fifo1` | **非重入式 FIFO**：上游 `i_drive` → 下游 `o_driveNext`；上游 `o_free` 仅在收到下游 `i_freeNext` 后发出 | 流水线级缓冲、隔离时序域、吸收突发流量 | ≥ 8（`cFifo1_cpu`, `cFifo1_idu`, `cFifo1_lsu` 等） |
| `cSelSplit_*` | `SelSplit` | **条件选择分发**：根据 `valid[k]` 信号，将上游 `i_drive` 事件**单路**转发至下游某 `o_driveNext[k]`；`o_free` 由被选通道的 `i_freeNext[k]` 触发 | 指令分发（IDU→EXE）、结果路由（WB→GRF/CSR） | ≥ 5（如 `cSelSplit_6_exe`, `cSelSplit_2_fetch`） |
| `cMutexMerge_*` | `MutexMerge` | **互斥合并**：假定上游 `i_drive0/1/...` **永不同时有效**；任一有效即透传至 `o_driveNext`；`o_free` 仅反馈给当前活动通道 | WB 回馈合并（`cMutexMerge_2_WB`）、Fetch 多源合并（`cMutexMerge_4_d_fetch`） | ≥ 4 |
| `cArbMerge_*` | `ArbMerge` | **仲裁合并**：当多个上游 `i_drive` 同时竞争时，内部仲裁器（策略未公开）决定服务顺序；仅被授权通道获得 `free_out` | LSU 请求仲裁（`cArbMerge2_lsu`）、Mem 请求仲裁（`cArbMerge_2_memslot`） | 2 |
| `cNatSplit_*` | `NatSplit` | **广播分发**：上游 `i_drive` 事件被**无条件复制**到所有下游 `o_driveNext[k]`；上游 `o_free` 需等待**所有** `i_freeNext[k]` 返回才发出 | LSU 请求广播（如地址/控制信号分发）、WB 结果广播（`cNatSplit_2_fetch`） | ≥ 2 |

> ✅ **结构子契约总结**：
> - `Fifo1`: “你给我 `drive`，我给你 `free` —— 但得等我下游 `free` 回来我才敢给你。”  
> - `SelSplit`: “你告诉我选哪个 (`valid[k]`)，我就把 `drive` 发给它；它 `free` 了，我就 `free` 你。”  
> - `MutexMerge`: “你保证不抢，我就直接转发；谁 `free` 了，我就 `free` 谁。”  
> - `ArbMerge`: “你们抢，我来判；我判谁，就给谁 `free`。”  
> - `NatSplit`: “我发给所有人；所有人都 `free` 了，我才 `free` 你。”

---

## 事件流（Event Flow）

事件流定义了“什么时间点、谁发起、谁响应”的控制逻辑。`cpu_top` 中所有交互均由 `drive`（启动）和 `free`（完成）信号驱动。

### 主干事件路径（Fetch → WB）

```text
[TPU] ─i_driveFromTPUtoCPU─┐
                           ▼
                    Fetch_top ─o_driveFromFetchtoDecoder──┐
                           │                             ▼
[i_freeFromDecodertoFetch]◄┘                      idu_top ─o_driveToExe──┐
                           ▲                             │              ▼
[o_freeFromCPUtoTPU]───────┘                             ▼        exe_top ─o_driveNextToLsu──┐
                                                        │              │                 ▼
[i_freeFromExe]◄────────────────────────────────────────┘              ▼         lsu_top ─o_driveToRetire──┐
                                                                       │                 │                ▼
[i_freeNextFrmLsu]◄───────────────────────────────────────────────────┘                 ▼         writeBack ─o_driveWbToFetch──┐
                                                                                         │                │                     ▼
[i_freeFromRetire]◄──────────────────────────────────────────────────────────────────────┘                ▼             Fetch_top ◄───┘
                                                                                                          │
[o_freeFromCPUtoWB]◄─────────────────────────────────────────────────────────────────────────────────────┘
```

### 关键事件特性

- **单向性**：`drive` 总是从上游流向下游（Fetch → IDU → EXE → LSU → WB），`free` 总是反向从下游流向上游（WB → LSU → EXE → IDU → Fetch）。
- **非阻塞启动**：上游发出 `drive` 后，**无需等待**下游 `free` 即可继续工作（只要 FIFO 有空间）；但若 FIFO 满，则 `drive` 自动被抑制（背压生效）。
- **完成即释放**：`free` 信号代表“该事务已彻底处理完毕，资源可回收”，是背压传播的载体。
- **多源合并点**：`Fetch_top` 使用 `cMutexMerge_2_WB` 合并来自 WB 的异常/跳转反馈，确保 Fetch 能及时响应执行结果。

> 🔍 **示例：分支预测失败恢复**
> 当 `exe_top` 检测到分支错误，会通过 `o_driveNextToLsu`（实际用于控制流）或 WB 通路发送 flush 信号 → `writeBack` 生成 `o_driveWbToFetch_64` → `Fetch_top` 收到后清空内部状态，并通过 `o_freeFromCPUtoWB` 确认接收。整个过程不依赖时钟边沿，纯事件触发。

---

## 数据流（Data Flow）

数据流承载指令、操作数、地址、结果等有效载荷，宽度随阶段变化，体现功能专业化。

### 主干数据路径（带宽标注）

```text
[TPU:80b] ─i_dataTPUtoCPU_80──────────────┐
                                         ▼
                                  Fetch_top ─o_dataFetchtoDecoder_97 (97b)──┐
                                         │                                   ▼
[i_dataIcachetoCPU_256]◄───────────────┘                            idu_top ─o_dataToExe_343 (343b)──┐
                                         ▲                                   │                       ▼
[o_dataCPUtoTS_128]──────────────────────┘                                   ▼               exe_top ─o_exeLSUBus_246 (246b)──┐
                                                                             │                       │                      ▼
[i_dataFromExe_246]◄─────────────────────────────────────────────────────────┘                       ▼              lsu_top ─o_dataToRetire_246 (246b)──┐
                                                                                                     │                      │                     ▼
[i_dataFromMem_256]◄─────────────────────────────────────────────────────────────────────────────────┘                      ▼             writeBack ─o_dataWbToFetch_64 (64b)──┐
                                                                                                                                                        │                     ▼
[o_dataMemtoIcache_136]──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘             Fetch_top ◄───┘
```

### 关键数据特性

- **宽度演进**：
  - `97b`（Fetch→IDU）：含 PC（32b）+ 原始指令（32b）+ 扩展字段（33b）；
  - `343b`（IDU→EXE）：解包后的完整操作数、立即数、控制信号等；
  - `246b`（EXE→LSU / LSU→WB）：标准化的 LSU 操作总线（地址、掩码、数据、类型等）；
  - `64b/76b`（WB→GRF/CSR）：写回寄存器的数据（GRF 通常 64b，CSR 含地址+数据共 76b）。
- **零拷贝设计**：数据信号（如 `w_dataFetchtoDecoder_97`）在模块间**直接连线**，无额外寄存器（除非结构子内部需要），降低延迟。
- **格式化节点**：`lsu_memReqFormat_comb` 和 `lsu_memAckFormat_comb` 是关键的数据格式转换器，将 `246b` LSU 总线映射为 `136b` 内存请求/响应，适配 `mem_slot` 接口。

> ⚠️ **风险提示**：`i_dataIcachetoCPU_256`（256b 指令总线）与 `o_dataCPUtoTS_128`（128b 跟踪总线）宽度差异巨大，表明 TS 并非全指令跟踪，而是摘要/事件跟踪（如 PC、分支结果）。**不能假设 TS 输出与 Icache 输入一一对应。**

---

## 等待/背压/完成关系

这是异步系统稳定性的基石。`free` 信号既是完成通知，也是背压信号。

### 核心机制：`free` 的双重角色

| 角色 | 行为 | 影响 |
|------|------|------|
| **完成确认** | 下游模块处理完一个 `drive` 事务后，向其直接上游发出 `free` | 上游可安全释放该事务占用的资源（如 FIFO slot） |
| **背压信号** | 若下游 `free` 未到达，上游的 `cFifo1` 等结构子将**阻止**新的 `drive` 进入（`i_drive` 被忽略） | 流水线自动降速，防止数据丢失或覆盖 |

### 典型背压链路（以 Fetch 为例）

```text
Fetch_top
  │
  ├─ o_driveFromCPUtoIcache ──► mem_slot (Icache req)
  │      │
  │      └─ i_freeFromIcachetoCPU ◄─── [Icache block]
  │             ▲
  │             │ (Icache busy → no free)
  │             │
  └─ w_freeFromCPUtoIcache ◄─── mem_slot (propagates upstream)
         ▲
         │ (mem_slot busy → no free to Fetch_top)
         │
         └─ w_driveFromFetchtoDecoder (stalled! cannot send new inst)
```

- 当 Icache 响应慢（`i_freeFromIcachetoCPU` 延迟），`mem_slot` 无法向 `Fetch_top` 发送 `w_freeFromCPUtoIcache`；
- `Fetch_top` 内部 `cFifo1_cpu` 检测到 `w_freeFromCPUtoIcache` 缺失，便**拒绝接受**新的 `w_driveFromFetchtoDecoder`；
- 整个 Fetch 流水线暂停，直到 Icache 完成并释放。

### 完成语义差异（关键！）

| 结构子 | `free` 何时发出？ | 语义 |
|--------|-------------------|------|
| `cFifo1` | 收到下游 `i_freeNext` 后 | “下游已消费，我可以释放上游 slot” |
| `cSelSplit` | 被选中下游 `i_freeNext[k]` 到达时 | “我选的那个完成了，所以我完成了” |
| `cMutexMerge` | 当前活动上游的 `o_free[k]` 到达时 | “我转发的那个完成了，所以我完成了” |
| `cArbMerge` | 被仲裁选中的上游的 `o_free[k]` 到达时 | “我服务的那个完成了，所以我完成了” |
| `cNatSplit` | **所有**下游 `i_freeNext[k]` 都到达后 | “所有人都收到了且处理完了，我才能算完” |

> ✅ **设计哲学**：`free` 不是“我做完了”，而是“我确认下游都做完了”。这保证了端到端的可靠性。

---

## 阅读建议与风险点

### 📚 快速上手建议

1. **先看 `cpu_top.v` 的实例化与连线**：重点关注 `w_*` 信号如何在模块间穿梭，这是理解数据/事件流向的最快路径。
2. **顺藤摸瓜查 `c*` 结构子**：遇到 `cFifo1_cpu`、`cSelSplit_2_fetch` 等，立刻查阅其 `component_summaries` 中的 `contract` 和 `flow_semantics`，它们定义了行为契约。
3. **用 `flow_graph` 验证**：JSON 中的 `flow_graph.edges` 是权威的信号流向图，比代码更直观。搜索 `"instance_name": "Fetch_top"` 即可看到它所有输入输出。
4. **忽略 `delay*U` 细节**：`delay1U`/`delay11U` 等是底层时序调整单元，对功能理解非必需，可暂视为“黑盒延迟器”。

### ⚠️ 重点风险点（基于当前 JSON）

| 风险点 | 描述 | 证据来源 | 建议 |
|---------|------|-----------|------|
| **`cMutexMerge` 的互斥假设** | 所有 `cMutexMerge_*` 均要求上游 `drive` **永不同时有效**。若实际硬件违反此约束（如两个中断同时触发），行为未定义（"out-of-contract"）。 | `component_summaries` 中 `cMutexMerge_*` 的 `contract.invariants` 明确声明 | 在顶层或测试平台中，必须确保所有接入 `cMutexMerge` 的信号源有严格的互斥逻辑（如优先级编码器）。 |
| **`cNatSplit` 的全等待开销** | `cNatSplit` 要求**所有**下游 `free` 返回才释放上游。若任一下游路径（如 CSR 写入）极慢，将拖慢整个 `NatSplit` 的吞吐。 | `cNatSplit_2_fetch` 的 `contract.release_rule.policy = "all_ports"` | 审查 `cNatSplit` 的使用场景（如 WB→GRF/CSR 分发），确认慢速路径（CSR）是否真的需要与快速路径（GRF）强同步。考虑是否可用 `cSelSplit` 替代。 |
| **`mem_slot` 的仲裁策略黑盒** | `cArbMerge_2_memslot` 的仲裁策略（轮询？固定优先级？）在 JSON 中**未披露**，影响性能建模与瓶颈分析。 | `cArbMerge_2_memslot` 的 `flow_semantics.event_behavior` 仅写 “implementation-specific” | 查阅 `test_data/cpu/mem_slot/cArbMerge_2_memslot.v` 源码，或咨询原作者确认策略。性能敏感场景需实测。 |
| **`switch` 信号用途模糊** | `switch` 是 `Fetch_top` 的输入，`role` 为 `"condition"`，但 JSON 中**无任何其他线索**说明其具体作用（调试开关？模式选择？）。 | `top_module_payload.interface.ports` 中 `switch` 的 `signal_role = "condition"`；`module_summaries` 中无进一步解释 | **必须查阅 `Fetch_top.v` 源码或设计文档**。切勿在未确认前修改或忽略此信号。 |
| **`o_exeLSUBus_246` 语义不明** | 该信号在 `exe_top` 中为 `o_exeLSUBus_246`（output），在 `lsu_top` 中为 `i_dataFromExe_246`（input），但 `flow_graph` 中其 `role` 为 `"unknown"`，且无 `payload_data` 标记。 | `top_module_payload.local_signals` 中 `w_exeLSUBus_246` 的 `role = "unknown"`；`flow_graph.signals` 中同名信号 `role = "unknown"` | **必须确认该总线是否承载有效数据**。若仅为控制信号，不应计入数据流分析；若是数据，则需补充其格式定义。 |

> 💡 **最后忠告**：异步设计的“正确性”不在于波形是否好看，而在于**每一条 `free` 是否精准对应一次 `drive`，且契约被所有参与者严格遵守**。调试时，永远从 `free` 信号的缺失或错位开始追踪。

---  
✅ **手册完** —— 你已掌握 `cpu_top` 的骨架与神经。下一步，打开 `test_data/cpu/CPU/cpu_top.v`，带着这份手册去阅读第一行 Verilog 吧。