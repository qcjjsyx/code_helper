import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

from .parser import parse_verilog_file
from .render import render_components_md

TARGET_FILENAMES = [
    "cArbMergeN_modName.v",
    "cMutexMergeN_modName.v",
    "cNatSplitN_modName.v",
    "cSelSplitN_modName.v",
    "cWaitMergeN_modName.v",
    "cFifo1_modName.v",
    "cPmtFifo1_modName.v",
]

DEFAULT_PRIMITIVES = {
    "sender",
    "relay",
    "receiver",
    "contTap",
    "freeSetDelay",
    "pmtRelay",
    "delay1U",
    "eventSource",
    "eventSink",
}

TECH_CELL_PREFIXES = (
    "INV",
    "XOR",
    "XNOR",
    "DRNQV",
    "DEL",
    "BUF",
    "CLK",
    "AND",
    "OR",
    "NAND",
    "NOR",
    "DFF",
    "MUX",
    "AOI",
    "OAI",
)


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def build_known_components():
    names = set()
    for fname in TARGET_FILENAMES:
        stem = Path(fname).stem
        names.add(stem)
        if stem.endswith("_modName"):
            names.add(stem[: -len("_modName")])
    return names


def load_known_primitives(repo_root: Path):
    names = set(DEFAULT_PRIMITIVES)
    registry_path = repo_root / ".docgen" / "primitive_registry.json"
    if registry_path.exists():
        try:
            data = json.loads(registry_path.read_text(encoding="utf-8"))
            for entry in data.get("entries", []):
                if "name" in entry:
                    names.add(entry["name"])
        except json.JSONDecodeError:
            pass
    return names


def discover_inputs(repo_root: Path, inputs):
    found = {}
    for item in inputs:
        path = Path(item)
        if not path.is_absolute():
            path = repo_root / path
        if path.is_dir():
            for target in TARGET_FILENAMES:
                for match in path.rglob(target):
                    found.setdefault(target, match)
        elif path.is_file() and path.name in TARGET_FILENAMES:
            found.setdefault(path.name, path)

    ordered = [found[name] for name in TARGET_FILENAMES if name in found]
    return ordered


def load_kb(repo_root: Path):
    kb_path = repo_root / ".docgen" / "component_kb.json"
    if not kb_path.exists():
        return {"meta": {}, "entries": []}
    return json.loads(kb_path.read_text(encoding="utf-8"))


def save_kb(repo_root: Path, kb: dict):
    kb_path = repo_root / ".docgen" / "component_kb.json"
    kb_path.parent.mkdir(parents=True, exist_ok=True)
    kb_path.write_text(json.dumps(kb, indent=2), encoding="utf-8")


def render_repo(repo_root: Path):
    kb = load_kb(repo_root)
    md_text = render_components_md(kb)
    md_path = repo_root / "docs" / "COMPONENTS.md"
    md_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.write_text(md_text, encoding="utf-8")


def init_repo(repo_root: Path, inputs, force: bool = False):
    known_primitives = load_known_primitives(repo_root)
    known_components = build_known_components()
    files = discover_inputs(repo_root, inputs)
    entries = []
    for path in files:
        entries.append(build_entry(path, repo_root, known_primitives, known_components))
    kb = {
        "meta": {
            "generated_at": now_iso(),
            "repo_root": str(repo_root),
            "entries_count": len(entries),
        },
        "entries": entries,
    }
    save_kb(repo_root, kb)
    render_repo(repo_root)


def update_repo(repo_root: Path, changed_files, force: bool = False):
    known_primitives = load_known_primitives(repo_root)
    known_components = build_known_components()
    files = discover_inputs(repo_root, changed_files)

    kb = load_kb(repo_root)
    entries = kb.get("entries", [])
    index_by_file = {entry.get("file"): idx for idx, entry in enumerate(entries)}

    for path in files:
        entry = build_entry(path, repo_root, known_primitives, known_components)
        existing_idx = index_by_file.get(entry["file"])
        if existing_idx is not None:
            if entries[existing_idx].get("sha256") == entry["sha256"] and not force:
                continue
            entries[existing_idx] = entry
        else:
            entries.append(entry)

    kb["meta"] = {
        "generated_at": now_iso(),
        "repo_root": str(repo_root),
        "entries_count": len(entries),
    }
    kb["entries"] = entries
    save_kb(repo_root, kb)
    render_repo(repo_root)


def build_entry(
    path: Path, repo_root: Path, known_primitives: set, known_components: set
):
    parsed = parse_verilog_file(path)
    rel_path = _relative_path(repo_root, path)
    sha256 = _file_sha256(path)
    name = parsed["name"] or path.stem
    component_type = infer_component_type(name)
    deps = classify_deps(parsed["instantiations"], known_components, known_primitives)
    contract = build_contract(parsed["ports"], component_type)

    return {
        "name": name,
        "file": rel_path,
        "sha256": sha256,
        "params": parsed["params"],
        "ports": parsed["ports"],
        "deps": deps,
        "component_type": component_type,
        "contract": contract,
        "customization_guide": parsed["customization_guide"],
        "semantics_1line": semantics_for(component_type),
        "gotchas": derive_gotchas(parsed["params"], parsed["ports"], component_type),
        "updated_at": now_iso(),
        "parse_errors": parsed["errors"],
    }


