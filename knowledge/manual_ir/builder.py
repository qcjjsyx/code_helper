"""Build Manual IR objects from parser artifacts."""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
import re
from typing import Any, Dict, Iterable, List

from knowledge.loaders.knowledge_base import ArtifactRecord, ProjectKnowledgeBase

from .models import (
    ArtifactTarget,
    BackpressureBehavior,
    BackpressurePoint,
    ChannelCard,
    ChannelConditioning,
    ChannelEndpoint,
    ChannelPayload,
    ComponentContract,
    ComponentRoleRef,
    CoveragePriority,
    ExternalDependencyRef,
    FlowBlockingPoint,
    FlowDecisionPoint,
    FlowPath,
    FlowStep,
    GeneratedFrom,
    HandshakeRule,
    KeyComponentRole,
    KeyInterfaces,
    ManualIR,
    ManualIRIndexes,
    ManualIRObjects,
    ModuleCard,
    ModuleRoleRef,
    ReadingPath,
    ReadingSection,
    ReleaseRule,
    RoleMapping,
    SemanticContract,
    SignalEndpoint,
    SourceRef,
    SystemView,
)


_SECTION_GUIDANCE: Dict[str, Dict[str, Any]] = {
    "read:newcomer:overview": {
        "intent": "帮助新读者先建立系统边界、一级结构和全局风险的整体图景。",
        "expected_outputs": ["系统边界摘要", "一级模块和结构子概览", "外部依赖和全局风险提示"],
        "evidence_policy": ["只能使用 SystemView 中的 boundary_interfaces、primary_modules、primary_components、families_used、external_dependencies 和 global_risks。"],
        "priority": "must_explain",
        "grouping_hints": ["按 boundary interface、primary module、primary component、external dependency 分组。"],
        "review_questions": ["顶层边界是否覆盖了所有关键输入/输出事件通道？", "外部依赖是否需要单独补充接口说明？"],
        "manual_chapter": "01_system_overview.md",
        "anchor": "system-overview",
    },
    "read:newcomer:top-module": {
        "intent": "解释 top module 在系统中的职责和直接结构。",
        "expected_outputs": ["top module 职责摘要", "关键接口摘要", "直接子对象列表"],
        "evidence_policy": ["只能使用 top ModuleCard 的 responsibilities、key_interfaces、child_modules、child_components 和 risk_points。"],
        "priority": "must_explain",
        "grouping_hints": ["按接口、子模块、结构子、风险点分组。"],
        "review_questions": ["top module 的直接子对象是否足以支撑系统总览？"],
        "manual_chapter": "02_module_structure.md",
        "anchor": "top-module",
    },
    "read:newcomer:primary-modules": {
        "intent": "让新读者理解一级子模块各自承担的结构职责。",
        "expected_outputs": ["一级模块职责表", "关键 ingress/egress channel 摘要", "需要后续阅读的模块列表"],
        "evidence_policy": ["只能使用 ModuleCard，不根据端口命名推断模块级上下游关系。"],
        "priority": "summarize",
        "grouping_hints": ["按 module_role、document_role、接口数量和风险点分组。"],
        "review_questions": ["是否存在一级模块风险点需要提前提醒读者？"],
        "manual_chapter": "02_module_structure.md",
        "anchor": "primary-modules",
    },
    "read:newcomer:component-protocols": {
        "intent": "用每类结构子的代表对象解释稳定协议语义。",
        "expected_outputs": ["结构子 family 协议表", "upstream/downstream/payload/condition 角色说明", "release/backpressure 规则摘要"],
        "evidence_policy": ["只能使用 ComponentContract 的 role_mapping、semantic_contract、release_rule、backpressure_behavior 和 family_invariants。", "不要从具体 RTL 实现猜测 family 模板未声明的行为。"],
        "priority": "must_explain",
        "grouping_hints": ["按 component family 分组，每个 family 解释代表 contract。"],
        "review_questions": ["每个已出现的结构子 family 是否至少有一个代表 contract？"],
        "manual_chapter": "03_component_protocols.md",
        "anchor": "component-protocols",
    },
    "read:newcomer:representative-flows": {
        "intent": "展示完整可达的代表性事件路径，帮助理解事件如何穿过结构子。",
        "expected_outputs": ["代表 FlowPath 列表", "每条路径的起点、步骤、终点", "branch/join/blocking 点摘要"],
        "evidence_policy": ["只能使用 FlowPath 中的 startpoints、steps、endpoints、branch_points、join_points、blocking_points 和 covered_channels。"],
        "priority": "must_explain",
        "grouping_hints": ["按 scope_module 分组，再按路径复杂度排序。"],
        "review_questions": ["代表路径是否覆盖了主要模块和常见结构子角色？"],
        "manual_chapter": "04_event_flow_paths.md",
        "anchor": "representative-event-flows",
    },
    "read:newcomer:partial-flows": {
        "intent": "提示新读者哪些事件路径是当前 parser 边界内的 partial path。",
        "expected_outputs": ["partial FlowPath 摘要", "停止原因 warning", "不要越界推断的说明"],
        "evidence_policy": ["只能说明 parser 已追踪到的实例连接和 warning；不能补写 always/FSM/process 内部逻辑。"],
        "priority": "summarize",
        "grouping_hints": ["按 warning 文本和 scope_module 分组。"],
        "review_questions": ["partial 是否属于合理的过程逻辑边界？"],
        "manual_chapter": "04_event_flow_paths.md",
        "anchor": "partial-event-flows",
    },
    "read:maintainer:hot-modules": {
        "intent": "帮助维护者优先定位修改影响面较大的模块。",
        "expected_outputs": ["高影响模块清单", "每个模块的接口/结构/风险摘要", "建议优先回归范围"],
        "evidence_policy": ["只能使用 ModuleCard 的确定性字段和 risk_points。"],
        "priority": "summarize",
        "grouping_hints": ["按接口复杂度、子对象数量、risk_points 分组。"],
        "review_questions": ["修改这些模块时需要同步检查哪些 child module 或 component contract？"],
        "manual_chapter": "05_maintenance_guide.md",
        "anchor": "high-impact-modules",
    },
    "read:maintainer:complex-flows": {
        "intent": "列出完整可达且包含分支、汇合或阻塞点的复杂事件路径。",
        "expected_outputs": ["复杂 FlowPath 表", "branch/join/blocking 点", "维护回归关注点"],
        "evidence_policy": ["只包含有 endpoints、无 warning、非 low confidence 的 FlowPath；partial path 应写入 partial-flows。"],
        "priority": "summarize",
        "grouping_hints": ["按 scope_module 分组，再按 blocking、join、branch 类型分组。"],
        "review_questions": ["复杂路径中的 blocking point 是否需要重点回归 free/backpressure？"],
        "manual_chapter": "05_maintenance_guide.md",
        "anchor": "complex-flow-paths",
    },
    "read:maintainer:boundary-channels": {
        "intent": "帮助维护者检查高影响模块和 top module 的边界事件通道。",
        "expected_outputs": ["Boundary Channel 表", "payload/free/condition 摘要", "ambiguous payload warning 列表"],
        "evidence_policy": ["只能使用 ChannelCard 的 producer、consumer、payload、handshake、conditioning 和 warnings。"],
        "priority": "summarize",
        "grouping_hints": ["按 scope_module、ingress/egress、payload present、warning 分组。"],
        "review_questions": ["是否存在 payload 匹配不明确的通道需要人工确认？"],
        "manual_chapter": "05_maintenance_guide.md",
        "anchor": "boundary-channels",
    },
    "read:maintainer:blocking-contracts": {
        "intent": "解释维护时最需要注意的结构子协议和阻塞行为。",
        "expected_outputs": ["按 family 分组的 ComponentContract 表", "release_rule/backpressure_behavior 摘要"],
        "evidence_policy": ["只能使用 ComponentContract，不根据实例上下文扩展 family 语义。"],
        "priority": "must_explain",
        "grouping_hints": ["按 component family 分组。"],
        "review_questions": ["每类结构子的 completion/free 行为是否已在手册中解释？"],
        "manual_chapter": "05_maintenance_guide.md",
        "anchor": "blocking-component-contracts",
    },
    "read:maintainer:partial-flows": {
        "intent": "列出维护时需要人工判断的 partial 或 low confidence flow。",
        "expected_outputs": ["partial FlowPath 审查表", "每条 warning 的停止原因", "可能需要增强 parser fact 的位置"],
        "evidence_policy": ["不能把 partial flow 补写成完整路径；若要增强，应回到 parser 层新增 process/FSM summary fact。"],
        "priority": "must_explain",
        "grouping_hints": ["按 scope_module 和 warning 类型分组。"],
        "review_questions": ["是否需要新增 process_event_generation、register_driven_event 或 sequential_event_boundary fact？"],
        "manual_chapter": "05_maintenance_guide.md",
        "anchor": "partial-or-low-confidence-flows",
    },
    "read:reviewer:system-risks": {
        "intent": "让审查者先检查系统级风险和外部依赖边界。",
        "expected_outputs": ["系统风险清单", "外部依赖表", "审查入口建议"],
        "evidence_policy": ["只能使用 SystemView 的 global_risks 和 external_dependencies。"],
        "priority": "must_explain",
        "grouping_hints": ["按 external dependency 和 parser warning 类型分组。"],
        "review_questions": ["哪些外部依赖需要补接口说明或确认 ignored policy？"],
        "manual_chapter": "06_review_checklist.md",
        "anchor": "system-risks",
    },
    "read:reviewer:risky-modules": {
        "intent": "集中审查包含 warning 或 risk_points 的模块。",
        "expected_outputs": ["Risky Module 表", "每个风险点的来源", "建议人工检查项"],
        "evidence_policy": ["只能使用 ModuleCard.warnings 和 ModuleCard.risk_points，不补充未解析 RTL 语义。"],
        "priority": "summarize",
        "grouping_hints": ["按 warning、外部依赖、多类结构子、直接子对象数量分组。"],
        "review_questions": ["风险是否来自 parser 边界、外部依赖，还是模块结构复杂度？"],
        "manual_chapter": "06_review_checklist.md",
        "anchor": "risky-modules",
    },
    "read:reviewer:partial-flows": {
        "intent": "逐条审查 partial 或 low confidence FlowPath 的合理性。",
        "expected_outputs": ["partial FlowPath 审查表", "起点、已知步骤、停止原因", "parser fact 增强建议"],
        "evidence_policy": ["只能报告 FlowPath.warning、confidence、startpoints、steps 和 endpoints；不能推断过程逻辑。"],
        "priority": "must_explain",
        "grouping_hints": ["按 scope_module、warning 文本、是否经过 transparent_delay 分组。"],
        "review_questions": ["partial 是否符合当前“不分析 always/FSM/process logic”的边界？"],
        "manual_chapter": "06_review_checklist.md",
        "anchor": "partial-flows",
    },
    "read:reviewer:blocking-points": {
        "intent": "审查所有包含 blocking、branch 或 join 点的事件路径。",
        "expected_outputs": ["Blocking/Join/Branch FlowPath 表", "阻塞点原因", "需要回归的 free/backpressure 关系"],
        "evidence_policy": ["只能使用 FlowPath.blocking_points、branch_points、join_points 和 covered_channels。"],
        "priority": "summarize",
        "grouping_hints": ["按 blocking、join、branch 类型和 scope_module 分组。"],
        "review_questions": ["是否存在可能影响上游释放的关键阻塞点？"],
        "manual_chapter": "06_review_checklist.md",
        "anchor": "blocking-and-join-points",
    },
    "read:reviewer:component-contracts": {
        "intent": "确认每种结构子类型的协议合同都被审查到。",
        "expected_outputs": ["按 family 分组的 ComponentContract 审查表", "协议不变量和 release_rule", "backpressure 审查项"],
        "evidence_policy": ["只能使用 ComponentContract 中的 parser/family 模板事实。"],
        "priority": "must_explain",
        "grouping_hints": ["按 component family 分组，每个 family 检查代表 contract。"],
        "review_questions": ["所有出现过的结构子 family 是否都有代表 contract？", "是否存在 missing_family_template warning？"],
        "manual_chapter": "06_review_checklist.md",
        "anchor": "component-contracts",
    },
}


