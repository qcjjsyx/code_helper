"""Infer signal and flow roles from module connections and naming rules."""

from __future__ import annotations

import re
from typing import Any, Dict, Iterable, List


def infer_signal_role(name: str) -> str:
    normalized = name.strip()
    lowered = normalized.lower()
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


def build_flow_graph(parse_result: Dict[str, Any]) -> Dict[str, List[Dict[str, Any]]]:
    signals: Dict[str, Dict[str, Any]] = {}
    edges: List[Dict[str, Any]] = []

    for port in parse_result.get("ports", []):
        signals[port["name"]] = {
            "name": port["name"],
            "kind": f"port_{port['direction']}",
            "width_text": port.get("width_text"),
            "role": infer_signal_role(port["name"]),
        }

    for signal in parse_result.get("local_signals", []):
        signals.setdefault(
            signal["name"],
            {
                "name": signal["name"],
                "kind": "local_signal",
                "width_text": signal.get("width_text"),
                "role": infer_signal_role(signal["name"]),
            },
        )

    for instance in parse_result.get("instances", []):
        for connection in instance.get("connections", []):
            signal_name = connection.get("signal") or ""
            if not signal_name:
                continue
            signals.setdefault(
                signal_name,
                {
                    "name": signal_name,
                    "kind": "expression" if _looks_like_expression(signal_name) else "implicit_signal",
                    "width_text": None,
                    "role": infer_signal_role(signal_name),
                },
            )
            port_direction = connection.get("port_direction") or "unknown"
            edges.append(
                {
                    "signal": signal_name,
                    "instance_name": instance["instance_name"],
                    "module_type": instance["module_type"],
                    "port": connection["port"],
                    "port_direction": port_direction,
                    "signal_role": connection["signal_role"],
                    "edge_kind": _edge_kind_for_direction(port_direction),
                }
            )

    return {
        "signals": sorted(signals.values(), key=lambda item: item["name"]),
        "edges": edges,
    }


def collect_family_usage(instances: Iterable[Dict[str, Any]]) -> List[str]:
    families = sorted(
        {
            instance.get("family")
            for instance in instances
            if instance.get("artifact_kind") == "derived_component" and instance.get("family")
        }
    )
    return families


def summarize_component_semantics(family_template: Dict[str, Any], role_mapping: Dict[str, Any]) -> Dict[str, str]:
    contract = family_template.get("contract", {})
    invariants = contract.get("invariants", [])
    release_rule = contract.get("release_rule", {})
    payload_ports = role_mapping.get("payload", {}).get("ports", [])
    event_behavior = invariants[0] if invariants else ""
    data_behavior = (
        f"Payload-related ports: {', '.join(payload_ports)}."
        if payload_ports
        else "This family primarily communicates through event handshakes."
    )
    completion_behavior = release_rule.get("details", "")
    if not completion_behavior and len(invariants) > 1:
        completion_behavior = invariants[1]
    return {
        "event_behavior": event_behavior,
        "data_behavior": data_behavior,
        "completion_behavior": completion_behavior,
    }


def _edge_kind_for_direction(direction: str) -> str:
    if direction == "input":
        return "signal_to_instance"
    if direction == "output":
        return "instance_to_signal"
    return "bidirectional"


def _looks_like_expression(signal_name: str) -> bool:
    return bool(re.search(r"[{}?:&|^~+\-*/\[\]()]", signal_name))
