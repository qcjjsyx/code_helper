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
SystemRole = Literal["cpu_core", "cpu_with_cache", "subsystem", "unknown"]
BoundaryDirection = Literal["ingress", "egress", "bidirectional"]
ModuleRole = Literal["top", "submodule", "leaf"]
DocumentRole = Literal[
    "front_end",
    "execute",
    "memory",
    "writeback",
    "glue",
    "adapter",
    "splitter",
    "merger",
    "arbiter",
    "fifo_stage",
    "synchronizer",
    "unknown",
]
ChannelType = Literal["event_only", "event_with_payload", "condition_gated"]
OwnerKind = Literal["module", "component", "external"]
FlowPathType = Literal["event_path", "data_path", "completion_path", "mixed"]
AudienceType = Literal["newcomer", "maintainer", "reviewer"]
DependencyStatus = Literal["interface_only", "resolved", "missing"]


@dataclass(frozen=True)
class SourceRef:
    artifact_kind: ArtifactKind
    artifact_name: str
    json_ref: str
    evidence_paths: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ManualIRObject:
    id: str
    kind: ManualIRObjectKind
    title: str
    summary: str
    top_module: str
    tags: List[str] = field(default_factory=list)
    source_refs: List[SourceRef] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    confidence: ConfidenceLevel = "medium"

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class GeneratedFrom:
    artifacts_root: str
    project_index_ref: str = "project_index.json"


@dataclass(frozen=True)
class BoundaryInterface:
    name: str
    direction: BoundaryDirection
    channels: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ModuleRoleRef:
    module: str
    role: str


@dataclass(frozen=True)
class ComponentRoleRef:
    component: str
    family: str
    role: str


@dataclass(frozen=True)
class ExternalDependencyRef:
    name: str
    status: DependencyStatus


@dataclass(frozen=True)
class SystemView(ManualIRObject):
    system_role: SystemRole = "unknown"
    boundary_interfaces: List[BoundaryInterface] = field(default_factory=list)
    primary_modules: List[ModuleRoleRef] = field(default_factory=list)
    primary_components: List[ComponentRoleRef] = field(default_factory=list)
    families_used: List[str] = field(default_factory=list)
    external_dependencies: List[ExternalDependencyRef] = field(default_factory=list)
    global_risks: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class KeyInterfaces:
    ingress_channels: List[str] = field(default_factory=list)
    egress_channels: List[str] = field(default_factory=list)
    control_signals: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class KeyComponentRole:
    component: str
    role: str


@dataclass(frozen=True)
class BackpressurePoint:
    via: str
    effect: str


@dataclass(frozen=True)
class ModuleCard(ManualIRObject):
    module_name: str = ""
    module_role: ModuleRole = "submodule"
    parent_modules: List[str] = field(default_factory=list)
    document_role: DocumentRole = "unknown"
    responsibilities: List[str] = field(default_factory=list)
    key_interfaces: KeyInterfaces = field(default_factory=KeyInterfaces)
    upstream_modules: List[str] = field(default_factory=list)
    downstream_modules: List[str] = field(default_factory=list)
    child_modules: List[str] = field(default_factory=list)
    child_components: List[str] = field(default_factory=list)
    key_component_roles: List[KeyComponentRole] = field(default_factory=list)
    internal_flow_paths: List[str] = field(default_factory=list)
    backpressure_points: List[BackpressurePoint] = field(default_factory=list)
    risk_points: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ChannelEndpoint:
    owner_kind: OwnerKind
    owner_name: str
    drive_signal: str = ""
    payload_signals: List[str] = field(default_factory=list)
    free_signal: str = ""


@dataclass(frozen=True)
class ChannelPayload:
    present: bool
    width_text: str = ""
    signals: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class HandshakeRule:
    drive: str
    free: str
    completion_rule: str
    backpressure_supported: bool = True