@dataclass(frozen=True)
class ManualIRBuildOptions:
    schema: str = "manual_ir"
    schema_version: str = "0.1"
    build_system_view: bool = True
    build_module_cards: bool = True
    build_component_contracts: bool = True
    build_channel_cards: bool = True
    build_flow_paths: bool = True
    build_reading_paths: bool = True


@dataclass
class _ReachabilityGraph:
    top_record: ArtifactRecord
    modules_in_order: List[ArtifactRecord]
    components_in_order: List[ArtifactRecord]
    parent_modules_by_module: Dict[str, List[str]]
    parent_modules_by_component: Dict[str, List[str]]
    external_dependencies: Dict[str, List[str]]


@dataclass(frozen=True)
class _FlowInstance:
    name: str
    module_type: str
    artifact_kind: str
    family: str
    input_drives: List[str]
    output_drives: List[str]


def build_manual_ir(
    kb: ProjectKnowledgeBase,
    top_module: str,
    *,
    options: ManualIRBuildOptions | None = None,
) -> ManualIR:
    options = options or ManualIRBuildOptions()
    graph = _collect_reachable_graph(kb, top_module)
    artifacts_root = _infer_artifacts_root(kb)

    objects = ManualIRObjects()
    if options.build_system_view:
        objects.system_views.append(_build_system_view(kb, graph, artifacts_root))
    if options.build_module_cards:
        objects.module_cards.extend(_build_module_cards(kb, graph, artifacts_root))
    if options.build_channel_cards:
        objects.channel_cards.extend(_build_channel_cards(graph, artifacts_root))
    if options.build_component_contracts:
        objects.component_contracts.extend(_build_component_contracts(kb, graph, artifacts_root))
    if options.build_flow_paths:
        objects.flow_paths.extend(_build_flow_paths(graph, artifacts_root, objects.channel_cards))
    if options.build_reading_paths:
        objects.reading_paths.extend(_build_reading_paths(objects, top_module))

    warnings = _build_phase_warnings(options)
    indexes = _build_indexes(objects)
    return ManualIR(
        schema=options.schema,
        schema_version=options.schema_version,
        top_module=top_module,
        generated_from=GeneratedFrom(
            artifacts_root=str(artifacts_root) if artifacts_root else "",
            project_index_ref="project_index.json",
        ),
        objects=objects,
        indexes=indexes,
        warnings=warnings,
    )


def _collect_reachable_graph(kb: ProjectKnowledgeBase, top_module: str) -> _ReachabilityGraph:
    top_record = kb.modules.get(top_module)
    if top_record is None:
        raise KeyError(f"top module not found: {top_module}")

    visited_modules: set[str] = set()
    modules_in_order: List[ArtifactRecord] = []
    components_in_order: List[ArtifactRecord] = []
    seen_components: set[str] = set()
    parent_modules_by_module: Dict[str, List[str]] = defaultdict(list)
    parent_modules_by_component: Dict[str, List[str]] = defaultdict(list)
    external_dependencies: Dict[str, List[str]] = defaultdict(list)

    def append_parent(mapping: Dict[str, List[str]], key: str, parent: str) -> None:
        parents = mapping[key]
        if parent not in parents:
            parents.append(parent)

    def register_component(component_name: str, parent_module: str) -> None:
        append_parent(parent_modules_by_component, component_name, parent_module)
        component_record = kb.components.get(component_name)
        if component_record and component_name not in seen_components:
            seen_components.add(component_name)
            components_in_order.append(component_record)

    def register_external_dependency(target_name: str, parent_module: str) -> None:
        if target_name and parent_module not in external_dependencies[target_name]:
            external_dependencies[target_name].append(parent_module)

    def walk(module_name: str) -> None:
        if module_name in visited_modules:
            return
        record = kb.modules.get(module_name)
        if record is None:
            return

        visited_modules.add(module_name)
        modules_in_order.append(record)

        payload = record.payload
        walked_modules: set[str] = set()
        walked_components: set[str] = set()

        for instance in payload.get("instances", []):
            instance_kind = instance.get("artifact_kind")
            target_name = instance.get("module_type") or ""
            if instance_kind == "module" and target_name:
                append_parent(parent_modules_by_module, target_name, module_name)
                walked_modules.add(target_name)
                walk(target_name)
            elif instance_kind == "derived_component" and target_name:
                walked_components.add(target_name)
                register_component(target_name, module_name)
            elif instance_kind == "external_dependency":
                register_external_dependency(target_name or instance.get("instance_name", ""), module_name)

        direct_children = payload.get("direct_children", {})
        for child_name in direct_children.get("modules", []):
            append_parent(parent_modules_by_module, child_name, module_name)
            if child_name not in walked_modules:
                walk(child_name)
        for child_name in direct_children.get("components", []):
            register_component(child_name, module_name)
            walked_components.add(child_name)

    walk(top_module)

    return _ReachabilityGraph(
        top_record=top_record,
        modules_in_order=modules_in_order,
        components_in_order=components_in_order,
        parent_modules_by_module=dict(parent_modules_by_module),
        parent_modules_by_component=dict(parent_modules_by_component),
        external_dependencies=dict(external_dependencies),
    )


def _build_system_view(
    kb: ProjectKnowledgeBase,
    graph: _ReachabilityGraph,
    artifacts_root: Path | None,
) -> SystemView:
    top_record = graph.top_record
    payload = top_record.payload
    direct_children = payload.get("direct_children", {})
    families_used = list(payload.get("transitive_summary", {}).get("families_used", []))

    primary_modules = [
        ModuleRoleRef(module=module_name, role="direct_child_module")
        for module_name in direct_children.get("modules", [])
    ]
    primary_components = []
    for component_name in direct_children.get("components", []):
        component = kb.components.get(component_name)
        primary_components.append(
            ComponentRoleRef(
                component=component_name,
                family=component.payload.get("family", "") if component else "",
                role=_family_to_document_role(component.payload.get("family", "") if component else ""),
            )
        )

    external_dependencies = [
        ExternalDependencyRef(name=name, status="interface_only")
        for name in sorted(graph.external_dependencies)
    ]
    global_risks = [
        f"外部依赖 {name} 目前只有接口边界。"
        for name in sorted(graph.external_dependencies)
    ]

    return SystemView(
        id=f"system:{top_record.name}",
        kind="system_view",
        title=top_record.name,
        summary=(
            f"顶层模块 {top_record.name} 的系统视图，覆盖 "
            f"{max(len(graph.modules_in_order) - 1, 0)} 个可达子模块和 "
            f"{len(graph.components_in_order)} 个结构子。"
        ),
        top_module=top_record.name,
        tags=["overview", "manual_ir"],
        source_refs=[
            _project_index_source_ref(),
            _artifact_source_ref(
                top_record,
                artifacts_root,
                ["interface.ports", "direct_children", "transitive_summary.families_used"],
            ),
        ],
        warnings=list(payload.get("warnings", [])),
        confidence="medium",
        system_role="user_defined",
        boundary_interfaces=_build_boundary_interfaces(payload.get("interface", {}).get("ports", []), top_record.name),
        primary_modules=primary_modules,
        primary_components=primary_components,
        families_used=families_used,
        external_dependencies=external_dependencies,
        global_risks=global_risks,
    )


