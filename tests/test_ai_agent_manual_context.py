import json
from pathlib import Path

from knowledge.loaders.knowledge_base import load_knowledge_base
from knowledge.manual_ir.manual_context import build_manual_context


def _write_json(path: Path, payload: dict) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def test_build_manual_context_collects_reachable_modules_and_components(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    modules_dir = artifacts_root / "modules"
    components_dir = artifacts_root / "components"
    modules_dir.mkdir(parents=True)
    components_dir.mkdir(parents=True)

    _write_json(artifacts_root / "project_index.json", {"top_modules": [{"name": "cpu_top"}], "stats": {}})
    _write_json(
        modules_dir / "cpu_top.json",
        {
            "name": "cpu_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/CPU/cpu_top.v",
            "module_role": "top",
            "interface": {"ports": [{"name": "rst"}]},
            "direct_children": {"modules": ["Fetch_top"], "components": ["cFifo1_cpu"]},
            "transitive_summary": {"reachable_modules": ["Fetch_top"], "reachable_components": ["cFifo1_cpu"]},
            "flow_graph": {"signals": [], "edges": []},
        },
    )
    _write_json(
        modules_dir / "Fetch_top.json",
        {
            "name": "Fetch_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/Fetch/Fetch_top.v",
            "module_role": "submodule",
            "interface": {"ports": [{"name": "i_drive"}]},
            "direct_children": {"modules": [], "components": ["cSelSplit_2_fetch"]},
            "transitive_summary": {"reachable_modules": [], "reachable_components": ["cSelSplit_2_fetch"]},
            "flow_graph": {"signals": [], "edges": [{"signal": "w_drive"}]},
        },
    )
    _write_json(
        components_dir / "cFifo1_cpu.json",
        {
            "name": "cFifo1_cpu",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/cFifo1_cpu.v",
            "family": "Fifo1",
            "role_mapping": {"upstream": {"ports": ["i_drive"]}},
            "flow_semantics": {"event_behavior": "fifo stage"},
            "contract": {"invariants": ["no reentry"], "release_rule": {"policy": "paired"}},
            "implementation_summary": {"internal_dependencies": ["sender"]},
        },
    )
    _write_json(
        components_dir / "cSelSplit_2_fetch.json",
        {
            "name": "cSelSplit_2_fetch",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/Fetch/cSelSplit_2_fetch.v",
            "family": "SelSplit",
            "role_mapping": {"condition": {"ports": ["valid0"]}},
            "flow_semantics": {"event_behavior": "selected routing"},
            "contract": {"invariants": ["selected only"], "release_rule": {"policy": "selected_only"}},
            "implementation_summary": {"internal_dependencies": ["contTap"]},
        },
    )

    kb = load_knowledge_base(artifacts_root)
    context = build_manual_context(kb, "cpu_top")

    assert context.top_module == "cpu_top"
    assert [item["name"] for item in context.module_summaries] == ["cpu_top", "Fetch_top"]
    assert {item["name"] for item in context.component_summaries} == {"cFifo1_cpu", "cSelSplit_2_fetch"}
