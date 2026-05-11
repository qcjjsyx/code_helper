"""Helpers for reading split Manual IR exports."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, Iterable, List


class ManualIRSplitError(ValueError):
    """Raised when a split Manual IR directory is incomplete or inconsistent."""


OBJECT_GROUPS = (
    "module_cards",
    "channel_cards",
    "component_contracts",
    "flow_paths",
    "reading_paths",
)


def load_manifest(manual_ir_dir: str | Path) -> Dict[str, Any]:
    root = Path(manual_ir_dir)
    manifest_path = root / "manifest.json"
    if not manifest_path.is_file():
        raise FileNotFoundError(f"Manual IR manifest not found: {manifest_path}")
    return _load_json(manifest_path)


def resolve_manual_ir_object(manual_ir_dir: str | Path, object_id: str) -> Dict[str, Any]:
    """Load one Manual IR object by its stable id from a split export."""

    root = Path(manual_ir_dir)
    catalog = build_object_catalog(root)
    ref = catalog.get(object_id)
    if ref is None:
        raise ManualIRSplitError(f"Manual IR object id not found: {object_id}")
    return _load_object_ref(root, ref)


def resolve_manual_ir_objects(manual_ir_dir: str | Path, object_ids: Iterable[str]) -> List[Dict[str, Any]]:
    return [resolve_manual_ir_object(manual_ir_dir, object_id) for object_id in object_ids]


def list_reading_paths(manual_ir_dir: str | Path) -> List[Dict[str, Any]]:
    root = Path(manual_ir_dir)
    manifest = load_manifest(root)
    files = manifest.get("files", {}).get("reading_paths", {})
    if not isinstance(files, dict):
        return []
    paths = [_load_json(root / rel_path) for rel_path in files.values()]
    return sorted(paths, key=lambda item: item.get("id", ""))


def select_reading_path(
    manual_ir_dir: str | Path,
    *,
    reading_path_id: str | None = None,
    audience: str | None = None,
) -> Dict[str, Any]:
    if reading_path_id:
        return resolve_manual_ir_object(manual_ir_dir, reading_path_id)
    if audience:
        matches = [
            path
            for path in list_reading_paths(manual_ir_dir)
            if path.get("audience") == audience
        ]
        if not matches:
            raise ManualIRSplitError(f"ReadingPath audience not found: {audience}")
        if len(matches) > 1:
            raise ManualIRSplitError(f"ReadingPath audience is ambiguous: {audience}")
        return matches[0]
    raise ManualIRSplitError("reading_path_id or audience is required")


def build_object_catalog(manual_ir_dir: str | Path) -> Dict[str, Dict[str, str]]:
    """Return object id -> file reference for all split Manual IR objects."""

    root = Path(manual_ir_dir)
    manifest = load_manifest(root)
    files = manifest.get("files", {})
    if not isinstance(files, dict):
        raise ManualIRSplitError("manifest.files must be an object")

    catalog: Dict[str, Dict[str, str]] = {}

    system_views_ref = files.get("system_views")
    if isinstance(system_views_ref, str):
        for index, item in enumerate(_load_json(root / system_views_ref)):
            object_id = item.get("id")
            if object_id:
                catalog[object_id] = {
                    "kind": "system_views",
                    "file": system_views_ref,
                    "list_index": str(index),
                }

    for group in OBJECT_GROUPS:
        group_files = files.get(group, {})
        if not isinstance(group_files, dict):
            continue
        for _, rel_path in sorted(group_files.items()):
            if not isinstance(rel_path, str):
                continue
            item = _load_json(root / rel_path)
            object_id = item.get("id")
            if object_id:
                catalog[object_id] = {
                    "kind": group,
                    "file": rel_path,
                }

    return catalog


def _load_object_ref(root: Path, ref: Dict[str, str]) -> Dict[str, Any]:
    payload = _load_json(root / ref["file"])
    list_index = ref.get("list_index")
    if list_index is None:
        return payload
    if not isinstance(payload, list):
        raise ManualIRSplitError(f"expected list payload in {ref['file']}")
    index = int(list_index)
    return payload[index]


def _load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))