def _build_module_cards(
    kb: ProjectKnowledgeBase,
    graph: _ReachabilityGraph,
    artifacts_root: Path | None,
) -> List[ModuleCard]:
    cards: List[ModuleCard] = []
    for record in graph.modules_in_order:
        payload = record.payload
        direct_children = payload.get("direct_children", {})
        child_modules = list(direct_children.get("modules", []))
        child_components = list(direct_children.get("components", []))
        interface_summary = _module_interface_summary(payload)
        key_component_roles = _build_key_component_roles(child_components, kb)
        module_role = _map_module_role(payload.get("module_role"), child_modules, child_components)
        external_dependencies = _module_external_dependencies(payload)
        cards.append(
            ModuleCard(
                id=f"module:{record.name}",
                kind="module_card",
                title=record.name,
                summary=(
                    f"模块 {record.name} 的结构摘要，"
                    f"直接包含 {len(child_modules)} 个子模块和 {len(child_components)} 个结构子。"
                ),
                top_module=graph.top_record.name,
                tags=["module"],
                source_refs=[
                    _artifact_source_ref(
                        record,
                        artifacts_root,
                        ["interface.ports", "interface_summary", "direct_children", "transitive_summary", "flow_graph"],
                    )
                ],
                warnings=list(payload.get("warnings", [])),
                confidence="medium",
                module_name=record.name,
                module_role=module_role, # type: ignore
                parent_modules=list(graph.parent_modules_by_module.get(record.name, [])),
                document_role=_infer_module_document_role(child_modules, child_components, kb), # type: ignore
                responsibilities=_build_module_responsibilities(interface_summary, child_modules, child_components, payload),
                key_interfaces=KeyInterfaces(
                    ingress_channels=list(interface_summary["signal_groups"]["event_inputs"]),
                    egress_channels=list(interface_summary["signal_groups"]["event_outputs"]),
                    control_signals=list(interface_summary["control_signals"]),
                ),
                upstream_modules=[],
                downstream_modules=[],
                child_modules=child_modules,
                child_components=child_components,
                key_component_roles=key_component_roles,
                internal_flow_paths=[],
                backpressure_points=_build_backpressure_points(interface_summary),
                risk_points=_build_module_risk_points(
                    child_modules=child_modules,
                    child_components=child_components,
                    key_component_roles=key_component_roles,
                    external_dependencies=external_dependencies,
                ),
            )
        )
    return cards


def _build_component_contracts(
    kb: ProjectKnowledgeBase,
    graph: _ReachabilityGraph,
    artifacts_root: Path | None,
) -> List[ComponentContract]:
    contracts: List[ComponentContract] = []
    for record in graph.components_in_order:
        payload = record.payload
        parents = list(graph.parent_modules_by_component.get(record.name, []))
        instance_scope = parents[0] if parents else ""
        warnings = list(payload.get("warnings", []))
        if len(parents) > 1:
            warnings.append(
                f"component referenced by multiple parent modules: {', '.join(parents)}"
            )

        release_rule_payload = payload.get("contract", {}).get("release_rule", {})
        contracts.append(
            ComponentContract(
                id=f"contract:{record.name}",
                kind="component_contract",
                title=record.name,
                summary=f"结构子 {record.name} 的协议摘要，family 为 {payload.get('family', '')}。",
                top_module=graph.top_record.name,
                tags=["component_contract", payload.get("family", "").lower()],
                source_refs=[
                    _artifact_source_ref(
                        record,
                        artifacts_root,
                        ["family", "role_mapping", "contract", "flow_semantics"],
                    )
                ],
                warnings=warnings,
                confidence="medium",
                component_name=record.name,
                family=payload.get("family", ""),
                instance_scope=instance_scope,
                document_role=_family_to_document_role(payload.get("family", "")), # type: ignore
                role_mapping=_flatten_role_mapping(payload.get("role_mapping", {})),
                semantic_contract=SemanticContract(
                    event_behavior=payload.get("flow_semantics", {}).get("event_behavior", ""),
                    data_behavior=payload.get("flow_semantics", {}).get("data_behavior", ""),
                    completion_behavior=payload.get("flow_semantics", {}).get("completion_behavior", ""),
                ),
                release_rule=ReleaseRule(
                    policy=release_rule_payload.get("policy", ""),
                    details=release_rule_payload.get("details", ""),
                ),
                backpressure_behavior=BackpressureBehavior(
                    can_block_upstream=True,
                    blocking_condition=_infer_blocking_condition(
                        payload.get("family", ""),
                        release_rule_payload,
                    ),
                ),
                family_invariants=list(payload.get("contract", {}).get("invariants", [])),
                implementation_notes=[],
                used_in_channels=[],
            )
        )
    return contracts


def _build_channel_cards(
    graph: _ReachabilityGraph,
    artifacts_root: Path | None,
) -> List[ChannelCard]:
    cards: List[ChannelCard] = []
    for record in graph.modules_in_order:
        payload = record.payload
        ports = payload.get("interface", {}).get("ports", [])
        ports = ports if isinstance(ports, list) else []
        ports_by_name = {
            port.get("name", ""): port
            for port in ports
            if isinstance(port, dict) and port.get("name")
        }
        interface_summary = _module_interface_summary(payload)
        signal_groups = interface_summary["signal_groups"]
        drive_names = sorted(set(signal_groups["event_inputs"] + signal_groups["event_outputs"]))
        drive_count_by_direction = {
            "input": len(signal_groups["event_inputs"]),
            "output": len(signal_groups["event_outputs"]),
        }

        free_ports = [
            port for port in ports_by_name.values()
            if _signal_role_for_name(port.get("name", "")) == "event_free"
        ]
        payload_ports = [
            port for port in ports_by_name.values()
            if _is_payload_candidate_port(port)
        ]
        condition_ports = [
            port for port in ports_by_name.values()
            if _signal_role_for_name(port.get("name", "")) == "condition"
        ]

        for drive_name in drive_names:
            drive_port = ports_by_name.get(drive_name, {})
            drive_direction = drive_port.get("direction") or (
                "input" if drive_name in signal_groups["event_inputs"] else "output"
            )
            if drive_direction not in {"input", "output"}:
                continue

            free_port = _match_channel_free_port(drive_name, drive_direction, free_ports)
            payload_matches, payload_warnings = _match_channel_payload_ports(
                drive_name,
                drive_direction,
                payload_ports,
                record.name,
                allow_unique_fallback=drive_count_by_direction.get(drive_direction, 0) == 1,
            )
            condition_matches = _match_channel_condition_ports(drive_name, condition_ports)

            peer_name = _infer_channel_peer_name(drive_name, drive_direction, record.name)
            channel_name = _build_channel_name(record.name, drive_name, drive_direction, peer_name)
            free_signal = free_port.get("name", "") if free_port else ""
            payload_signals = [port.get("name", "") for port in payload_matches if port.get("name")]
            condition_signals = [port.get("name", "") for port in condition_matches if port.get("name")]
            warnings = list(payload_warnings)

            if drive_direction == "input":
                producer = ChannelEndpoint(
                    owner_kind="external",
                    owner_name=peer_name or "external",
                    drive_signal=drive_name,
                    payload_signals=payload_signals,
                )
                consumer = ChannelEndpoint(
                    owner_kind="module",
                    owner_name=record.name,
                    free_signal=free_signal,
                )
                direction_tag = "ingress"
            else:
                producer = ChannelEndpoint(
                    owner_kind="module",
                    owner_name=record.name,
                    drive_signal=drive_name,
                    payload_signals=payload_signals,
                )
                consumer = ChannelEndpoint(
                    owner_kind="external",
                    owner_name=peer_name or "external",
                    free_signal=free_signal,
                )
                direction_tag = "egress"

            channel_type = "event_only"
            if payload_signals:
                channel_type = "event_with_payload"
            if condition_signals:
                channel_type = "condition_gated"

            cards.append(
                ChannelCard(
                    id=f"channel:{record.name}:{drive_name}",
                    kind="channel_card",
                    title=channel_name,
                    summary=(
                        f"模块 {record.name} 边界上的局部事件通道，"
                        f"drive 信号为 {drive_name}。"
                    ),
                    top_module=graph.top_record.name,
                    tags=["channel", "boundary_channel", direction_tag],
                    source_refs=[
                        _artifact_source_ref(
                            record,
                            artifacts_root,
                            ["interface.ports", "interface_summary"],
                        )
                    ],
                    warnings=warnings,
                    confidence="medium",
                    scope_module=record.name,
                    channel_name=channel_name,
                    channel_type=channel_type, # type: ignore[arg-type]
                    producer=producer,
                    consumer=consumer,
                    payload=ChannelPayload(
                        present=bool(payload_signals),
                        width_text=_payload_width_text(payload_matches),
                        signals=payload_signals,
                    ),
                    handshake=HandshakeRule(
                        drive=drive_name,
                        free=free_signal,
                        completion_rule=_channel_completion_rule(free_signal),
                        backpressure_supported=bool(free_signal),
                    ),
                    conditioning=ChannelConditioning(
                        has_condition=bool(condition_signals),
                        signals=condition_signals,
                    ),
                    implemented_by_path=[],
                    related_flow_paths=[],
                )
            )
    return cards


