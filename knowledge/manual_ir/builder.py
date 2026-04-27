"""Build Manual IR objects from parser artifacts."""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
import re
from typing import Any, Dict, Iterable, List

from knowledge.loaders.knowledge_base import ArtifactRecord, ProjectKnowledgeBase

from .models import (
    BackpressureBehavior,
    BackpressurePoint,
    ComponentContract,
    ComponentRoleRef,
    ExternalDependencyRef,
    GeneratedFrom,
    KeyComponentRole,
    KeyInterfaces,
    ManualIR,
    ManualIRIndexes,
    ManualIRObjects,
    ModuleCard,
    ModuleRoleRef,
    ReleaseRule,
    RoleMapping,
    SemanticContract,
    SourceRef,
    SystemView,
)


@dataclass(frozen=True)
class ManualIRBuildOptions:
    schema: str = "manual_ir"
    schema_version: str = "0.1"
    build_system_view: bool = True
    build_module_cards: bool = True
    build_component_contracts: bool = True
    build_channel_cards: bool = False
    build_flow_paths: bool = False
    build_reading_paths: bool = False


@dataclass
class _ReachabilityGraph:
    top_record: ArtifactRecord
    modules_in_order: List[ArtifactRecord]
    components_in_order: List[ArtifactRecord]
    parent_modules_by_module: Dict[str, List[str]]
    parent_modules_by_component: Dict[str, List[str]]
    external_dependencies: Dict[str, List[str]]


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
    if options.build_component_contracts:
        objects.component_contracts.extend(_build_component_contracts(kb, graph, artifacts_root))

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
    if "drive" in lowered:
        return "event_drive"
    if "free" in lowered:
        return "event_free"
    if "data" in lowered:
        return "payload_data"
    return "unknown"


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
