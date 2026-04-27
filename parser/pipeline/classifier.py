"""Artifact classification helpers."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, Optional

from .boundary_policy import decide_boundary


def classify_artifact(
    module_name: str,
    file_path: str,
    module_index: Dict[str, Path],
    top_module_names: set[str],
    cc_header: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    resolved_path = module_index.get(module_name)
    if resolved_path is None:
        candidate_path = Path(file_path)
        if candidate_path.is_file():
            resolved_path = candidate_path
    decision = decide_boundary(
        module_name,
        module_index=module_index,
        top_module_names=top_module_names,
        file_path=resolved_path,
        cc_header=cc_header,
    )
    artifact_kind = decision.artifact_kind
    if decision.kind == "component_leaf":
        artifact_kind = "derived_component"
    if decision.kind == "module" and module_name in top_module_names:
        artifact_kind = "top_module"
    return {
        "artifact_kind": artifact_kind,
        "family": decision.family,
        "num_ports": decision.num_ports,
    }
