from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from docgen_sv.config import load_config
from docgen_sv.parser import ParsedModule, parse_verilog, scan_verilog_files, sha256_bytes


def iso_timestamp() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def default_kind(name: str, file_name: str) -> str:
    if name.startswith("c") and "Fifo" in file_name:
        return "component"
    return "primitive"


def default_category(name: str) -> str:
    if "Relay" in name:
        return "handshake_relay"
    if "Fifo" in name:
        return "base_pipeline"
    if "delay" in name or "Delay" in name:
        return "delay"
    if "event" in name or "Event" in name:
        return "event"
    if "Tap" in name:
        return "toggle"
    return "unknown"


def infer_reset(ports: list[dict]) -> dict:
    reset_signal = None
    for port in ports:
        name = port.get("name", "").lower()
        if name in {"rstn", "resetn", "rst_n", "reset_n"}:
            reset_signal = port["name"]
            break
        if ("rst" in name or "reset" in name) and name.endswith("n"):
            reset_signal = port["name"]
            break
    if reset_signal:
        return {"present": True, "signal": reset_signal, "active_low": True}
    return {"present": False, "signal": None, "active_low": None}


def build_entry(
    repo_root: Path,
    file_path: Path,
    module: ParsedModule,
    known_modules: set[str],
    config: dict[str, Any],
    sha256: str,
) -> dict[str, Any]:
    rel_path = str(file_path.relative_to(repo_root))
    kind_overrides = config.get("kind_overrides", {})
    category_overrides = config.get("category_overrides", {})
    kind = kind_overrides.get(module.name, default_kind(module.name, file_path.name))
    category = category_overrides.get(module.name, default_category(module.name))

    deps: list[str] = []
    tech_cells: list[str] = []
    for instance in module.instances:
        if instance in known_modules:
            deps.append(instance)
        else:
            tech_cells.append(instance)

    entry = {
        "name": module.name,
        "kind": kind,
        "file": rel_path,
        "sha256": sha256,
        "language": "verilog",
        "ports": module.ports,
        "params": module.params,
        "deps_primitives": sorted(set(deps)),
        "tech_cells": sorted(set(tech_cells)),
        "reset": infer_reset(module.ports),
        "category": category,
        "protocol": "unknown",
        "port_roles": {},
        "semantics_1line": "",
        "constraints": [],
        "gotchas": [],
        "updated_at": iso_timestamp(),
        "deleted": False,
    }
    if module.errors:
        entry["parse_errors"] = module.errors
    return entry


def load_registry(registry_path: Path) -> dict[str, Any]:
    if not registry_path.exists():
        return {
            "meta": {
                "generated_at": None,
                "repo_root": None,
                "entries_count": 0,
            },
            "entries": [],
        }
    with registry_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def save_registry(registry_path: Path, data: dict[str, Any]) -> None:
    registry_path.parent.mkdir(parents=True, exist_ok=True)
    with registry_path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=2)
        handle.write("\n")


def index_entries(entries: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {entry["file"]: entry for entry in entries}


def scan_modules(repo_root: Path, paths: list[Path]) -> dict[Path, ParsedModule]:
    modules: dict[Path, ParsedModule] = {}
    for file_path in scan_verilog_files(paths):
        modules[file_path] = parse_verilog(file_path)
    return modules


def generate_registry(repo_root: Path, inputs: list[Path]) -> dict[str, Any]:
    config = load_config(repo_root)
    registry_path = repo_root / ".docgen" / "primitive_registry.json"
    registry = load_registry(registry_path)
    entry_map = index_entries(registry.get("entries", []))
    modules = scan_modules(repo_root, inputs)
    known_modules = {parsed.name for parsed in modules.values()}

    current_files = set()
    entries: list[dict[str, Any]] = []
    for file_path, parsed in modules.items():
        rel_path = str(file_path.relative_to(repo_root))
        current_files.add(rel_path)
        raw_bytes = file_path.read_bytes()
        digest = sha256_bytes(raw_bytes)
        existing = entry_map.get(rel_path)
        if existing and existing.get("sha256") == digest and not existing.get("deleted", False):
            entries.append(existing)
            continue
        entries.append(
            build_entry(repo_root, file_path, parsed, known_modules, config, digest)
        )

    for rel_path, entry in entry_map.items():
        if rel_path not in current_files:
            entry["deleted"] = True
            entry["updated_at"] = iso_timestamp()
            entries.append(entry)

    registry = {
        "meta": {
            "generated_at": iso_timestamp(),
            "repo_root": str(repo_root),
            "entries_count": len(entries),
        },
        "entries": sorted(entries, key=lambda item: item["name"]),
    }
    save_registry(registry_path, registry)
    return registry


def update_registry(repo_root: Path, changed_files: list[Path]) -> dict[str, Any]:
    config = load_config(repo_root)
    registry_path = repo_root / ".docgen" / "primitive_registry.json"
    registry = load_registry(registry_path)
    entries = registry.get("entries", [])
    entry_map = index_entries(entries)

    existing_files = {Path(repo_root / entry["file"]) for entry in entries if not entry.get("deleted")}
    modules: dict[Path, ParsedModule] = {}
    for file_path in scan_verilog_files(changed_files):
        if file_path.exists():
            modules[file_path] = parse_verilog(file_path)

    known_modules = {parse_verilog(path).name for path in existing_files if path.exists()}
    known_modules.update({parsed.name for parsed in modules.values()})

    updated_paths = set()
    for file_path, parsed in modules.items():
        rel_path = str(file_path.relative_to(repo_root))
        updated_paths.add(rel_path)
        raw_bytes = file_path.read_bytes()
        digest = sha256_bytes(raw_bytes)
        existing = entry_map.get(rel_path)
        if existing and existing.get("sha256") == digest and not existing.get("deleted", False):
            continue
        entry_map[rel_path] = build_entry(
            repo_root, file_path, parsed, known_modules, config, digest
        )

    for file_path in changed_files:
        if not file_path.exists():
            rel_path = str(file_path.relative_to(repo_root))
            entry = entry_map.get(rel_path)
            if entry:
                entry["deleted"] = True
                entry["updated_at"] = iso_timestamp()
                updated_paths.add(rel_path)

    registry = {
        "meta": {
            "generated_at": iso_timestamp(),
            "repo_root": str(repo_root),
            "entries_count": len(entry_map),
        },
        "entries": sorted(entry_map.values(), key=lambda item: item["name"]),
    }
    save_registry(registry_path, registry)
    return registry
