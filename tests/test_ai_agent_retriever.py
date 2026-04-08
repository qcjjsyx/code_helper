import json
from pathlib import Path

from agent.prompts.prompt_builder import build_user_prompt
from knowledge.loaders.knowledge_base import load_knowledge_base
from knowledge.retrieval.retriever import retrieve_relevant_artifacts


def _write_json(path: Path, payload: dict) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def test_retriever_prefers_named_module_and_related_children(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    modules_dir = artifacts_root / "modules"
    components_dir = artifacts_root / "components"
    modules_dir.mkdir(parents=True)
    components_dir.mkdir(parents=True)

    _write_json(
        artifacts_root / "project_index.json",
        {
            "top_modules": [{"name": "cpu_top"}],
            "stats": {"module_count": 2, "component_count": 1},
        },
    )
    _write_json(
        modules_dir / "cpu_top.json",
        {
            "name": "cpu_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/CPU/cpu_top.v",
            "direct_children": {"modules": ["Fetch_top"], "components": []},
            "transitive_summary": {"families_used": ["SelSplit"]},
        },
    )
    _write_json(
        modules_dir / "Fetch_top.json",
        {
            "name": "Fetch_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/Fetch/Fetch_top.v",
            "direct_children": {"modules": [], "components": ["cSelSplit_2_fetch"]},
            "transitive_summary": {"families_used": ["SelSplit"]},
        },
    )
    _write_json(
        components_dir / "cSelSplit_2_fetch.json",
        {
            "name": "cSelSplit_2_fetch",
            "artifact_kind": "derived_component",
            "family": "SelSplit",
            "file": "test_data/cpu/Fetch/cSelSplit_2_fetch.v",
            "contract": {"invariants": ["Selection condition determines routing."]},
        },
    )

    kb = load_knowledge_base(artifacts_root)
    records = retrieve_relevant_artifacts("解释 cpu_top 的取指路径和 cSelSplit_2_fetch", kb, top_k=2)

    names = [record.name for record in records]
    assert "cpu_top" in names
    assert "cSelSplit_2_fetch" in names


def test_prompt_contains_question_and_selected_artifacts(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    modules_dir = artifacts_root / "modules"
    components_dir = artifacts_root / "components"
    modules_dir.mkdir(parents=True)
    components_dir.mkdir(parents=True)

    _write_json(artifacts_root / "project_index.json", {"top_modules": [], "stats": {}})
    _write_json(
        modules_dir / "Fetch_top.json",
        {
            "name": "Fetch_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/Fetch/Fetch_top.v",
            "direct_children": {"modules": [], "components": []},
            "transitive_summary": {},
        },
    )

    kb = load_knowledge_base(artifacts_root)
    records = retrieve_relevant_artifacts("Fetch_top 做什么", kb, top_k=1)
    prompt = build_user_prompt("Fetch_top 做什么", kb, records)

    assert "Fetch_top" in prompt
    assert "question" in prompt
