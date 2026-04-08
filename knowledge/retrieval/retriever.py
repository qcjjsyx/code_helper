"""Retrieve the most relevant parser artifacts for a user question."""

from __future__ import annotations

import re
from typing import List, Sequence

from knowledge.loaders.knowledge_base import ArtifactRecord, ProjectKnowledgeBase


def retrieve_relevant_artifacts(
    question: str,
    kb: ProjectKnowledgeBase,
    *,
    top_k: int = 6,
) -> List[ArtifactRecord]:
    scored = []
    tokens = _tokenize(question)
    lowered_question = question.lower()

    for record in kb.all_records():
        score = 0
        searchable = record.searchable_text().lower()
        if record.name.lower() in lowered_question:
            score += 12
        if record.file.lower() in lowered_question:
            score += 10
        score += sum(2 for token in tokens if token in searchable)
        if record.artifact_kind == "module" and "模块" in question:
            score += 1
        if record.artifact_kind == "derived_component" and ("结构子" in question or "family" in lowered_question):
            score += 1
        if score > 0:
            scored.append((score, record))

    scored.sort(key=lambda item: (-item[0], item[1].name))
    selected = [record for _, record in scored[:top_k]]

    # If a top-level module is selected, pull in a few direct children to help the model answer architectural questions.
    expanded = list(selected)
    seen = {record.name for record in expanded}
    for record in list(selected):
        if record.artifact_kind != "module":
            continue
        children = record.payload.get("direct_children", {})
        for child_name in children.get("modules", []) + children.get("components", []):
            child = kb.get(child_name)
            if child and child.name not in seen and len(expanded) < top_k + 3:
                expanded.append(child)
                seen.add(child.name)

    return expanded


def _tokenize(text: str) -> Sequence[str]:
    parts = re.split(r"[^A-Za-z0-9_\u4e00-\u9fff]+", text.lower())
    return [part for part in parts if part]