def _build_flow_paths(
    graph: _ReachabilityGraph,
    artifacts_root: Path | None,
    channel_cards: List[ChannelCard],
) -> List[FlowPath]:
    channel_id_by_module_signal = {
        (card.scope_module, card.handshake.drive): card.id
        for card in channel_cards
        if card.scope_module and card.handshake.drive
    }
    paths: List[FlowPath] = []
    for record in graph.modules_in_order:
        interface_summary = _module_interface_summary(record.payload)
        start_signals = list(interface_summary["signal_groups"]["event_inputs"])
        if not start_signals:
            continue
        signal_to_instances, instance_flows = _build_local_event_graph(record.payload)
        output_drives = set(interface_summary["signal_groups"]["event_outputs"])
        for start_signal in start_signals:
            paths.append(
                _trace_module_local_flow_path(
                    record=record,
                    top_module=graph.top_record.name,
                    artifacts_root=artifacts_root,
                    start_signal=start_signal,
                    output_drives=output_drives,
                    signal_to_instances=signal_to_instances,
                    instance_flows=instance_flows,
                    channel_id_by_module_signal=channel_id_by_module_signal,
                )
            )
    return paths


def _build_local_event_graph(payload: Dict[str, Any]) -> tuple[Dict[str, List[str]], Dict[str, _FlowInstance]]:
    signal_to_instances: Dict[str, List[str]] = defaultdict(list)
    instance_flows: Dict[str, _FlowInstance] = {}
    for instance in payload.get("instances", []):
        instance_name = instance.get("instance_name", "")
        if not instance_name:
            continue
        input_drives: List[str] = []
        output_drives: List[str] = []
        for connection in instance.get("connections", []):
            signal_names = _connection_signal_terms(connection)
            if not signal_names or not _connection_is_event_drive(connection):
                continue
            port_direction = connection.get("port_direction")
            if port_direction == "input":
                for signal_name in signal_names:
                    input_drives.append(signal_name)
                    if instance_name not in signal_to_instances[signal_name]:
                        signal_to_instances[signal_name].append(instance_name)
            elif port_direction == "output":
                output_drives.extend(signal_names)

        if input_drives or output_drives:
            instance_flows[instance_name] = _FlowInstance(
                name=instance_name,
                module_type=instance.get("module_type", ""),
                artifact_kind=instance.get("artifact_kind", ""),
                family=instance.get("family", ""),
                input_drives=sorted(set(input_drives)),
                output_drives=sorted(set(output_drives)),
            )

    for transparent_flow in payload.get("transparent_flows", []):
        instance_name = transparent_flow.get("instance_name", "")
        input_signal = transparent_flow.get("input_signal", "")
        output_signal = transparent_flow.get("output_signal", "")
        if not instance_name or not input_signal or not output_signal:
            continue
        signal_role = transparent_flow.get("signal_role", "")
        if signal_role != "event_drive":
            continue
        if instance_name not in signal_to_instances[input_signal]:
            signal_to_instances[input_signal].append(instance_name)
        instance_flows[instance_name] = _FlowInstance(
            name=instance_name,
            module_type=transparent_flow.get("module_type", ""),
            artifact_kind=transparent_flow.get("artifact_kind", "transparent_helper"),
            family="",
            input_drives=[input_signal],
            output_drives=[output_signal],
        )
    return dict(signal_to_instances), instance_flows


def _connection_signal_terms(connection: Dict[str, Any]) -> List[str]:
    signal_terms = connection.get("signal_terms")
    if isinstance(signal_terms, list):
        terms = [term for term in signal_terms if isinstance(term, str) and term]
        if terms:
            return terms
    signal_name = connection.get("signal") or ""
    return [signal_name] if signal_name else []


def _trace_module_local_flow_path(
    *,
    record: ArtifactRecord,
    top_module: str,
    artifacts_root: Path | None,
    start_signal: str,
    output_drives: set[str],
    signal_to_instances: Dict[str, List[str]],
    instance_flows: Dict[str, _FlowInstance],
    channel_id_by_module_signal: Dict[tuple[str, str], str],
) -> FlowPath:
    steps: List[FlowStep] = []
    endpoints: List[SignalEndpoint] = []
    branch_points: List[FlowDecisionPoint] = []
    join_points: List[FlowDecisionPoint] = []
    blocking_points: List[FlowBlockingPoint] = []
    covered_channels: List[str] = []
    warnings: List[str] = []

    start_channel = channel_id_by_module_signal.get((record.name, start_signal))
    if start_channel:
        covered_channels.append(start_channel)

    visited_signals: set[str] = set()
    visited_instances: set[str] = set()
    queued_signals: List[str] = [start_signal]
    max_visits = 512

    while queued_signals and len(visited_signals) + len(visited_instances) < max_visits:
        signal_name = queued_signals.pop(0)
        if signal_name in visited_signals:
            continue
        visited_signals.add(signal_name)

        if signal_name in output_drives:
            endpoints.append(SignalEndpoint(owner=record.name, signal=signal_name))
            channel_id = channel_id_by_module_signal.get((record.name, signal_name))
            if channel_id and channel_id not in covered_channels:
                covered_channels.append(channel_id)

        for instance_name in signal_to_instances.get(signal_name, []):
            instance_flow = instance_flows.get(instance_name)
            if instance_flow is None:
                continue
            if instance_name not in visited_instances:
                visited_instances.add(instance_name)
                steps.append(
                    FlowStep(
                        order=len(steps) + 1,
                        node_kind=_flow_node_kind(instance_flow),
                        node_name=instance_name,
                        role=_flow_instance_role(instance_flow),
                    )
                )
                _append_flow_points(
                    instance_flow=instance_flow,
                    branch_points=branch_points,
                    join_points=join_points,
                    blocking_points=blocking_points,
                )
            for output_signal in instance_flow.output_drives:
                if output_signal not in visited_signals and output_signal not in queued_signals:
                    queued_signals.append(output_signal)

    if queued_signals:
        warnings.append(f"flow traversal for {start_signal} stopped after reaching traversal limit.")
    if not endpoints:
        warnings.append(f"no module output event drive reached from start signal {start_signal}.")

    return FlowPath(
        id=f"flow:{record.name}:{start_signal}",
        kind="flow_path",
        title=f"{record.name}:{start_signal}",
        summary=f"模块 {record.name} 内从 {start_signal} 出发的局部事件流。",
        top_module=top_module,
        tags=["flow_path", "module_local", "event_path"],
        source_refs=[
            _artifact_source_ref(
                record,
                artifacts_root,
                ["instances.connections", "transparent_flows", "flow_graph", "interface_summary"],
            )
        ],
        warnings=warnings,
        confidence="medium" if endpoints else "low",
        scope_module=record.name,
        path_type="event_path",
        startpoints=[SignalEndpoint(owner=record.name, signal=start_signal)],
        endpoints=_dedupe_signal_endpoints(endpoints),
        steps=steps,
        branch_points=_dedupe_decision_points(branch_points),
        join_points=_dedupe_decision_points(join_points),
        completion_return_path=[],
        blocking_points=_dedupe_blocking_points(blocking_points),
        covered_channels=covered_channels,
    )


def _connection_is_event_drive(connection: Dict[str, Any]) -> bool:
    return (
        connection.get("signal_role") == "event_drive"
        or _signal_role_for_name(connection.get("signal", "")) == "event_drive"
        or _signal_role_for_name(connection.get("port", "")) == "event_drive"
    )


def _flow_node_kind(instance_flow: _FlowInstance) -> str:
    if instance_flow.artifact_kind == "transparent_helper":
        return "signal_group"
    if instance_flow.artifact_kind == "derived_component":
        return "component"
    return "module"


def _flow_instance_role(instance_flow: _FlowInstance) -> str:
    if instance_flow.artifact_kind == "transparent_helper":
        return "transparent_delay"
    if instance_flow.family:
        return _family_to_document_role(instance_flow.family)
    if instance_flow.artifact_kind == "module":
        return "module_instance"
    return "unknown"


def _append_flow_points(
    *,
    instance_flow: _FlowInstance,
    branch_points: List[FlowDecisionPoint],
    join_points: List[FlowDecisionPoint],
    blocking_points: List[FlowBlockingPoint],
) -> None:
    role = _flow_instance_role(instance_flow)
    if len(instance_flow.output_drives) > 1 or role == "splitter":
        branch_points.append(
            FlowDecisionPoint(
                node=instance_flow.name,
                reason="component may route one event into multiple downstream event outputs.",
            )
        )
    if len(instance_flow.input_drives) > 1 or role in {"merger", "arbiter"}:
        join_points.append(
            FlowDecisionPoint(
                node=instance_flow.name,
                reason="component may combine or arbitrate multiple upstream event inputs.",
            )
        )
    if role in {"fifo_stage", "merger", "arbiter"}:
        blocking_points.append(
            FlowBlockingPoint(
                node=instance_flow.name,
                reason=f"{role} can gate local event propagation.",
            )
        )


