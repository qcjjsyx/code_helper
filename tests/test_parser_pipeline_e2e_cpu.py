import json
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


def test_cli_build_writes_expected_outputs_from_input_directory(tmp_path):
    output_dir = tmp_path / "artifacts" / "parser_pipeline_result"
    completed = subprocess.run(
        [
            sys.executable,
            "-m",
            "parser.pipeline",
            "build",
            "--inputs",
            "tests/fixtures/tcl_filelist",
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
    top = json.loads((output_dir / "modules" / "top.json").read_text(encoding="utf-8"))

    assert project_index["schema"] == "parser_pipeline_project_index"
    assert project_index["input_roots"] == ["tests/fixtures/tcl_filelist"]
    assert project_index["top_modules"] == [
        {
            "name": "top",
            "file": "tests/fixtures/tcl_filelist/top.v",
            "json_ref": "modules/top.json",
        }
    ]
    assert any(item["name"] == "child" for item in project_index["artifacts"]["modules"])
    assert top["direct_children"]["modules"] == ["child"]


def test_cli_build_requires_standard_tcl_files(tmp_path):
    input_dir = tmp_path / "rtl"
    input_dir.mkdir()
    (input_dir / "read_rtl_list.tcl").write_text("top.v\n", encoding="utf-8")
    completed = subprocess.run(
        [
            sys.executable,
            "-m",
            "parser.pipeline",
            "build",
            "--inputs",
            str(input_dir),
            "--output",
            str(tmp_path / "out"),
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )

    assert completed.returncode == 1
    assert "rtl_top_list.tcl" in completed.stderr