@dataclass(frozen=True)
class ChannelConditioning:
    has_condition: bool = False
    signals: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ChannelCard(ManualIRObject):
    scope_module: str = ""
    channel_name: str = ""
    channel_type: ChannelType = "event_with_payload"
    producer: ChannelEndpoint = field(default_factory=lambda: ChannelEndpoint(owner_kind="module", owner_name=""))
    consumer: ChannelEndpoint = field(default_factory=lambda: ChannelEndpoint(owner_kind="module", owner_name=""))
    payload: ChannelPayload = field(default_factory=lambda: ChannelPayload(present=False))
    handshake: HandshakeRule = field(default_factory=lambda: HandshakeRule(drive="", free="", completion_rule=""))
    conditioning: ChannelConditioning = field(default_factory=ChannelConditioning)
    implemented_by_path: List[str] = field(default_factory=list)
    related_flow_paths: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class RoleMapping:
    upstream: List[str] = field(default_factory=list)
    downstream: List[str] = field(default_factory=list)
    payload: List[str] = field(default_factory=list)
    condition: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class SemanticContract:
    event_behavior: str
    data_behavior: str
    completion_behavior: str


@dataclass(frozen=True)
class ReleaseRule:
    policy: str
    details: str


@dataclass(frozen=True)
class BackpressureBehavior:
    can_block_upstream: bool
    blocking_condition: str


@dataclass(frozen=True)
class ComponentContract(ManualIRObject):
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
    family_invariants: List[str] = field(default_factory=list)
    implementation_notes: List[str] = field(default_factory=list)
    used_in_channels: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class SignalEndpoint:
    owner: str
    signal: str


@dataclass(frozen=True)
class FlowStep:
    order: int
    node_kind: Literal["interface", "module", "component", "signal_group"]
    node_name: str
    role: str = ""


@dataclass(frozen=True)
class FlowDecisionPoint:
    node: str
    reason: str


@dataclass(frozen=True)
class FlowBlockingPoint:
    node: str
    reason: str


@dataclass(frozen=True)
class FlowPath(ManualIRObject):
    scope_module: str = ""
    path_type: FlowPathType = "mixed"
    startpoints: List[SignalEndpoint] = field(default_factory=list)
    endpoints: List[SignalEndpoint] = field(default_factory=list)
    steps: List[FlowStep] = field(default_factory=list)
    branch_points: List[FlowDecisionPoint] = field(default_factory=list)
    join_points: List[FlowDecisionPoint] = field(default_factory=list)
    completion_return_path: List[str] = field(default_factory=list)
    blocking_points: List[FlowBlockingPoint] = field(default_factory=list)
    covered_channels: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ReadingSection:
    section_id: str
    title: str
    covers: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ReadingPath(ManualIRObject):
    audience: AudienceType = "newcomer"
    goals: List[str] = field(default_factory=list)
    ordered_sections: List[ReadingSection] = field(default_factory=list)
    must_cover: List[str] = field(default_factory=list)
    defer_sections: List[str] = field(default_factory=list)
    risk_reminders: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class ManualIRObjects:
    system_views: List[SystemView] = field(default_factory=list)
    module_cards: List[ModuleCard] = field(default_factory=list)
    channel_cards: List[ChannelCard] = field(default_factory=list)
    component_contracts: List[ComponentContract] = field(default_factory=list)
    flow_paths: List[FlowPath] = field(default_factory=list)
    reading_paths: List[ReadingPath] = field(default_factory=list)


@dataclass(frozen=True)
class ManualIRIndexes:
    by_id: Dict[str, str] = field(default_factory=dict)
    by_module: Dict[str, List[str]] = field(default_factory=dict)
    by_family: Dict[str, List[str]] = field(default_factory=dict)
    by_tag: Dict[str, List[str]] = field(default_factory=dict)


@dataclass(frozen=True)
class ManualIR:
    schema: str
    schema_version: str
    top_module: str
    generated_from: GeneratedFrom
    objects: ManualIRObjects = field(default_factory=ManualIRObjects)
    indexes: ManualIRIndexes = field(default_factory=ManualIRIndexes)
    warnings: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)
