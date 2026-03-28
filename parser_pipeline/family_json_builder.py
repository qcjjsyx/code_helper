"""Build derived-component JSON artifacts from parsed modules and family templates."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

from .flow_inference import infer_signal_role, summarize_component_semantics


def load_family_templates(repo_root: Path) -> Dict[str, Dict[str, Any]]:
    template_path = repo_root / "JSON_Template" / "family_level.json"
    data = json.loads(template_path.read_text(encoding="utf-8"))
    templates = {}
    for entry in data.get("templates", []):
        family = entry.get("family")
        if family:
            templates[family] = entry
    return templates


def build_component_json(
    parse_result: Dict[str, Any],
    family: str,
    file_path: Path,
    template: Dict[str, Any],
    cc_header: Dict[str, Any],
    module_role_mapping: Dict[str, Any] | None = None,
) -> Dict[str, Any]:
    params = {item["name"]: item.get("default_text") for item in parse_result.get("params", [])}
    role_mapping = module_role_mapping or infer_role_mapping(parse_result, cc_header)
    flow_semantics = summarize_component_semantics(template, role_mapping)
    warnings = list(parse_result.get("warnings", []))
    if cc_header and not role_mapping_from_header(cc_header):
        warnings.append("cc_header present but roles missing or empty")

    return {
        "schema": "parser_pipeline_component",
        "schema_version": "1.0",
        "name": parse_result["name"],
        "artifact_kind": "derived_component",
        "family": family,
        "file": str(file_path),
        "template_source": "JSON_Template/family_level.json",
        "interface": {
            "params": params,
            "ports": parse_result.get("ports", []),
            "reset": parse_result.get("reset", {}),
        },
        "role_mapping": role_mapping,
        "contract": template.get("contract", {}),
        "flow_semantics": flow_semantics,
        "implementation_summary": {
            "internal_dependencies": sorted(
                {instance["module_type"] for instance in parse_result.get("instances", [])}
            ),
            "stops_at_family_level": True,
        },
        "warnings": warnings,
    }


def infer_role_mapping(parse_result: Dict[str, Any], cc_header: Dict[str, Any]) -> Dict[str, Any]:
    header_roles = role_mapping_from_header(cc_header)
    if header_roles:
        return {
            "upstream": {"ports": header_roles.get("upstream", [])},
            "downstream": {"ports": header_roles.get("downstream", [])},
            "payload": {"ports": header_roles.get("payload", [])},
            "fire": {"ports": header_roles.get("fire", [])},
        }

    upstream: List[str] = []
    downstream: List[str] = []
    payload: List[str] = []
    fire: List[str] = []
    condition: List[str] = []
    for port in parse_result.get("ports", []):
        role = infer_signal_role(port["name"])
        if role == "event_drive":
            if port["direction"] == "input":
                upstream.append(port["name"])
            else:
                downstream.append(port["name"])
        elif role == "event_free":
            if port["direction"] == "output":
                upstream.append(port["name"])
            else:
                downstream.append(port["name"])
        elif role == "payload_data":
            payload.append(port["name"])
        elif role == "condition":
            condition.append(port["name"])
        if "fire" in port["name"].lower():
            fire.append(port["name"])

    mapping: Dict[str, Any] = {
        "upstream": {"ports": upstream},
        "downstream": {"ports": downstream},
        "payload": {"ports": payload},
        "fire": {"ports": fire},
    }
    if condition:
        mapping["condition"] = {"ports": condition}
    return mapping


def role_mapping_from_header(cc_header: Dict[str, Any]) -> Dict[str, List[str]]:
    roles = cc_header.get("roles", {}) if cc_header else {}
    if not isinstance(roles, dict):
        return {}
    extracted: Dict[str, List[str]] = {}
    for key in ("upstream", "downstream", "payload", "fire"):
        value = roles.get(key)
        if isinstance(value, list):
            extracted[key] = value
    return extracted
