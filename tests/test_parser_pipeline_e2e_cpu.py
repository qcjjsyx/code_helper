import json
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


def test_cli_build_writes_expected_cpu_outputs(tmp_path):
    output_dir = tmp_path / "artifacts" / "parser_pipeline_result"
    completed = subprocess.run(
        [
            sys.executable,
            "-m",
            "parser_pipeline",
            "build",
            "--repo",
            str(REPO_ROOT),
            "--inputs",
            "test_data/cpu",
            "--tops",
            "test_data/cpu/CPU/cpu_top.v",
            "test_data/cpu/CPUwithCache.v",
            "--output",
            str(output_dir),
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr

    project_index = json.loads((output_dir / "project_index.json").read_text(encoding="utf-8"))
    cpu_top = json.loads((output_dir / "modules" / "cpu_top.json").read_text(encoding="utf-8"))
    component = json.loads((output_dir / "components" / "cNatSplit2_lsu.json").read_text(encoding="utf-8"))

    assert project_index["schema"] == "parser_pipeline_project_index"
    assert any(item["name"] == "cpu_top" for item in project_index["top_modules"])
    assert any(item["name"] == "cSelSplit_2_fetch" for item in project_index["artifacts"]["components"])
    assert cpu_top["flow_graph"]["edges"], "expected flow graph edges in cpu_top output"
    assert component["contract"]["invariants"], "expected family template contract in component output"
