"""Orchestrate recursive module parsing and JSON artifact generation."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Set

from .cc_header_reader import read_cc_header
from .classifier import classify_artifact
from .family_inference import infer_family
from .family_json_builder import build_component_json, load_family_templates
from .flow_inference import build_flow_graph, collect_family_usage, infer_signal_role
from .module_index import build_module_index
from .module_parser import parse_verilog_file


@dataclass
class BuildContext:
    repo_root: Path
    module_index: Dict[str, Path]
    top_module_names: Set[str]
    family_templates: Dict[str, Dict[str, Any]]
    parsed_modules: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    module_jsons: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    component_jsons: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    hierarchy_nodes: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    issues: List[Dict[str, Any]] = field(default_factory=list)


def build_project(repo_root: Path, inputs: List[str], tops: List[str], output_dir: Path) -> Dict[str, Any]:
    top_paths = {_resolve_path(repo_root, item) for item in tops}
    module_index = build_module_index(repo_root, inputs, top_paths)
    top_module_names = set()
    for top_path in top_paths:
        top_parse = parse_verilog_file(top_path)
        if top_parse["name"]:
            top_module_names.add(top_parse["name"])
            module_index.setdefault(top_parse["name"], top_path)

    context = BuildContext(
        repo_root=repo_root,
        module_index=module_index,
        top_module_names=top_module_names,
        family_templates=load_family_templates(repo_root),
    )

    top_entries = []
    for top_path in tops:
        resolved_top_path = _resolve_path(repo_root, top_path)
        top_parse = parse_verilog_file(resolved_top_path)
        top_name = top_parse["name"]
        if not top_name:
            continue
        _build_module_artifact(context, top_name)
        top_entries.append(
            {
                "name": top_name,
                "file": _relative_path(repo_root, resolved_top_path),
                "json_ref": f"modules/{top_name}.json",
            }
        )

    project_index = _build_project_index(context, inputs, top_entries)
    build_report = _build_report(context, output_dir)
    return {
        "modules": context.module_jsons,
        "components": context.component_jsons,
        "project_index": project_index,
        "build_report": build_report,
    }


def _build_module_artifact(context: BuildContext, module_name: str) -> Dict[str, Any]:
    if module_name in context.module_jsons:
        return context.module_jsons[module_name]

    file_path = context.module_index[module_name]
    parse_result = _parse_with_cache(context, module_name, file_path)
    cc_header = read_cc_header(file_path)
    artifact_info = classify_artifact(
        module_name,
        str(file_path),
        context.module_index,
        context.top_module_names,
        cc_header=cc_header,
    )

    if artifact_info["artifact_kind"] == "derived_component":
        component_json = _build_component_artifact(context, module_name)
        return component_json

    hierarchy_children: List[Dict[str, Any]] = []
    enriched_instances: List[Dict[str, Any]] = []
    direct_modules: List[str] = []
    direct_components: List[str] = []

    for instance in parse_result.get("instances", []):
        target_module = instance["module_type"]
        target_path = context.module_index.get(target_module)
        target_header = read_cc_header(target_path) if target_path else {}
        target_info = classify_artifact(
            target_module,
            str(target_path or target_module),
            context.module_index,
            context.top_module_names,
            cc_header=target_header,
        )
        target_kind = "module" if target_info["artifact_kind"] == "top_module" else target_info["artifact_kind"]
        target_parse = _parse_with_cache(context, target_module, target_path) if target_path else None
        connections = _enrich_connections(instance["connections"], target_parse)
        target_ref = _target_ref(target_kind, target_module)

        enriched_instance = {
            "instance_name": instance["instance_name"],
            "module_type": target_module,
            "artifact_kind": target_kind,
            "target_ref": target_ref,
            "parameter_overrides": instance["parameter_overrides"],
            "connections": connections,
        }
        if target_info.get("family"):
            enriched_instance["family"] = target_info["family"]
        enriched_instances.append(enriched_instance)

        child_node = {
            "instance_name": instance["instance_name"],
            "target": target_module,
            "artifact_kind": target_kind,
        }
        if target_path:
            child_node["file"] = _relative_path(context.repo_root, target_path)

        if target_kind == "module":
            child_artifact = _build_module_artifact(context, target_module)
            child_node["children"] = context.hierarchy_nodes[target_module]["children"]
            direct_modules.append(target_module)
        elif target_kind == "derived_component":
            _build_component_artifact(context, target_module)
            direct_components.append(target_module)
            child_node["family"] = target_info["family"]
        else:
            context.issues.append(
                {
                    "level": "warning",
                    "message": f"unresolved instance target: {target_module}",
                    "file": _relative_path(context.repo_root, file_path),
                    "module": module_name,
                }
            )
        hierarchy_children.append(child_node)

    module_role = "submodule"
    if module_name in context.top_module_names:
        module_role = "top"
    elif not direct_modules and not direct_components:
        module_role = "leaf"

    flow_graph = build_flow_graph(
        {
            "ports": parse_result.get("ports", []),
            "local_signals": parse_result.get("local_signals", []),
            "instances": enriched_instances,
        }
    )

    module_json = {
        "schema": "parser_pipeline_module",
        "schema_version": "1.0",
        "name": module_name,
        "artifact_kind": "module",
        "module_role": module_role,
        "file": _relative_path(context.repo_root, file_path),
        "interface": {
            "params": parse_result.get("params", []),
            "ports": parse_result.get("ports", []),
            "reset": parse_result.get("reset", {}),
        },
        "local_signals": parse_result.get("local_signals", []),
        "instances": enriched_instances,
        "direct_children": {
            "modules": sorted(set(direct_modules)),
            "components": sorted(set(direct_components)),
        },
        "flow_graph": flow_graph,
        "transitive_summary": {},
        "warnings": parse_result.get("warnings", []),
    }

    context.module_jsons[module_name] = module_json
    context.hierarchy_nodes[module_name] = {
        "module": module_name,
        "file": _relative_path(context.repo_root, file_path),
        "children": hierarchy_children,
    }
    module_json["transitive_summary"] = _compute_transitive_summary(context, module_name)
    return module_json


def _build_component_artifact(context: BuildContext, module_name: str) -> Dict[str, Any]:
    if module_name in context.component_jsons:
        return context.component_jsons[module_name]

    file_path = context.module_index[module_name]
    parse_result = _parse_with_cache(context, module_name, file_path)
    cc_header = read_cc_header(file_path)
    family_info = infer_family(module_name=module_name, file_path=str(file_path), cc_header=cc_header)
    family = family_info["family"]
    template = context.family_templates[family]
    component_json = build_component_json(parse_result, family, file_path, template, cc_header)
    component_json["file"] = _relative_path(context.repo_root, file_path)
    context.component_jsons[module_name] = component_json
    return component_json


def _parse_with_cache(context: BuildContext, module_name: str, file_path: Path | None) -> Dict[str, Any]:
    if module_name in context.parsed_modules:
        return context.parsed_modules[module_name]
    if file_path is None:
        return {"name": module_name, "ports": [], "params": [], "reset": {}, "local_signals": [], "instances": [], "warnings": []}
    parsed = parse_verilog_file(file_path)
    context.parsed_modules[module_name] = parsed
    return parsed


def _enrich_connections(connections: List[Dict[str, Any]], target_parse: Dict[str, Any] | None) -> List[Dict[str, Any]]:
    port_direction_map = {}
    if target_parse:
        port_direction_map = {port["name"]: port["direction"] for port in target_parse.get("ports", [])}

    enriched = []
    for connection in connections:
        signal = connection.get("signal", "")
        enriched.append(
            {
                **connection,
                "port_direction": port_direction_map.get(connection["port"], "unknown"),
                "signal_role": infer_signal_role(signal),
            }
        )
    return enriched


def _compute_transitive_summary(context: BuildContext, module_name: str) -> Dict[str, Any]:
    visited_modules: Set[str] = set()
    reachable_modules: Set[str] = set()
    reachable_components: Set[str] = set()
    families_used: Set[str] = set()

    def walk(name: str) -> None:
        if name in visited_modules:
            return
        visited_modules.add(name)
        module_json = context.module_jsons.get(name)
        if not module_json:
            return
        for instance in module_json.get("instances", []):
            kind = instance.get("artifact_kind")
            target = instance.get("module_type")
            if kind == "module":
                reachable_modules.add(target)
                if target in context.module_jsons:
                    walk(target)
            elif kind == "derived_component":
                reachable_components.add(target)
                family = instance.get("family")
                if family:
                    families_used.add(family)

    walk(module_name)
    reachable_modules.discard(module_name)
    return {
        "reachable_modules": sorted(reachable_modules),
        "reachable_components": sorted(reachable_components),
        "families_used": sorted(families_used),
    }


def _build_project_index(context: BuildContext, inputs: List[str], top_entries: List[Dict[str, Any]]) -> Dict[str, Any]:
    all_instances = [
        instance
        for module_json in context.module_jsons.values()
        for instance in module_json.get("instances", [])
    ]
    artifacts_modules = [
        {
            "name": name,
            "file": payload["file"],
            "json_ref": f"modules/{name}.json",
        }
        for name, payload in sorted(context.module_jsons.items())
    ]
    artifacts_components = [
        {
            "name": name,
            "family": payload["family"],
            "file": payload["file"],
            "json_ref": f"components/{name}.json",
        }
        for name, payload in sorted(context.component_jsons.items())
    ]
    hierarchies = {
        top_name: context.hierarchy_nodes[top_name]
        for top_name in context.top_module_names
        if top_name in context.hierarchy_nodes
    }
    warning_count = sum(len(payload.get("warnings", [])) for payload in context.module_jsons.values())
    warning_count += sum(len(payload.get("warnings", [])) for payload in context.component_jsons.values())
    warning_count += len(context.issues)
    unresolved_instance_count = sum(
        1 for instance in all_instances if instance.get("artifact_kind") == "external_dependency"
    )

    return {
        "schema": "parser_pipeline_project_index",
        "schema_version": "1.0",
        "repo_root": str(context.repo_root),
        "generated_at": _now_iso(),
        "input_roots": inputs,
        "top_modules": top_entries,
        "artifacts": {
            "modules": artifacts_modules,
            "components": artifacts_components,
        },
        "hierarchies": hierarchies,
        "stats": {
            "module_count": len(context.module_jsons),
            "component_count": len(context.component_jsons),
            "unresolved_instance_count": unresolved_instance_count,
            "warning_count": warning_count,
        },
    }


def _build_report(context: BuildContext, output_dir: Path) -> Dict[str, Any]:
    return {
        "schema": "parser_pipeline_build_report",
        "schema_version": "1.0",
        "generated_at": _now_iso(),
        "output_dir": str(output_dir),
        "issues": context.issues,
        "module_names": sorted(context.module_jsons.keys()),
        "component_names": sorted(context.component_jsons.keys()),
        "families_used": collect_family_usage(
            instance
            for module_json in context.module_jsons.values()
            for instance in module_json.get("instances", [])
        ),
    }


def _target_ref(kind: str, module_name: str) -> str | None:
    if kind == "module":
        return f"../modules/{module_name}.json"
    if kind == "derived_component":
        return f"../components/{module_name}.json"
    return None


def _resolve_path(repo_root: Path, item: str) -> Path:
    path = Path(item)
    if not path.is_absolute():
        path = repo_root / item
    return path.resolve()


def _relative_path(repo_root: Path, path: Path) -> str:
    return str(path.resolve().relative_to(repo_root.resolve()))


def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
