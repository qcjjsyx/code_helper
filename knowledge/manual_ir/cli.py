"""CLI entrypoint for exporting Manual IR JSON."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Optional

from knowledge.loaders.knowledge_base import load_knowledge_base

from .builder import build_manual_ir


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(prog="knowledge.manual_ir")
    subparsers = parser.add_subparsers(dest="command", required=True)

    export_parser = subparsers.add_parser("export", help="Export Manual IR JSON from parser artifacts")
    export_parser.add_argument("--artifacts-root", required=True, help="Parser pipeline output directory")
    export_parser.add_argument("--top-module", required=True, help="Top module to build Manual IR for")
    export_parser.add_argument("--output", default=None, help="Output JSON file. Prints to stdout if omitted")
    export_parser.add_argument("--output-dir", default=None, help="Output split Manual IR JSON files into a directory")

    args = parser.parse_args(argv)

    if args.command == "export":
        if args.output and args.output_dir:
            print("error: --output and --output-dir cannot be used together", file=sys.stderr)
            return 1

        artifacts_root = Path(args.artifacts_root)
        if not artifacts_root.is_absolute():
            artifacts_root = Path.cwd().resolve() / artifacts_root

        try:
            kb = load_knowledge_base(artifacts_root)
            manual_ir = build_manual_ir(kb, args.top_module)
        except (FileNotFoundError, KeyError, json.JSONDecodeError) as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1

        manual_ir_dict = manual_ir.to_dict()
        payload = json.dumps(manual_ir_dict, ensure_ascii=False, indent=2)
        if args.output_dir:
            output_dir = Path(args.output_dir)
            if not output_dir.is_absolute():
                output_dir = Path.cwd().resolve() / output_dir
            _write_split_manual_ir(output_dir, manual_ir_dict)
            return 0

        if args.output:
            output_path = Path(args.output)
            if not output_path.is_absolute():
                output_path = Path.cwd().resolve() / output_path
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(payload + "\n", encoding="utf-8")
        else:
            print(payload)
        return 0

    return 1


def _write_split_manual_ir(output_dir: Path, manual_ir: dict) -> None:
    objects = manual_ir.get("objects", {})
    output_dir.mkdir(parents=True, exist_ok=True)

    system_views = list(objects.get("system_views", []))
    module_cards = list(objects.get("module_cards", []))
    component_contracts = list(objects.get("component_contracts", []))
    channel_cards = list(objects.get("channel_cards", []))
    flow_paths = list(objects.get("flow_paths", []))
    reading_paths = list(objects.get("reading_paths", []))

    files = {
        "system_views": "system_views.json",
        "module_cards": {},
        "channel_cards": {},
        "component_contracts": {},
    }

    _write_json_file(output_dir / "system_views.json", system_views)

    module_dir = output_dir / "module_cards"
    module_dir.mkdir(parents=True, exist_ok=True)
    for card in module_cards:
        module_name = card.get("module_name") or card.get("title") or card.get("id", "module_card")
        file_name = f"{_safe_json_filename(module_name)}.json"
        _write_json_file(module_dir / file_name, card)
        files["module_cards"][module_name] = f"module_cards/{file_name}"

    channel_dir = output_dir / "channel_cards"
    channel_dir.mkdir(parents=True, exist_ok=True)
    for card in channel_cards:
        channel_id = card.get("id") or card.get("channel_name") or card.get("title") or "channel_card"
        file_name = f"{_safe_json_filename(channel_id)}.json"
        _write_json_file(channel_dir / file_name, card)
        files["channel_cards"][channel_id] = f"channel_cards/{file_name}"

    contract_dir = output_dir / "component_contracts"
    contract_dir.mkdir(parents=True, exist_ok=True)
    for contract in component_contracts:
        component_name = contract.get("component_name") or contract.get("title") or contract.get("id", "component_contract")
        file_name = f"{_safe_json_filename(component_name)}.json"
        _write_json_file(contract_dir / file_name, contract)
        files["component_contracts"][component_name] = f"component_contracts/{file_name}"

    manifest = {
        "schema": manual_ir.get("schema"),
        "schema_version": manual_ir.get("schema_version"),
        "top_module": manual_ir.get("top_module"),
        "generated_from": manual_ir.get("generated_from", {}),
        "counts": {
            "system_views": len(system_views),
            "module_cards": len(module_cards),
            "channel_cards": len(channel_cards),
            "component_contracts": len(component_contracts),
            "flow_paths": len(flow_paths),
            "reading_paths": len(reading_paths),
        },
        "files": files,
        "indexes": manual_ir.get("indexes", {}),
        "warnings": manual_ir.get("warnings", []),
    }
    _write_json_file(output_dir / "manifest.json", manifest)


def _write_json_file(path: Path, payload: object) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _safe_json_filename(name: str) -> str:
    safe_name = "".join(char if char.isalnum() or char in "._-" else "_" for char in name)
    return safe_name.strip("._") or "manual_ir_object"