def _dedupe_signal_endpoints(endpoints: List[SignalEndpoint]) -> List[SignalEndpoint]:
    seen: set[tuple[str, str]] = set()
    deduped: List[SignalEndpoint] = []
    for endpoint in endpoints:
        key = (endpoint.owner, endpoint.signal)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(endpoint)
    return deduped


def _dedupe_decision_points(points: List[FlowDecisionPoint]) -> List[FlowDecisionPoint]:
    seen: set[tuple[str, str]] = set()
    deduped: List[FlowDecisionPoint] = []
    for point in points:
        key = (point.node, point.reason)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(point)
    return deduped


def _dedupe_blocking_points(points: List[FlowBlockingPoint]) -> List[FlowBlockingPoint]:
    seen: set[tuple[str, str]] = set()
    deduped: List[FlowBlockingPoint] = []
    for point in points:
        key = (point.node, point.reason)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(point)
    return deduped


def _build_reading_paths(objects: ManualIRObjects, top_module: str) -> List[ReadingPath]:
    system_ids = [item.id for item in objects.system_views]
    module_by_name = {item.module_name: item for item in objects.module_cards}
    top_module_card = module_by_name.get(top_module)
    top_module_ids = [top_module_card.id] if top_module_card else []
    primary_module_names = _primary_module_names(objects, top_module_card)
    primary_module_ids = [
        module_by_name[name].id
        for name in primary_module_names
        if name in module_by_name
    ]
    warning_flow_ids = [
        flow.id
        for flow in objects.flow_paths
        if flow.warnings or flow.confidence == "low"
    ]
    risky_module_ids = [
        card.id
        for card in objects.module_cards
        if card.warnings or card.risk_points
    ]
    base_must_cover = _dedupe_ids(system_ids + top_module_ids + primary_module_ids + warning_flow_ids + risky_module_ids)

    return [
        _build_newcomer_reading_path(
            objects=objects,
            top_module=top_module,
            system_ids=system_ids,
            top_module_ids=top_module_ids,
            primary_module_ids=primary_module_ids,
            warning_flow_ids=warning_flow_ids,
            must_cover=base_must_cover,
        ),
        _build_maintainer_reading_path(
            objects=objects,
            top_module=top_module,
            system_ids=system_ids,
            top_module_ids=top_module_ids,
            warning_flow_ids=warning_flow_ids,
            must_cover=base_must_cover,
        ),
        _build_reviewer_reading_path(
            objects=objects,
            top_module=top_module,
            system_ids=system_ids,
            warning_flow_ids=warning_flow_ids,
            risky_module_ids=risky_module_ids,
            must_cover=base_must_cover,
        ),
    ]


def _build_newcomer_reading_path(
    *,
    objects: ManualIRObjects,
    top_module: str,
    system_ids: List[str],
    top_module_ids: List[str],
    primary_module_ids: List[str],
    warning_flow_ids: List[str],
    must_cover: List[str],
) -> ReadingPath:
    contract_ids = _representative_component_contract_ids(objects.component_contracts, max_per_family=2)[:20]
    representative_flow_ids = [
        flow.id
        for flow in _rank_flows(objects.flow_paths)
        if not flow.warnings and flow.confidence != "low" and flow.endpoints
    ][:12]
    sections = [
        ReadingSection(
            section_id="read:newcomer:overview",
            title="System Overview",
            covers=system_ids,
        ),
        ReadingSection(
            section_id="read:newcomer:top-module",
            title="Top Module",
            covers=top_module_ids,
        ),
        ReadingSection(
            section_id="read:newcomer:primary-modules",
            title="Primary Modules",
            covers=primary_module_ids,
        ),
        ReadingSection(
            section_id="read:newcomer:component-protocols",
            title="Component Protocols",
            covers=contract_ids,
        ),
        ReadingSection(
            section_id="read:newcomer:representative-flows",
            title="Representative Event Flows",
            covers=representative_flow_ids,
        ),
    ]
    if warning_flow_ids:
        sections.append(
            ReadingSection(
                section_id="read:newcomer:partial-flows",
                title="Partial Or Deferred Event Flows",
                covers=warning_flow_ids[:12],
            )
        )

    return ReadingPath(
        id=f"reading:newcomer:{top_module}",
        kind="reading_path",
        title=f"Newcomer reading path for {top_module}",
        summary=(
            f"面向新读者的 {top_module} 阅读顺序：先理解系统边界和一级结构，"
            "再阅读关键模块、结构子协议和代表性事件流。"
        ),
        top_module=top_module,
        tags=["reading_path", "newcomer"],
        source_refs=[],
        warnings=[],
        confidence="medium",
        audience="newcomer",
        goals=[
            f"理解 {top_module} 的系统边界和一级模块结构。",
            "识别主要事件通道、payload 和 backpressure 关系。",
            "掌握常见结构子 family 的协议作用。",
        ],
        ordered_sections=_non_empty_sections(sections),
        must_cover=must_cover,
        defer_sections=[
            "read:newcomer:low-level-leaves",
            "read:newcomer:simple-event-only-channels",
        ],
        risk_reminders=_reading_risk_reminders(objects, audience="newcomer"),
    )


def _build_maintainer_reading_path(
    *,
    objects: ManualIRObjects,
    top_module: str,
    system_ids: List[str],
    top_module_ids: List[str],
    warning_flow_ids: List[str],
    must_cover: List[str],
) -> ReadingPath:
    hot_modules = _rank_module_cards(objects.module_cards)[:12]
    hot_module_ids = _dedupe_ids(top_module_ids + [card.id for card in hot_modules])
    hot_module_names = {card.module_name for card in hot_modules}
    complex_flow_ids = [
        flow.id
        for flow in _rank_flows(objects.flow_paths)
        if _is_complete_complex_flow(flow)
    ]
    channel_ids = [
        card.id
        for card in _rank_channels(objects.channel_cards)
        if card.scope_module in hot_module_names or card.scope_module == top_module
    ][:20]
    contract_ids = _representative_component_contract_ids(objects.component_contracts, max_per_family=2)

    sections = [
        ReadingSection(
            section_id="read:maintainer:hot-modules",
            title="High Impact Modules",
            covers=hot_module_ids,
        ),
        ReadingSection(
            section_id="read:maintainer:complex-flows",
            title="Complex Flow Paths",
            covers=complex_flow_ids,
        ),
        ReadingSection(
            section_id="read:maintainer:boundary-channels",
            title="Boundary Channels",
            covers=channel_ids,
        ),
        ReadingSection(
            section_id="read:maintainer:blocking-contracts",
            title="Blocking Component Contracts",
            covers=contract_ids,
        ),
    ]
    if warning_flow_ids:
        sections.append(
            ReadingSection(
                section_id="read:maintainer:partial-flows",
                title="Partial Or Low Confidence Flows",
                covers=warning_flow_ids,
            )
        )

    return ReadingPath(
        id=f"reading:maintainer:{top_module}",
        kind="reading_path",
        title=f"Maintainer reading path for {top_module}",
        summary="面向维护者的阅读顺序：优先阅读接口复杂、flow 复杂和存在阻塞点的模块。",
        top_module=top_module,
        tags=["reading_path", "maintainer"],
        source_refs=[],
        warnings=[],
        confidence="medium",
        audience="maintainer",
        goals=[
            "定位修改影响最大的模块和事件路径。",
            "理解复杂 flow 中的分支、汇合和阻塞点。",
            "识别维护时需要优先回归的 channel 和 component contract。",
        ],
        ordered_sections=_non_empty_sections(sections),
        must_cover=must_cover,
        defer_sections=["read:maintainer:simple-leaf-modules"],
        risk_reminders=_reading_risk_reminders(objects, audience="maintainer"),
    )


def _build_reviewer_reading_path(
    *,
    objects: ManualIRObjects,
    top_module: str,
    system_ids: List[str],
    warning_flow_ids: List[str],
    risky_module_ids: List[str],
    must_cover: List[str],
) -> ReadingPath:
    risky_flow_ids = _dedupe_ids(warning_flow_ids)
    blocking_flow_ids = [
        flow.id
        for flow in _rank_flows(objects.flow_paths)
        if flow.blocking_points or flow.branch_points or flow.join_points
    ]
    contract_ids = _representative_component_contract_ids(objects.component_contracts, max_per_family=2)
    sections = [
        ReadingSection(
            section_id="read:reviewer:system-risks",
            title="System Risks",
            covers=system_ids,
        ),
        ReadingSection(
            section_id="read:reviewer:risky-modules",
            title="Risky Modules",
            covers=risky_module_ids,
        ),
        ReadingSection(
            section_id="read:reviewer:partial-flows",
            title="Partial Or Low Confidence Flows",
            covers=risky_flow_ids,
        ),
        ReadingSection(
            section_id="read:reviewer:blocking-points",
            title="Blocking And Join Points",
            covers=blocking_flow_ids,
        ),
        ReadingSection(
            section_id="read:reviewer:component-contracts",
            title="Component Contracts",
            covers=contract_ids,
        ),
    ]

    return ReadingPath(
        id=f"reading:reviewer:{top_module}",
        kind="reading_path",
        title=f"Reviewer reading path for {top_module}",
        summary="面向审查者的阅读顺序：优先检查风险、partial flow、低置信度对象和外部依赖。",
        top_module=top_module,
        tags=["reading_path", "reviewer"],
        source_refs=[],
        warnings=[],
        confidence="medium",
        audience="reviewer",
        goals=[
            "优先审查 Manual IR 中的低置信度和 warning 对象。",
            "确认 partial FlowPath 是合理边界还是 parser 规则不足。",
            "检查外部依赖和复杂 backpressure 路径。",
        ],
        ordered_sections=_non_empty_sections(sections),
        must_cover=must_cover,
        defer_sections=[],
        risk_reminders=_reading_risk_reminders(objects, audience="reviewer"),
    )


