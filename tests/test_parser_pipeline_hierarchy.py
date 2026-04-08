from pathlib import Path

from parser.pipeline.hierarchy_builder import build_project


REPO_ROOT = Path(__file__).resolve().parents[1]


def test_cpu_top_hierarchy_reaches_modules_and_components(tmp_path):
    result = build_project(
        repo_root=REPO_ROOT,
        inputs=["test_data/cpu"],
        tops=["test_data/cpu/CPU/cpu_top.v"],
        output_dir=tmp_path / "artifacts" / "parser_pipeline_result",
    )

    cpu_top = result["modules"]["cpu_top"]
    assert cpu_top["module_role"] == "top"
    assert cpu_top["direct_children"]["modules"] == [
        "Fetch_top",
        "exe_top",
        "idu_top",
        "lsu_top",
        "mem_slot",
        "writeBack",
    ]

    fetch_top = result["modules"]["Fetch_top"]
    direct_targets = {instance["module_type"] for instance in fetch_top["instances"]}
    assert {"Fetch_Logic", "cFifo1_cpu", "cMutexMerge_4_d_fetch", "cSelSplit_2_fetch"}.issubset(direct_targets)

    fetch_logic = result["modules"]["Fetch_Logic"]
    transitive_components = set(fetch_logic["transitive_summary"]["reachable_components"])
    assert {
        "cSelSplit_2_fetch",
        "cNatSplit_2_fetch",
        "cWaitMerge_2_d_fetch",
        "cSelSplit_3_fetch",
        "cMutexMerge_3_df_fetch",
    }.issubset(transitive_components)
