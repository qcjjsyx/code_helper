"""Artifact classification helpers."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, Optional

from .family_inference import infer_family, is_known_family


def classify_artifact(
    module_name: str,
    file_path: str,
    module_index: Dict[str, Path],
    top_module_names: set[str],
    cc_header: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    family_info = infer_family(module_name=module_name, file_path=file_path, cc_header=cc_header)
    family = family_info.get("family")
    if is_known_family(family):
        return {
            "artifact_kind": "derived_component",
            "family": family,
            "num_ports": family_info.get("num_ports"),
        }
    if module_name in top_module_names:
        return {"artifact_kind": "top_module", "family": None, "num_ports": None}
    if module_name in module_index:
        return {"artifact_kind": "module", "family": None, "num_ports": None}
    return {"artifact_kind": "external_dependency", "family": None, "num_ports": None}