def _primary_module_names(objects: ManualIRObjects, top_module_card: ModuleCard | None) -> List[str]:
    if objects.system_views and objects.system_views[0].primary_modules:
        return [item.module for item in objects.system_views[0].primary_modules]
    if top_module_card:
        return list(top_module_card.child_modules)
    return []


def _rank_component_contract_ids(contracts: List[ComponentContract]) -> List[str]:
    return [
        contract.id
        for contract in sorted(
            contracts,
            key=lambda contract: (
                _family_rank(contract.document_role),
                contract.family,
                contract.component_name,
                contract.id,
            ),
        )
    ]


def _representative_component_contract_ids(
    contracts: List[ComponentContract],
    *,
    max_per_family: int,
) -> List[str]:
    selected: List[str] = []
    count_by_family: Dict[str, int] = defaultdict(int)
    for contract in sorted(
        contracts,
        key=lambda contract: (
            _family_rank(contract.document_role),
            contract.family,
            contract.component_name,
            contract.id,
        ),
    ):
        family_key = contract.family or contract.document_role or "unknown"
        if count_by_family[family_key] >= max_per_family:
            continue
        selected.append(contract.id)
        count_by_family[family_key] += 1
    return selected


def _rank_module_cards(cards: List[ModuleCard]) -> List[ModuleCard]:
    return sorted(
        cards,
        key=lambda card: (
            -_module_reading_score(card),
            card.module_role != "top",
            card.module_name,
        ),
    )


def _module_reading_score(card: ModuleCard) -> int:
    interface_score = len(card.key_interfaces.ingress_channels) + len(card.key_interfaces.egress_channels)
    structure_score = len(card.child_modules) + len(card.child_components)
    risk_score = len(card.risk_points) + len(card.warnings)
    return interface_score + structure_score + risk_score * 3


def _rank_flows(flows: List[FlowPath]) -> List[FlowPath]:
    return sorted(
        flows,
        key=lambda flow: (
            -_flow_reading_score(flow),
            flow.scope_module,
            flow.id,
        ),
    )


def _flow_reading_score(flow: FlowPath) -> int:
    return (
        len(flow.branch_points)
        + len(flow.join_points)
        + len(flow.blocking_points)
        + len(flow.warnings) * 5
        + (3 if flow.confidence == "low" else 0)
    )


def _is_complete_complex_flow(flow: FlowPath) -> bool:
    return (
        bool(flow.endpoints)
        and not flow.warnings
        and flow.confidence != "low"
        and bool(flow.branch_points or flow.join_points or flow.blocking_points)
    )


def _rank_channels(channels: List[ChannelCard]) -> List[ChannelCard]:
    return sorted(
        channels,
        key=lambda card: (
            -(len(card.payload.signals) + len(card.conditioning.signals) + len(card.warnings) * 3),
            card.scope_module,
            card.id,
        ),
    )


def _family_rank(document_role: str) -> int:
    order = {
        "fifo_stage": 0,
        "fifo": 0,
        "splitter": 1,
        "merger": 2,
        "arbiter": 3,
        "synchronizer": 4,
        "eventSource": 5,
        "unknown": 9,
    }
    return order.get(document_role, 8)


def _reading_risk_reminders(objects: ManualIRObjects, *, audience: str) -> List[str]:
    reminders: List[str] = []
    for system_view in objects.system_views:
        reminders.extend(system_view.global_risks)
    for module_card in objects.module_cards:
        for warning in module_card.warnings:
            reminders.append(f"ModuleCard {module_card.id}: {warning}")
        for risk in module_card.risk_points:
            reminders.append(f"ModuleCard {module_card.id}: {risk}")
    low_confidence_flows = [
        flow
        for flow in objects.flow_paths
        if flow.confidence == "low" or flow.warnings
    ]
    if low_confidence_flows:
        reminders.append(
            f"{len(low_confidence_flows)} 个 FlowPath 当前为 low confidence 或包含 warning，"
            "阅读时需要区分结构化实例路径和过程逻辑边界。"
        )
    blocking_flows = [
        flow
        for flow in objects.flow_paths
        if flow.blocking_points
    ]
    if blocking_flows:
        reminders.append(
            f"{len(blocking_flows)} 个 FlowPath 包含 blocking_points，需关注 free/backpressure 对事件传播的影响。"
        )
    if audience in {"maintainer", "reviewer"}:
        for flow in low_confidence_flows:
            for warning in flow.warnings:
                reminders.append(f"FlowPath {flow.id}: {warning}")
    for channel in objects.channel_cards:
        for warning in channel.warnings:
            reminders.append(f"ChannelCard {channel.id}: {warning}")
    if any(
        step.role == "transparent_delay"
        for flow in objects.flow_paths
        for step in flow.steps
    ):
        reminders.append(
            "FlowPath 中出现 transparent_delay 表示 parser 保留了 delay helper 的透传事实，"
            "但 delay 不作为正式 component 展开。"
        )
    return _dedupe_text(reminders)


def _non_empty_sections(sections: List[ReadingSection]) -> List[ReadingSection]:
    return [
        _enrich_reading_section(section)
        for section in sections
        if section.covers
    ]


def _enrich_reading_section(section: ReadingSection) -> ReadingSection:
    guidance = _SECTION_GUIDANCE.get(section.section_id, {})
    priority = str(guidance.get("priority", "summarize"))
    return ReadingSection(
        section_id=section.section_id,
        title=section.title,
        covers=list(section.covers),
        intent=section.intent or str(guidance.get("intent", "")),
        expected_outputs=list(section.expected_outputs or _ensure_list(guidance.get("expected_outputs"))),
        evidence_policy=list(section.evidence_policy or _ensure_list(guidance.get("evidence_policy"))),
        coverage_priority=section.coverage_priority
        if _coverage_priority_has_values(section.coverage_priority)
        else _build_coverage_priority(section.covers, priority),
        grouping_hints=list(section.grouping_hints or _ensure_list(guidance.get("grouping_hints"))),
        review_questions=list(section.review_questions or _ensure_list(guidance.get("review_questions"))),
        artifact_target=section.artifact_target
        if section.artifact_target.manual_chapter or section.artifact_target.anchor
        else ArtifactTarget(
            manual_chapter=str(guidance.get("manual_chapter", "")),
            anchor=str(guidance.get("anchor", "")),
        ),
    )


def _coverage_priority_has_values(priority: CoveragePriority) -> bool:
    return bool(priority.must_explain or priority.summarize or priority.reference_only)


def _build_coverage_priority(covers: List[str], priority: str) -> CoveragePriority:
    if priority == "must_explain":
        return CoveragePriority(must_explain=list(covers))
    if priority == "reference_only":
        return CoveragePriority(reference_only=list(covers))
    return CoveragePriority(summarize=list(covers))


def _dedupe_ids(values: List[str]) -> List[str]:
    seen: set[str] = set()
    deduped: List[str] = []
    for value in values:
        if not value or value in seen:
            continue
        seen.add(value)
        deduped.append(value)
    return deduped


def _dedupe_text(values: List[str]) -> List[str]:
    seen: set[str] = set()
    deduped: List[str] = []
    for value in values:
        if not value or value in seen:
            continue
        seen.add(value)
        deduped.append(value)
    return deduped


def _build_phase_warnings(options: ManualIRBuildOptions) -> List[str]:
    warnings: List[str] = []
    if not options.build_channel_cards:
        warnings.append("channel card mapping is deferred in this phase.")
    if not options.build_flow_paths:
        warnings.append("flow path extraction is deferred in this phase.")
    if not options.build_reading_paths:
        warnings.append("reading path planning is deferred in this phase.")
    return warnings


def _build_indexes(objects: ManualIRObjects) -> ManualIRIndexes:
    by_id: Dict[str, str] = {}
    by_module: Dict[str, List[str]] = defaultdict(list)
    by_family: Dict[str, List[str]] = defaultdict(list)
    by_tag: Dict[str, List[str]] = defaultdict(list)

    def add_object(location: str, obj: Any, module_key: str | None = None, family_key: str | None = None) -> None:
        by_id[obj.id] = location
        if module_key:
            by_module[module_key].append(obj.id)
        if family_key:
            by_family[family_key].append(obj.id)
        for tag in getattr(obj, "tags", []):
            by_tag[tag].append(obj.id)

    for index, obj in enumerate(objects.system_views):
        add_object(f"objects.system_views[{index}]", obj, module_key=obj.top_module)
    for index, obj in enumerate(objects.module_cards):
        add_object(f"objects.module_cards[{index}]", obj, module_key=obj.module_name)
    for index, obj in enumerate(objects.channel_cards):
        add_object(f"objects.channel_cards[{index}]", obj, module_key=obj.scope_module)
    for index, obj in enumerate(objects.component_contracts):
        add_object(
            f"objects.component_contracts[{index}]",
            obj,
            module_key=obj.instance_scope or obj.top_module,
            family_key=obj.family,
        )
    for index, obj in enumerate(objects.flow_paths):
        add_object(f"objects.flow_paths[{index}]", obj, module_key=obj.scope_module)
    for index, obj in enumerate(objects.reading_paths):
        add_object(f"objects.reading_paths[{index}]", obj, module_key=obj.top_module)

    return ManualIRIndexes(
        by_id=by_id,
        by_module=dict(by_module),
        by_family=dict(by_family),
        by_tag=dict(by_tag),
    )


