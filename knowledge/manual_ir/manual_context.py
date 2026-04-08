"""Build structured context for automatic code-manual generation."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, List, Set

from knowledge.loaders.knowledge_base import ArtifactRecord, ProjectKnowledgeBase


@dataclass(frozen=True)
class ManualContext:
    top_module: str
    top_module_payload: Dict[str, Any]
    module_summaries: List[Dict[str, Any]]
    component_summaries: List[Dict[str, Any]]


def build_manual_context(kb: ProjectKnowledgeBase, top_module: str) -> ManualContext:
    top_record = kb.modules.get(top_module)
    if top_record is None:
        raise KeyError(f"top module not found: {top_module}")

    visited_modules: Set[str] = set()
    modules: List[ArtifactRecord] = []
    components: List[ArtifactRecord] = []
    seen_components: Set[str] = set()

    def walk(module_name: str) -> None:
        if module_name in visited_modules:
            return
        visited_modules.add(module_name)
        record = kb.modules.get(module_name)
        if record is None:
            return
        modules.append(record)

        payload = record.payload
        for child_name in payload.get("direct_children", {}).get("modules", []):
            walk(child_name)
        for child_name in payload.get("direct_children", {}).get("components", []):
            component = kb.components.get(child_name)
            if component and component.name not in seen_components:
                seen_components.add(component.name)
                components.append(component)

    walk(top_module)

    return ManualContext(
        top_module=top_module,
        top_module_payload=top_record.payload,
        module_summaries=[_summarize_module(record) for record in modules],
        component_summaries=[_summarize_component(record) for record in components],
    )


def _summarize_module(record: ArtifactRecord) -> Dict[str, Any]:
    payload = record.payload
    interface = payload.get("interface", {})
    return {
        "name": record.name,
        "file": record.file,
        "module_role": payload.get("module_role"),
        "ports": [port.get("name") for port in interface.get("ports", [])],
        "direct_children": payload.get("direct_children", {}),
        "transitive_summary": payload.get("transitive_summary", {}),
        "flow_graph": {
            "signal_count": len(payload.get("flow_graph", {}).get("signals", [])),
            "edge_count": len(payload.get("flow_graph", {}).get("edges", [])),
            "sample_edges": payload.get("flow_graph", {}).get("edges", [])[:12],
        },
    }


def _summarize_component(record: ArtifactRecord) -> Dict[str, Any]:
    payload = record.payload
    return {
        "name": record.name,
        "file": record.file,
        "family": payload.get("family"),
        "role_mapping": payload.get("role_mapping", {}),
        "flow_semantics": payload.get("flow_semantics", {}),
        "contract": {
            "invariants": payload.get("contract", {}).get("invariants", []),
            "release_rule": payload.get("contract", {}).get("release_rule", {}),
        },
        "implementation_summary": payload.get("implementation_summary", {}),
    }