def infer_component_type(name: str) -> str:
    lowered = name.lower()
    if "arbmerge" in lowered:
        return "arb_merge"
    if "waitmerge" in lowered:
        return "wait_merge"
    if "mutexmerge" in lowered:
        return "mutex_merge"
    if "natsplit" in lowered:
        return "nat_split"
    if "selsplit" in lowered:
        return "sel_split"
    if "pmtfifo" in lowered:
        return "pmt_fifo"
    if "fifo" in lowered:
        return "fifo"
    return "unknown"


def semantics_for(component_type: str) -> str:
    mapping = {
        "arb_merge": "Arbitrates among inputs and merges data into a single output.",
        "wait_merge": "Waits for all inputs ready before merging into one output.",
        "mutex_merge": "Merges inputs with mutual exclusion behavior.",
        "nat_split": "Splits one input into multiple outputs with natural mapping.",
        "sel_split": "Splits one input into multiple outputs based on selection.",
        "fifo": "Provides single-stage FIFO buffering for a channel.",
        "pmt_fifo": "Provides single-stage FIFO buffering with permit control.",
    }
    return mapping.get(component_type, "")


def classify_deps(instantiations, known_components, known_primitives):
    components = []
    primitives = []
    primitives_raw = []
    tech_cells = []
    unresolved = []
    aliases = []

    for raw in instantiations:
        normalized = raw
        if re.match(r"^delay\d+U$", raw):
            normalized = "delay1U"
            if raw != normalized:
                aliases.append({"from": raw, "to": normalized})

        if raw in known_components or normalized in known_components:
            components.append(raw if raw in known_components else normalized)
        elif normalized in known_primitives or raw in known_primitives:
            prim_name = normalized if normalized in known_primitives else raw
            primitives.append(prim_name)
            primitives_raw.append(raw)
        elif is_tech_cell(raw):
            tech_cells.append(raw)
        else:
            unresolved.append(raw)

    return {
        "components": _unique(components),
        "primitives": _unique(primitives),
        "primitives_raw": _unique(primitives_raw),
        "tech_cells": _unique(tech_cells),
        "unresolved": _unique(unresolved),
        "aliases": _unique_aliases(aliases),
    }


def is_tech_cell(name: str) -> bool:
    return any(name.startswith(prefix) for prefix in TECH_CELL_PREFIXES)


def build_contract(ports, component_type: str):
    names = [port["name"] for port in ports]
    drive_map = _indexed_map(names, "i_drive")
    data_map = _indexed_map(names, "i_data")
    free_map = _indexed_map(names, "o_free")

    indices = sorted(set(drive_map) | set(data_map) | set(free_map))
    if not indices and ("i_drive" in names or "i_data" in names or "o_free" in names):
        indices = [0]

    inputs = []
    for idx in indices:
        inputs.append(
            {
                "drive_port": drive_map.get(idx),
                "data_port": data_map.get(idx),
                "free_port": free_map.get(idx),
                "index": idx,
            }
        )

    drive_next_port = _first_match(names, ["o_driveNext", "o_driveNext_n"])
    data_port = "o_data" if "o_data" in names else None
    free_port = "o_free" if "o_free" in names else None
    free_next_port = _first_match(names, ["i_freeNext", "i_freeNext_n", "i_free"])

    extra_ports = [
        port["name"]
        for port in ports
        if port["direction"] == "output"
        and port["name"] not in {drive_next_port, data_port, free_port}
    ]

    handshake_style = "unknown"
    if any(name.endswith("_n") for name in names):
        handshake_style = "toggle_2phase"
    elif any(name.startswith("i_drive") for name in names) and "o_free" in names:
        handshake_style = "pulse_drive_free"

    return {
        "handshake_style": handshake_style,
        "inputs": inputs,
        "outputs": {
            "driveNext_port": drive_next_port,
            "data_port": data_port,
            "free_port": free_port,
            "freeNext_port": free_next_port,
            "extra_ports": extra_ports,
        },
        "arbitration_policy": "lowest-index-first"
        if component_type == "arb_merge"
        else None,
        "selection_encoding": "one-hot in high bits"
        if component_type == "sel_split"
        else None,
        "join_condition": "all-ports-ready"
        if component_type in {"wait_merge", "nat_split"}
        else None,
    }


def derive_gotchas(params, ports, component_type: str):
    gotchas = []
    if component_type == "sel_split":
        gotchas.append("Selection uses one-hot encoding in the high bits of i_data.")
    if component_type == "arb_merge":
        gotchas.append("Arbitration is lowest-index-first unless modified.")
    if any(param["name"].upper().startswith("DELAY") for param in params):
        gotchas.append("DELAY parameters affect handshake timing and throughput.")
    if any(port["name"].endswith("_n") for port in ports):
        gotchas.append("Signals with _n suffix may be active-low; confirm polarity.")
    return _unique(gotchas)


def _file_sha256(path: Path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(8192), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _relative_path(repo_root: Path, path: Path):
    try:
        return path.resolve().relative_to(repo_root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def _indexed_map(names, base: str):
    mapping = {}
    for name in names:
        match = re.match(rf"^{re.escape(base)}(\d+)$", name)
        if match:
            mapping[int(match.group(1))] = name
    if not mapping and base in names:
        mapping[0] = base
    return mapping


def _first_match(names, options):
    for option in options:
        if option in names:
            return option
    return None


def _unique(items):
    seen = set()
    result = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def _unique_aliases(aliases):
    seen = set()
    result = []
    for alias in aliases:
        key = (alias["from"], alias["to"])
        if key in seen:
            continue
        seen.add(key)
        result.append(alias)
    return result