def _map_module_role(
    parser_module_role: str | None,
    child_modules: List[str],
    child_components: List[str],
) -> str:
    if parser_module_role == "top":
        return "top"
    if not child_modules and not child_components:
        return "component"
    return "submodule"


def _flatten_role_mapping(raw_mapping: Dict[str, Any]) -> RoleMapping:
    def ports_for(key: str) -> List[str]:
        value = raw_mapping.get(key, [])
        if isinstance(value, dict):
            ports = value.get("ports", [])
            return list(ports) if isinstance(ports, list) else []
        if isinstance(value, list):
            return list(value)
        return []

    return RoleMapping(
        upstream=ports_for("upstream"),
        downstream=ports_for("downstream"),
        payload=ports_for("payload"),
        condition=ports_for("condition"),
    )


def _family_to_document_role(family: str) -> str:
    return {
        "SelSplit": "splitter",
        "WaitMerge": "merger",
        "MutexMerge": "merger",
        "ArbMerge": "arbiter",
        "Fifo1": "fifo_stage",
        "PmtFifo1": "fifo_stage",
    }.get(family, "unknown")


def _infer_blocking_condition(family: str, release_rule_payload: Dict[str, Any]) -> str:
    policy = release_rule_payload.get("policy", "")
    details = release_rule_payload.get("details", "")
    if details:
        return details
    if policy == "selected_only":
        return "等待被选中的下游返回 free。"
    if policy == "all_ports":
        return "等待所有下游返回 free。"
    if policy == "broadcast_from_output_free":
        return "等待输出 free 返回后再向上游传播完成。"
    if family:
        return f"{family} 的完成传播尚未细化到更具体的阻塞条件。"
    return ""


def _extract_control_signals(ports: Iterable[Dict[str, Any]]) -> List[str]:
    signals: List[str] = []
    for port in ports:
        name = port.get("name", "")
        lowered = name.lower()
        if any(token in lowered for token in ("switch", "sel", "valid", "permit", "pmt")):
            signals.append(name)
    return signals


def _module_interface_summary(payload: Dict[str, Any]) -> Dict[str, Any]:
    raw_summary = payload.get("interface_summary")
    if isinstance(raw_summary, dict):
        signal_groups = raw_summary.get("signal_groups", {})
        return {
            "signal_groups": {
                key: sorted(set(_ensure_list(signal_groups.get(key))))
                for key in (
                    "event_inputs",
                    "event_outputs",
                    "payload_inputs",
                    "payload_outputs",
                    "condition_inputs",
                    "condition_outputs",
                    "reset_inputs",
                    "reset_outputs",
                )
            },
            "control_signals": sorted(set(_ensure_list(raw_summary.get("control_signals")))),
            "backpressure_signals": sorted(set(_ensure_list(raw_summary.get("backpressure_signals")))),
        }

    ports = payload.get("interface", {}).get("ports", [])
    return _build_interface_summary_from_ports(ports if isinstance(ports, list) else [])


def _build_interface_summary_from_ports(ports: List[Dict[str, Any]]) -> Dict[str, Any]:
    signal_groups: Dict[str, List[str]] = {
        "event_inputs": [],
        "event_outputs": [],
        "payload_inputs": [],
        "payload_outputs": [],
        "condition_inputs": [],
        "condition_outputs": [],
        "reset_inputs": [],
        "reset_outputs": [],
    }
    control_signals: List[str] = []
    backpressure_signals: List[str] = []

    for port in ports:
        port_name = port.get("name", "")
        port_direction = port.get("direction", "")
        signal_role = _signal_role_for_name(port_name)
        group_key = _interface_signal_group_key(signal_role, port_direction)
        if group_key is not None and port_name:
            signal_groups[group_key].append(port_name)
        if signal_role == "condition" and port_name:
            control_signals.append(port_name)
        if signal_role == "event_free" and port_direction == "input" and port_name:
            backpressure_signals.append(port_name)

    return {
        "signal_groups": {
            key: sorted(set(values))
            for key, values in signal_groups.items()
        },
        "control_signals": sorted(set(control_signals)),
        "backpressure_signals": sorted(set(backpressure_signals)),
    }


def _infer_module_document_role(
    child_modules: List[str],
    child_components: List[str],
    kb: ProjectKnowledgeBase,
) -> str:
    component_roles = {
        _family_to_document_role(
            (kb.components.get(component_name).payload.get("family", "") if kb.components.get(component_name) else "")
        )
        for component_name in child_components
    }
    component_roles.discard("unknown")
    if len(component_roles) == 1 and not child_modules:
        return next(iter(component_roles))
    if child_modules or child_components:
        return "glue"
    return "unknown"


def _build_module_responsibilities(
    interface_summary: Dict[str, Any],
    child_modules: List[str],
    child_components: List[str],
    payload: Dict[str, Any],
) -> List[str]:
    responsibilities: List[str] = []
    signal_groups = interface_summary["signal_groups"]
    event_inputs = signal_groups["event_inputs"]
    event_outputs = signal_groups["event_outputs"]
    control_signals = interface_summary["control_signals"]
    if event_inputs or event_outputs or control_signals:
        fragments: List[str] = []
        if event_inputs:
            fragments.append(f"{len(event_inputs)} 个事件输入")
        if event_outputs:
            fragments.append(f"{len(event_outputs)} 个事件输出")
        if control_signals:
            fragments.append(f"{len(control_signals)} 个控制信号")
        responsibilities.append(f"对外接口包含 {'、'.join(fragments)}。")
    if child_modules or child_components:
        responsibilities.append(f"直接包含 {len(child_modules)} 个子模块和 {len(child_components)} 个结构子。")
    families_used = list(payload.get("transitive_summary", {}).get("families_used", []))
    if families_used:
        responsibilities.append(f"可达结构子 family 包括 {', '.join(families_used)}。")
    return responsibilities


def _build_key_component_roles(
    child_components: List[str],
    kb: ProjectKnowledgeBase,
) -> List[KeyComponentRole]:
    roles: List[KeyComponentRole] = []
    for component_name in child_components:
        record = kb.components.get(component_name)
        family = record.payload.get("family", "") if record else ""
        role = _family_to_document_role(family)
        if role == "unknown":
            continue
        roles.append(KeyComponentRole(component=component_name, role=role))
    return roles


def _build_backpressure_points(interface_summary: Dict[str, Any]) -> List[BackpressurePoint]:
    return [
        BackpressurePoint(
            via=signal_name,
            effect=f"{signal_name} 未返回释放时，对应下游握手无法完成。",
        )
        for signal_name in interface_summary["backpressure_signals"]
    ]


def _build_module_risk_points(
    *,
    child_modules: List[str],
    child_components: List[str],
    key_component_roles: List[KeyComponentRole],
    external_dependencies: List[str],
) -> List[str]:
    risks: List[str] = [
        f"外部依赖 {name} 当前只有接口边界。"
        for name in external_dependencies
    ]
    distinct_roles = sorted({item.role for item in key_component_roles})
    if len(distinct_roles) > 1:
        risks.append("同时包含多类结构子角色，阅读时需要区分主路径与返回路径。")
    if len(child_modules) + len(child_components) >= 4:
        risks.append("直接子对象较多，建议按层级拆分理解。")
    return risks


def _module_external_dependencies(payload: Dict[str, Any]) -> List[str]:
    dependencies = [
        instance.get("module_type", "")
        for instance in payload.get("instances", [])
        if instance.get("artifact_kind") == "external_dependency" and instance.get("module_type")
    ]
    return sorted(set(dependencies))


def _ensure_list(value: Any) -> List[str]:
    if isinstance(value, list):
        return [item for item in value if isinstance(item, str)]
    return []


def _signal_role_for_name(name: str) -> str:
    lowered = name.strip().lower()
    if re.match(r"^(rst|rstn|reset)\b", lowered):
        return "reset"
    if "valid" in lowered or lowered.startswith("sel") or "switch" in lowered or lowered == "pmt" or "permit" in lowered:
        return "condition"
    if "drive" in lowered or _has_drv_token(lowered):
        return "event_drive"
    if "free" in lowered:
        return "event_free"
    if "data" in lowered:
        return "payload_data"
    return "unknown"


def _is_payload_candidate_port(port: Dict[str, Any]) -> bool:
    name = port.get("name", "")
    lowered = name.strip().lower()
    if not name:
        return False
    if lowered in {"clk", "clock"} or lowered.startswith(("clk_", "clock_")) or lowered.endswith(("_clk", "_clock")):
        return False
    return _signal_role_for_name(name) not in {"event_drive", "event_free", "reset", "condition"}


def _has_drv_token(lowered_name: str) -> bool:
    return bool(re.search(r"(^|_)drv|^[iow]_drv", lowered_name))


