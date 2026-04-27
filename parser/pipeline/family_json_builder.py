"""Build derived-component JSON artifacts from parsed modules and family templates."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

from .boundary_policy import is_skip_helper_module
from .flow_inference import infer_signal_role, summarize_component_semantics


def load_family_templates(repo_root: Path) -> Dict[str, Dict[str, Any]]:
    template_path = repo_root / "parser" / "schemas" / "json_templates" / "family_level.json"
    data = json.loads(template_path.read_text(encoding="utf-8"))
    templates = {}
    for entry in data.get("templates", []):
        family = entry.get("family")
        if family:
            templates[family] = entry
    return templates


def missing_family_template(family: str) -> Dict[str, Any]:
    return {
        "family": family,
        "kind": "missing_family_template",
        "contract": {},
        "_template_missing": True,
        "_template_source": "missing_family_template",
    }


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
    if template.get("_template_missing"):
        warnings.append(f"family template missing for {family}; using empty contract")

    return {
        "schema": "parser_pipeline_component",
        "schema_version": "1.0",
        "name": parse_result["name"],
        "artifact_kind": "derived_component",
        "family": family,
        "file": str(file_path),
        "template_source": template.get("_template_source", "parser/schemas/json_templates/family_level.json"),
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
                {
                    instance["module_type"]
                    for instance in parse_result.get("instances", [])
                    if not is_skip_helper_module(instance["module_type"])
                }
            ),
            "stops_at_family_level": True,
        },
        "warnings": warnings,
    }


def infer_role_mapping(parse_result: Dict[str, Any], cc_header: Dict[str, Any]) -> Dict[str, Any]:
    # cc_header is accepted for call-site compatibility; role mapping is inferred from parsed ports.
    _ = cc_header
    upstream_drive: List[str] = []
    upstream_free: List[str] = []
    downstream_drive: List[str] = []
    downstream_free: List[str] = []
    payload: List[str] = []
    fire: List[str] = []
    condition: List[str] = []
    for port in parse_result.get("ports", []):
        role = infer_signal_role(port["name"])
        if role == "event_drive":
            if port["direction"] == "input":
                upstream_drive.append(port["name"])
            else:
                downstream_drive.append(port["name"])
        elif role == "event_free":
            if port["direction"] == "output":
                upstream_free.append(port["name"])
            else:
                downstream_free.append(port["name"])
        elif role == "payload_data":
            payload.append(port["name"])
        elif role == "condition":
            condition.append(port["name"])
        if "fire" in port["name"].lower():
            fire.append(port["name"])

    mapping: Dict[str, Any] = {
        "upstream": {"ports": upstream_drive + upstream_free},
        "downstream": {"ports": downstream_drive + downstream_free},
        "payload": {"ports": payload},
        "fire": {"ports": fire},
    }
    if condition:
        mapping["condition"] = {"ports": condition}
    return mapping
