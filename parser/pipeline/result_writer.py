"""Write parser_pipeline outputs to disk."""

from __future__ import annotations

import json
import shutil
from pathlib import Path
from typing import Any, Dict


def write_results(output_dir: Path, project_result: Dict[str, Any]) -> None:
    if output_dir.exists():
        shutil.rmtree(output_dir)
    (output_dir / "modules").mkdir(parents=True, exist_ok=True)
    (output_dir / "components").mkdir(parents=True, exist_ok=True)

    for name, payload in project_result.get("modules", {}).items():
        _write_json(output_dir / "modules" / f"{name}.json", payload)

    for name, payload in project_result.get("components", {}).items():
        _write_json(output_dir / "components" / f"{name}.json", payload)

    _write_json(output_dir / "project_index.json", project_result["project_index"])
    _write_json(output_dir / "build_report.json", project_result["build_report"])


def _write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
