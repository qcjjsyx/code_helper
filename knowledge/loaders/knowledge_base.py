"""Load parser artifacts into a searchable knowledge base."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List


@dataclass(frozen=True)
class ArtifactRecord:
    name: str
    artifact_kind: str
    file: str
    json_path: Path
    payload: Dict[str, Any]

    def searchable_text(self) -> str:
        fields = [self.name, self.artifact_kind, self.file]
        if self.artifact_kind == "module":
            fields.extend(self.payload.get("direct_children", {}).get("modules", []))
            fields.extend(self.payload.get("direct_children", {}).get("components", []))
            fields.extend(self.payload.get("transitive_summary", {}).get("families_used", []))
        if self.artifact_kind == "derived_component":
            fields.append(self.payload.get("family", ""))
            fields.extend(self.payload.get("contract", {}).get("invariants", []))
        return " ".join(item for item in fields if item)


@dataclass(frozen=True)
class ProjectKnowledgeBase:
    project_index: Dict[str, Any]
    modules: Dict[str, ArtifactRecord]
    components: Dict[str, ArtifactRecord]

    def all_records(self) -> List[ArtifactRecord]:
        return list(self.modules.values()) + list(self.components.values())

    def get(self, name: str) -> ArtifactRecord | None:
        return self.modules.get(name) or self.components.get(name)


def load_knowledge_base(artifacts_root: Path) -> ProjectKnowledgeBase:
    project_index = _load_json(artifacts_root / "project_index.json")
    modules = _load_records(artifacts_root / "modules", "module")
    components = _load_records(artifacts_root / "components", "derived_component")
    return ProjectKnowledgeBase(
        project_index=project_index,
        modules=modules,
        components=components,
    )


def _load_records(directory: Path, default_kind: str) -> Dict[str, ArtifactRecord]:
    records: Dict[str, ArtifactRecord] = {}
    if not directory.exists():
        return records
    for json_path in sorted(directory.glob("*.json")):
        payload = _load_json(json_path)
        name = payload.get("name", json_path.stem)
        records[name] = ArtifactRecord(
            name=name,
            artifact_kind=payload.get("artifact_kind", default_kind),
            file=payload.get("file", ""),
            json_path=json_path,
            payload=payload,
        )
    return records


def _load_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))