def _match_channel_free_port(
    drive_name: str,
    drive_direction: str,
    free_ports: List[Dict[str, Any]],
) -> Dict[str, Any] | None:
    expected_direction = "output" if drive_direction == "input" else "input"
    candidates = [
        port for port in free_ports
        if port.get("direction") == expected_direction
    ]
    if not candidates:
        return None

    peer_key = _channel_peer_key(drive_name, drive_direction)
    if peer_key:
        peer_matches = [
            port for port in candidates
            if _channel_peer_key(port.get("name", ""), port.get("direction", "")) == peer_key
        ]
        if peer_matches:
            return sorted(peer_matches, key=lambda port: port.get("name", ""))[0]
        return None
    if len(candidates) == 1:
        return candidates[0]
    return None


def _match_channel_payload_ports(
    drive_name: str,
    drive_direction: str,
    payload_ports: List[Dict[str, Any]],
    scope_module: str,
    *,
    allow_unique_fallback: bool,
) -> tuple[List[Dict[str, Any]], List[str]]:
    endpoint_peer_key = _channel_endpoint_peer_key(drive_name, drive_direction, scope_module)
    peer_key = _channel_peer_key(drive_name, drive_direction)
    candidates = [
        port for port in payload_ports
        if port.get("direction") == drive_direction
    ]
    if endpoint_peer_key:
        endpoint_matches = [
            port for port in candidates
            if _port_matches_peer_key(port.get("name", ""), endpoint_peer_key, drive_direction)
        ]
        if endpoint_matches:
            return sorted(endpoint_matches, key=lambda port: port.get("name", "")), []
    if peer_key:
        peer_matches = [
            port for port in candidates
            if _port_matches_peer_key(port.get("name", ""), peer_key, drive_direction)
        ]
        if peer_matches:
            return sorted(peer_matches, key=lambda port: port.get("name", "")), []
    if allow_unique_fallback and len(candidates) == 1:
        return candidates, []
    if candidates:
        candidate_names = ", ".join(sorted(port.get("name", "") for port in candidates if port.get("name")))
        return [], [f"payload candidates were ambiguous for drive signal {drive_name}: {candidate_names}."]
    return [], []


def _match_channel_condition_ports(
    drive_name: str,
    condition_ports: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    peer_key = _channel_peer_key(drive_name, "")
    if not peer_key:
        return []
    return [
        port for port in condition_ports
        if _channel_peer_key(port.get("name", ""), "") == peer_key
    ]


def _infer_channel_peer_name(signal_name: str, signal_direction: str, scope_module: str) -> str:
    endpoint = _extract_channel_endpoint_pair(signal_name)
    if endpoint is not None:
        source, target = endpoint
        scope_key = _normalize_channel_token(scope_module)
        if signal_direction == "input" and _normalize_channel_token(target) == scope_key:
            return source
        if signal_direction == "output" and _normalize_channel_token(source) == scope_key:
            return target
    return _extract_channel_peer(signal_name, signal_direction)


def _channel_peer_key(signal_name: str, signal_direction: str) -> str:
    peer = _extract_channel_peer(signal_name, signal_direction)
    return re.sub(r"[^a-z0-9]", "", peer.lower())


def _channel_endpoint_peer_key(signal_name: str, signal_direction: str, scope_module: str) -> str:
    endpoint = _extract_channel_endpoint_pair(signal_name)
    if endpoint is None:
        return ""
    source, target = endpoint
    scope_key = _normalize_channel_token(scope_module)
    source_key = _normalize_channel_token(source)
    target_key = _normalize_channel_token(target)
    if signal_direction == "input":
        return source_key if target_key == scope_key else ""
    if signal_direction == "output":
        return target_key if source_key == scope_key else ""
    return ""


def _port_matches_peer_key(port_name: str, peer_key: str, port_direction: str) -> bool:
    normalized_name = re.sub(r"[^a-z0-9]", "", port_name.lower())
    return peer_key in normalized_name or _channel_peer_key(port_name, port_direction) == peer_key


def _extract_channel_endpoint_pair(signal_name: str) -> tuple[str, str] | None:
    name = re.sub(r"^[io]_", "", signal_name.strip(), flags=re.IGNORECASE)
    from_to_match = re.search(r"from([A-Za-z0-9_]+?)to([A-Za-z0-9_]+)", name, flags=re.IGNORECASE)
    if from_to_match:
        return from_to_match.group(1), from_to_match.group(2)

    to_match = re.search(
        r"(?:^|_)([A-Za-z][A-Za-z0-9_]*?)(?:drive|drv|free|data)(?:to|2)([A-Za-z][A-Za-z0-9_]*)",
        name,
        flags=re.IGNORECASE,
    )
    if to_match:
        return to_match.group(1), to_match.group(2)
    return None


def _normalize_channel_token(token: str) -> str:
    normalized = re.sub(r"[^a-z0-9]", "", token.lower())
    normalized = re.sub(r"\d+$", "", normalized)
    aliases = {
        "lunch": "launch",
    }
    return aliases.get(normalized, normalized)


def _extract_channel_peer(signal_name: str, signal_direction: str) -> str:
    name = signal_name.strip()
    from_to_match = re.search(r"from([A-Za-z0-9_]+?)to([A-Za-z0-9_]+)", name, flags=re.IGNORECASE)
    if from_to_match:
        return from_to_match.group(1) if signal_direction == "input" else from_to_match.group(2)

    for pattern in (
        r"(?:drive|drv|free|data)(?:from|frm|f)([A-Za-z0-9_]+)",
        r"(?:drive|drv|free|data)(?:to|2)([A-Za-z0-9_]+)",
    ):
        match = re.search(pattern, name, flags=re.IGNORECASE)
        if match:
            return match.group(1)
    suffix_match = re.search(r"(?:^|_)(?:drive|drv|free)([A-Za-z][A-Za-z0-9_]*)$", name, flags=re.IGNORECASE)
    if suffix_match:
        return suffix_match.group(1)
    return ""


def _build_channel_name(
    scope_module: str,
    drive_name: str,
    drive_direction: str,
    peer_name: str,
) -> str:
    if not peer_name:
        return f"{scope_module}:{drive_name}"
    if drive_direction == "input":
        return f"{peer_name}_to_{scope_module}:{drive_name}"
    return f"{scope_module}_to_{peer_name}:{drive_name}"


def _payload_width_text(payload_ports: List[Dict[str, Any]]) -> str:
    widths = sorted({
        port.get("width_text", "")
        for port in payload_ports
        if port.get("width_text")
    })
    if len(widths) == 1:
        return widths[0]
    return ""


def _channel_completion_rule(free_signal: str) -> str:
    if free_signal:
        return "free signal returns completion/backpressure for this local channel."
    return "free companion is optional and was not recorded for this event channel."


def _interface_signal_group_key(signal_role: str, port_direction: str) -> str | None:
    if port_direction not in {"input", "output"}:
        return None
    suffix = "inputs" if port_direction == "input" else "outputs"
    return {
        "event_drive": f"event_{suffix}",
        "payload_data": f"payload_{suffix}",
        "condition": f"condition_{suffix}",
        "reset": f"reset_{suffix}",
    }.get(signal_role)


def _build_boundary_interfaces(ports: Iterable[Dict[str, Any]], top_module: str) -> List[Any]:
    from .models import BoundaryInterface

    aliases = _top_module_aliases(top_module)
    grouped: Dict[str, str] = {}

    for port in ports:
        port_name = port.get("name", "")
        match = re.search(r"From([A-Za-z0-9]+)to([A-Za-z0-9]+)", port_name, flags=re.IGNORECASE)
        if not match:
            continue
        src, dst = match.group(1), match.group(2)
        src_lower = src.lower()
        dst_lower = dst.lower()

        peer = ""
        direction = "bidirectional"
        if src_lower in aliases and dst_lower not in aliases:
            peer = dst
            direction = "egress"
        elif dst_lower in aliases and src_lower not in aliases:
            peer = src
            direction = "ingress"
        else:
            peer = src if src_lower not in aliases else dst

        existing = grouped.get(peer)
        if existing and existing != direction:
            grouped[peer] = "bidirectional"
        else:
            grouped[peer] = direction

    return [
        BoundaryInterface(name=name, direction=direction, channels=[]) # type: ignore
        for name, direction in sorted(grouped.items())
    ]


def _top_module_aliases(top_module: str) -> set[str]:
    lowered = top_module.lower()
    parts = [part for part in re.split(r"[^a-z0-9]+", lowered) if part]
    aliases = set(parts)
    aliases.add(lowered)
    aliases.add(lowered.replace("_", ""))
    return aliases


def _project_index_source_ref() -> SourceRef:
    return SourceRef(
        artifact_kind="project_index",
        artifact_name="project_index",
        json_ref="project_index.json",
        evidence_paths=["top_modules", "artifacts", "stats"],
    )


def _artifact_source_ref(
    record: ArtifactRecord,
    artifacts_root: Path | None,
    evidence_paths: List[str],
) -> SourceRef:
    if artifacts_root is None:
        json_ref = record.json_path.name
    else:
        json_ref = str(record.json_path.relative_to(artifacts_root))
    artifact_kind = "component" if record.artifact_kind == "derived_component" else record.artifact_kind
    return SourceRef(
        artifact_kind=artifact_kind,  # type: ignore[arg-type]
        artifact_name=record.name,
        json_ref=json_ref,
        evidence_paths=evidence_paths,
    )


def _infer_artifacts_root(kb: ProjectKnowledgeBase) -> Path | None:
    if kb.modules:
        return next(iter(kb.modules.values())).json_path.parent.parent
    if kb.components:
        return next(iter(kb.components.values())).json_path.parent.parent
    return None
