from pathlib import Path

from parser.pipeline.hierarchy_builder import build_project
from parser.pipeline.module_index import discover_verilog_files, resolve_explicit_verilog_files


REPO_ROOT = Path(__file__).resolve().parents[1]
FIXTURE_DIR = REPO_ROOT / "tests" / "fixtures" / "tcl_filelist"


def test_module_index_expands_tcl_file_lists():
    top_paths = resolve_explicit_verilog_files(REPO_ROOT, [str(FIXTURE_DIR / "rtl_top_list.tcl")])
    files = discover_verilog_files(REPO_ROOT, [str(FIXTURE_DIR / "read_rtl_list.tcl")], top_paths)

    assert top_paths == {(FIXTURE_DIR / "top.v").resolve()}
    assert files == sorted(
        {
            (FIXTURE_DIR / "top.v").resolve(),
            (FIXTURE_DIR / "nested" / "child.v").resolve(),
        }
    )


def test_build_project_accepts_tcl_inputs_and_tops(tmp_path):
    result = build_project(
        repo_root=REPO_ROOT,
        input_root=FIXTURE_DIR,
        output_dir=tmp_path / "artifacts" / "parser_pipeline_result",
    )

    assert set(result["modules"]) == {"top", "child"}
    assert result["project_index"]["top_modules"] == [
        {
            "name": "top",
            "file": "tests/fixtures/tcl_filelist/top.v",
            "json_ref": "modules/top.json",
        }
    ]
    assert result["project_index"]["input_roots"] == ["tests/fixtures/tcl_filelist"]
