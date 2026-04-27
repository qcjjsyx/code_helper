"""Build structured context for automatic code-manual generation."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, List

from knowledge.loaders.knowledge_base import ProjectKnowledgeBase

from .builder import build_manual_ir
from .models import ComponentContract, ModuleCard


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
    manual_ir = build_manual_ir(kb, top_module)

    return ManualContext(
        top_module=top_module,
        top_module_payload=top_record.payload,
        module_summaries=[_summarize_module(kb, card) for card in manual_ir.objects.module_cards],
        component_summaries=[_summarize_component(kb, contract) for contract in manual_ir.objects.component_contracts],
    )


def _summarize_module(kb: ProjectKnowledgeBase, card: ModuleCard) -> Dict[str, Any]:
    record = kb.modules.get(card.module_name)
    payload = record.payload if record else {}
    interface = payload.get("interface", {})
    return {
        "name": card.module_name,
        "file": record.file if record else "",
        "module_role": card.module_role,
        "document_role": card.document_role,
        "responsibilities": list(card.responsibilities),
        "key_interfaces": {
            "ingress_channels": list(card.key_interfaces.ingress_channels),
            "egress_channels": list(card.key_interfaces.egress_channels),
            "control_signals": list(card.key_interfaces.control_signals),
        },
        "ports": [port.get("name") for port in interface.get("ports", [])],
        "direct_children": payload.get("direct_children", {}),
        "key_component_roles": [
            {
                "component": item.component,
                "role": item.role,
            }
            for item in card.key_component_roles
        ],
        "backpressure_points": [
            {
                "via": item.via,
                "effect": item.effect,
            }
            for item in card.backpressure_points
        ],
        "risk_points": list(card.risk_points),
        "transitive_summary": payload.get("transitive_summary", {}),
        "flow_graph": {
            "signal_count": len(payload.get("flow_graph", {}).get("signals", [])),
            "edge_count": len(payload.get("flow_graph", {}).get("edges", [])),
            "sample_edges": payload.get("flow_graph", {}).get("edges", [])[:12],
        },
    }


def _summarize_component(kb: ProjectKnowledgeBase, contract: ComponentContract) -> Dict[str, Any]:
    record = kb.components.get(contract.component_name)
    payload = record.payload if record else {}
    return {
        "name": contract.component_name,
        "file": record.file if record else "",
        "family": contract.family,
        "role_mapping": {
            "upstream": {"ports": list(contract.role_mapping.upstream)},
            "downstream": {"ports": list(contract.role_mapping.downstream)},
            "payload": {"ports": list(contract.role_mapping.payload)},
            "condition": {"ports": list(contract.role_mapping.condition)},
        },
        "flow_semantics": {
            "event_behavior": contract.semantic_contract.event_behavior,
            "data_behavior": contract.semantic_contract.data_behavior,
            "completion_behavior": contract.semantic_contract.completion_behavior,
        },
        "contract": {
            "invariants": list(contract.family_invariants),
            "release_rule": {
                "policy": contract.release_rule.policy,
                "details": contract.release_rule.details,
            },
        },
        "implementation_summary": payload.get("implementation_summary", {}),
    }
