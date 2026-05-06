"""Dataclass models for the manual-oriented intermediate representation."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any, Dict, List, Literal


ConfidenceLevel = Literal["high", "medium", "low"]
ArtifactKind = Literal["project_index", "module", "component", "external_stub"]
ManualIRObjectKind = Literal[
    "system_view",
    "module_card",
    "channel_card",
    "component_contract",
    "flow_path",
    "reading_path",
]
BoundaryDirection = Literal["ingress", "egress", "bidirectional"] ## 输入方向 输出方向 双向
ModuleRole = Literal["top", "submodule", "component"] ## 最底层定义为结构子，英文写为component
DocumentRole = Literal[           ### 前四个不是每个项目都会有的，所以进行了删除，后面几个是常见的角色类型，可以根据需要扩展
    # "front_end",
    # "execute",
    # "memory",
    # "writeback",
    "glue",
    "adapter",
    "splitter",
    "merger",
    "arbiter",
    "fifo",
    "synchronizer",
    "eventSource",
    "unknown",
]
ChannelType = Literal["event_only", "event_with_payload", "condition_gated"] 
OwnerKind = Literal["module", "component", "external"]
FlowPathType = Literal["event_path", "data_path", "completion_path", "mixed"]
AudienceType = Literal["newcomer", "maintainer", "reviewer"]
DependencyStatus = Literal["interface_only", "resolved", "missing"]


@dataclass(frozen=True)
class SourceRef:
    # 指向 parser artifact 中的事实来源，用于追踪 Manual IR 对象的证据边界。
    artifact_kind: ArtifactKind
    artifact_name: str
    json_ref: str
    # artifact 内部被使用的字段路径，例如 interface.ports 或 direct_children。
    evidence_paths: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ManualIRObject:
    # 所有 Manual IR 对象的公共元信息基类。
    id: str
    kind: ManualIRObjectKind
    title: str
    summary: str
    top_module: str
    # 面向检索、过滤、分组的轻量标签。
    tags: List[str] = field(default_factory=list)
    # 本对象依赖的 parser artifact 证据列表。
    source_refs: List[SourceRef] = field(default_factory=list)
    # 构建本对象时发现的局部风险或未细化信息。
    warnings: List[str] = field(default_factory=list)
    confidence: ConfidenceLevel = "medium"

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class GeneratedFrom:
    # 记录当前 Manual IR 从哪一份 parser artifact 目录生成。
    artifacts_root: str
    project_index_ref: str = ""


### 便捷的接口定义，方便后续构建IR对象时使用，实际IR对象中会展开成更具体的字段
@dataclass(frozen=True)
class BoundaryInterface:
    # 顶层模块与外部 peer 之间的边界接口摘要。
    name: str
    direction: BoundaryDirection
    # 归属于该边界的 channel id；当前阶段通常为空，待 ChannelCard 构建后填充。
    channels: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ModuleRoleRef:
    # SystemView 中对关键模块的轻量引用。
    module: str
    role: str


@dataclass(frozen=True)
class ComponentRoleRef:
    # SystemView 中对关键结构子的轻量引用。
    component: str
    family: str
    role: str


@dataclass(frozen=True)
class ExternalDependencyRef:
    # parser 识别出的外部依赖，Manual IR 只记录其边界状态。
    name: str
    status: DependencyStatus


## 整个顶层系统视图，包含了系统边界接口、主要模块和组件、使用的组件族、外部依赖以及全局风险点等信息，是整个IR的核心对象之一
@dataclass(frozen=True)
class SystemView(ManualIRObject):
    # 顶层系统视图：描述 top module 的边界、一级结构和全局风险。
    system_role: str = "user_defined"
    # top module 对外暴露的边界接口集合。
    boundary_interfaces: List[BoundaryInterface] = field(default_factory=list)
    # top module 的一级子模块及其文档角色。
    primary_modules: List[ModuleRoleRef] = field(default_factory=list)
    # top module 的一级结构子及其 family / 文档角色。
    primary_components: List[ComponentRoleRef] = field(default_factory=list)
    # top module 可达范围内出现过的 component family。
    families_used: List[str] = field(default_factory=list)
    # top module 可达范围内引用但未解析为内部模块/结构子的依赖。
    external_dependencies: List[ExternalDependencyRef] = field(default_factory=list)
    # 需要在手册总览中提醒的全局风险点。
    global_risks: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class KeyInterfaces:
    # ModuleCard 中最值得写入手册的接口摘要。
    # 事件输入端口名，例如 i_drive*。
    ingress_channels: List[str] = field(default_factory=list)
    # 事件输出端口名，例如 o_drive*。
    egress_channels: List[str] = field(default_factory=list)
    # reset、switch、sel、valid、permit 等控制类端口名。
    control_signals: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class KeyComponentRole:
    # 模块内部关键结构子的文档角色摘要。
    component: str ## 这里应该是实例化后的组件名称，而不是组件族名称，以明确具体是哪个组件在扮演关键角色
    role: str   ## todo: 这个role应该是指在模块内的角色，例如如果是sel，应该表明它要选择是什么


@dataclass(frozen=True)
class BackpressurePoint:
    # 模块或路径中的反压观察点。
    via: str ## 这里应该是实例化后的组件名称，而不是组件族名称，以明确具体是哪个组件
    effect: str 


@dataclass(frozen=True)
class ModuleCard(ManualIRObject):
    # 单个 module 的手册卡片：把 parser module JSON 重组为文档友好的摘要。
    module_name: str = ""
    module_role: ModuleRole = "submodule"
    # 直接实例化该模块的父模块名称列表。
    parent_modules: List[str] = field(default_factory=list)
    document_role: DocumentRole = "unknown"
    # 该模块在手册中应承担的职责描述。
    responsibilities: List[str] = field(default_factory=list)
    key_interfaces: KeyInterfaces = field(default_factory=KeyInterfaces)
    # 保留字段：当前不再根据命名习惯推断模块级 upstream。
    upstream_modules: List[str] = field(default_factory=list)
    # 保留字段：当前不再根据命名习惯推断模块级 downstream。
    downstream_modules: List[str] = field(default_factory=list)
    # 直接子模块名称列表，来自 parser direct_children.modules。
    child_modules: List[str] = field(default_factory=list)
    # 直接结构子名称列表，来自 parser direct_children.components。
    child_components: List[str] = field(default_factory=list)
    # 直接结构子中可稳定识别的文档角色。
    key_component_roles: List[KeyComponentRole] = field(default_factory=list)
    # 本模块内部 flow path id；当前阶段暂不填充。
    internal_flow_paths: List[str] = field(default_factory=list)
    # 由 free/backpressure 类接口或结构子归纳出的阻塞点。
    backpressure_points: List[BackpressurePoint] = field(default_factory=list)
    # 本模块手册说明中需要提醒的风险点。
    risk_points: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ChannelEndpoint:
    # Channel 的一端，描述事件生产者或消费者归属及可选 companion free 信号。
    owner_kind: OwnerKind
    owner_name: str
    drive_signal: str = ""
    # 与该端点相关的数据载荷信号。
    payload_signals: List[str] = field(default_factory=list)
    free_signal: str = ""


@dataclass(frozen=True)
class ChannelPayload:
    # Channel 携带的数据载荷摘要。
    present: bool
    width_text: str = ""
    # 参与载荷传递的信号名列表。
    signals: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class HandshakeRule:
    # Channel 的核心 drive 事件及可选 free/backpressure companion。
    drive: str
    free: str
    completion_rule: str
    backpressure_supported: bool = True


@dataclass(frozen=True)
class ChannelConditioning:
    # Channel 是否受条件、选择或许可信号控制。
    has_condition: bool = False
    # 控制该 Channel 的条件信号列表。
    signals: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ChannelCard(ManualIRObject):
    # 单条以 drive 为核心的局部事件 Channel；当前 builder 先生成模块边界 channel。
    scope_module: str = ""
    channel_name: str = ""
    channel_type: ChannelType = "event_with_payload"
    producer: ChannelEndpoint = field(default_factory=lambda: ChannelEndpoint(owner_kind="module", owner_name=""))
    consumer: ChannelEndpoint = field(default_factory=lambda: ChannelEndpoint(owner_kind="module", owner_name=""))
    payload: ChannelPayload = field(default_factory=lambda: ChannelPayload(present=False))
    handshake: HandshakeRule = field(default_factory=lambda: HandshakeRule(drive="", free="", completion_rule=""))
    conditioning: ChannelConditioning = field(default_factory=ChannelConditioning)
    # 实现该 Channel 的模块/结构子/信号路径对象 id。
    implemented_by_path: List[str] = field(default_factory=list)
    # 与该 Channel 相关的 FlowPath id。
    related_flow_paths: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class RoleMapping:
    # ComponentContract 中的端口角色映射，直接来自 parser component JSON。
    # 上游握手端口名。
    upstream: List[str] = field(default_factory=list)
    # 下游握手端口名。
    downstream: List[str] = field(default_factory=list)
    # 数据载荷端口名。
    payload: List[str] = field(default_factory=list)
    # 条件、选择或许可端口名。
    condition: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class SemanticContract:
    # 结构子 family 的事件、数据、完成传播语义摘要。
    event_behavior: str
    data_behavior: str
    completion_behavior: str


@dataclass(frozen=True)
class ReleaseRule:
    # 结构子完成/释放传播策略。
    policy: str
    details: str


@dataclass(frozen=True)
class BackpressureBehavior:
    # 结构子是否可能阻塞上游，以及阻塞条件说明。
    can_block_upstream: bool
    blocking_condition: str


@dataclass(frozen=True)
class ComponentContract(ManualIRObject):
    # 单个结构子实例的协议卡片，来自 parser component JSON 与 family 模板。
    component_name: str = ""
    family: str = ""
    instance_scope: str = ""
    document_role: DocumentRole = "unknown"
    role_mapping: RoleMapping = field(default_factory=RoleMapping)
    semantic_contract: SemanticContract = field(
        default_factory=lambda: SemanticContract(event_behavior="", data_behavior="", completion_behavior="")
    )
    release_rule: ReleaseRule = field(default_factory=lambda: ReleaseRule(policy="", details=""))
    backpressure_behavior: BackpressureBehavior = field(
        default_factory=lambda: BackpressureBehavior(can_block_upstream=True, blocking_condition="")
    )
    # family 模板中给出的稳定不变量。
    family_invariants: List[str] = field(default_factory=list)
    # 与具体实现有关的补充说明；当前阶段通常为空。
    implementation_notes: List[str] = field(default_factory=list)
    # 使用该结构子的 ChannelCard id；当前阶段通常为空。
    used_in_channels: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class SignalEndpoint:
    # FlowPath 的起点或终点信号。
    owner: str
    signal: str


@dataclass(frozen=True)
class FlowStep:
    # FlowPath 中的一个有序步骤。
    order: int
    node_kind: Literal["interface", "module", "component", "signal_group"]
    node_name: str
    role: str = ""


@dataclass(frozen=True)
class FlowDecisionPoint:
    # FlowPath 中的分支或汇合决策点。
    node: str
    reason: str


@dataclass(frozen=True)
class FlowBlockingPoint:
    # FlowPath 中可能造成反压或等待的位置。
    node: str ## 应该是实例化后的组件名称或者接口名称，以明确具体是哪个点存在阻塞风险
    reason: str


@dataclass(frozen=True)
class FlowPath(ManualIRObject):
    # 模块内部或跨模块的逻辑流路径；当前 builder 先生成 module-local event path。
    scope_module: str = ""
    path_type: FlowPathType = "mixed"
    # 路径起点信号列表。
    startpoints: List[SignalEndpoint] = field(default_factory=list)
    # 路径终点信号列表。
    endpoints: List[SignalEndpoint] = field(default_factory=list)
    # 按 order 排列的路径步骤。
    steps: List[FlowStep] = field(default_factory=list)
    # 路径中的分支点。
    branch_points: List[FlowDecisionPoint] = field(default_factory=list)
    # 路径中的汇合点。
    join_points: List[FlowDecisionPoint] = field(default_factory=list)
    # 完成/释放信号返回路径上的节点 id 或信号名。
    completion_return_path: List[str] = field(default_factory=list)
    # 路径中的阻塞/反压点。
    blocking_points: List[FlowBlockingPoint] = field(default_factory=list)
    # 该路径覆盖的 ChannelCard id。
    covered_channels: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ReadingSection:
    # 手册阅读路径中的一个章节节点。
    section_id: str
    title: str
    # 本章节应覆盖的 Manual IR object id。
    covers: List[str] = field(default_factory=list)
    # 本章节在最终手册中要解决的问题。
    intent: str = ""
    # 本章节生成时应产出的内容形态。
    expected_outputs: List[str] = field(default_factory=list)
    # 本章节允许使用的证据边界和禁止越界的说明。
    evidence_policy: List[str] = field(default_factory=list)
    # 本章节内对象的展开优先级。
    coverage_priority: "CoveragePriority" = field(default_factory=lambda: CoveragePriority())
    # 对大量对象进行分组写作的确定性提示。
    grouping_hints: List[str] = field(default_factory=list)
    # 面向人工审查或维护的问题清单。
    review_questions: List[str] = field(default_factory=list)
    # 建议映射到最终手册中的章节位置。
    artifact_target: "ArtifactTarget" = field(default_factory=lambda: ArtifactTarget())


@dataclass(frozen=True)
class CoveragePriority:
    # 需要在正文中展开解释的 Manual IR object id。
    must_explain: List[str] = field(default_factory=list)
    # 需要按组或表格汇总的 Manual IR object id。
    summarize: List[str] = field(default_factory=list)
    # 只需要作为证据索引或附录引用的 Manual IR object id。
    reference_only: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ArtifactTarget:
    # 建议写入的最终手册章节文件名。
    manual_chapter: str = ""
    # 建议章节锚点。
    anchor: str = ""


@dataclass(frozen=True)
class ReadingPath(ManualIRObject):
    # 面向特定读者的手册阅读顺序；当前 builder 默认尚不生成。
    audience: AudienceType = "newcomer"
    # 该阅读路径希望帮助读者完成的目标。
    goals: List[str] = field(default_factory=list)
    # 推荐阅读章节顺序。
    ordered_sections: List[ReadingSection] = field(default_factory=list)
    # 必须覆盖的 Manual IR object id。
    must_cover: List[str] = field(default_factory=list)
    # 可以后置阅读的章节 id。
    defer_sections: List[str] = field(default_factory=list)
    # 阅读该路径时需要提醒的风险。
    risk_reminders: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ManualIRObjects:
    # Manual IR 的对象容器，按对象类型分组保存。
    # 顶层系统视图，通常每个 top module 一个。
    system_views: List[SystemView] = field(default_factory=list)
    # 可达 module 的文档卡片。
    module_cards: List[ModuleCard] = field(default_factory=list)
    # 以 drive 为核心的局部事件 Channel 卡片。
    channel_cards: List[ChannelCard] = field(default_factory=list)
    # 可达 component leaf 的协议卡片。
    component_contracts: List[ComponentContract] = field(default_factory=list)
    # module-local event flow 路径对象。
    flow_paths: List[FlowPath] = field(default_factory=list)
    # 手册阅读路径对象；当前阶段通常为空。
    reading_paths: List[ReadingPath] = field(default_factory=list)


@dataclass(frozen=True)
class ManualIRIndexes:
    # Manual IR 的轻量索引，方便后续上下文选择和手册生成定位对象。
    by_id: Dict[str, str] = field(default_factory=dict)
    # module name -> 相关 Manual IR object id 列表。
    by_module: Dict[str, List[str]] = field(default_factory=dict)
    # component family -> ComponentContract id 列表。
    by_family: Dict[str, List[str]] = field(default_factory=dict)
    # tag -> Manual IR object id 列表。
    by_tag: Dict[str, List[str]] = field(default_factory=dict)


@dataclass(frozen=True)
class ManualIR:
    # 一次 Manual IR 构建的完整结果。
    schema: str
    schema_version: str
    top_module: str
    generated_from: GeneratedFrom
    objects: ManualIRObjects = field(default_factory=ManualIRObjects)
    indexes: ManualIRIndexes = field(default_factory=ManualIRIndexes)
    # 构建阶段的全局提醒，例如哪些对象类型仍是 deferred。
    warnings: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)
