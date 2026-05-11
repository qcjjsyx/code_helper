import json
from pathlib import Path

from knowledge.manual_ir.cli import main
from knowledge.manual_ir.context_pack import build_context_pack
from knowledge.manual_ir.split_store import resolve_manual_ir_object
from knowledge.manual_ir.validator import validate_manual_ir_split


def _write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def _write_minimal_artifacts(artifacts_root: Path) -> None:
    _write_json(
        artifacts_root / "project_index.json",
        {
            "top_modules": [{"name": "cpu_top"}],
            "stats": {"module_count": 1, "component_count": 1},
        },
    )
    _write_json(
        artifacts_root / "build_report.json",
        {
            "issues": [],
            "module_names": ["cpu_top"],
            "component_names": ["cFifo1_cpu"],
            "families_used": ["Fifo1"],
        },
    )
    _write_json(
        artifacts_root / "modules" / "cpu_top.json",
        {
            "name": "cpu_top",
            "artifact_kind": "module",
            "file": "test_data/cpu_top.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "i_drvFProducer", "direction": "input", "width_text": "1"},
                    {"name": "o_free2Producer", "direction": "output", "width_text": "1"},
                ]
            },
            "direct_children": {"modules": [], "components": ["cFifo1_cpu"]},
            "transitive_summary": {
                "reachable_modules": [],
                "reachable_components": ["cFifo1_cpu"],
                "families_used": ["Fifo1"],
            },
            "flow_graph": {"signals": [], "edges": []},
            "instances": [
                {"module_type": "cFifo1_cpu", "artifact_kind": "derived_component"},
            ],
            "warnings": [],
        },
    )
    _write_json(
        artifacts_root / "components" / "cFifo1_cpu.json",
        {
            "name": "cFifo1_cpu",
            "artifact_kind": "derived_component",
            "file": "test_data/cFifo1_cpu.v",
            "family": "Fifo1",
            "role_mapping": {
                "upstream": {"ports": ["i_drive", "o_free"]},
                "downstream": {"ports": ["o_driveNext", "i_freeNext"]},
                "payload": {"ports": []},
            },
            "flow_semantics": {
                "event_behavior": "fifo stage",
                "data_behavior": "event only",
                "completion_behavior": "wait downstream free",
            },
            "contract": {
                "invariants": ["no reentry"],
                "release_rule": {"policy": "selected_only", "details": "wait paired free"},
            },
            "implementation_summary": {},
            "warnings": [],
        },
    )


def _export_split_manual_ir(tmp_path: Path) -> Path:
    artifacts_root = tmp_path / "artifacts"
    manual_ir_dir = tmp_path / "manual_ir" / "cpu_top"
    _write_minimal_artifacts(artifacts_root)

    exit_code = main(
        [
            "export",
            "--artifacts-root",
            str(artifacts_root),
            "--top-module",
            "cpu_top",
            "--output-dir",
            str(manual_ir_dir),
        ]
    )

    assert exit_code == 0
    return manual_ir_dir


def test_resolve_manual_ir_object_loads_split_object_by_id(tmp_path):
    manual_ir_dir = _export_split_manual_ir(tmp_path)

    module_card = resolve_manual_ir_object(manual_ir_dir, "module:cpu_top")
    reading_path = resolve_manual_ir_object(manual_ir_dir, "reading:newcomer:cpu_top")

    assert module_card["module_name"] == "cpu_top"
    assert reading_path["audience"] == "newcomer"


def test_validate_manual_ir_split_reports_passed_and_warning_counts(tmp_path):
    manual_ir_dir = _export_split_manual_ir(tmp_path)

    report = validate_manual_ir_split(manual_ir_dir)

    assert report["status"] == "passed"
    assert report["summary"]["top_module"] == "cpu_top"
    assert report["summary"]["warnings"]["partial_or_low_confidence_flows"] == 1
    assert report["issues"] == []


def test_build_context_pack_uses_reading_section_covers(tmp_path):
    manual_ir_dir = _export_split_manual_ir(tmp_path)

    context_pack = build_context_pack(
        manual_ir_dir,
        audience="newcomer",
        section_id="read:newcomer:top-module",
    )

    assert context_pack["schema"] == "manual_ir_context_pack"
    assert context_pack["reading_path"]["audience"] == "newcomer"
    assert len(context_pack["sections"]) == 1
    section_pack = context_pack["sections"][0]
    assert section_pack["section"]["section_id"] == "read:newcomer:top-module"
    assert [item["id"] for item in section_pack["covered_objects"]] == ["module:cpu_top"]
    assert section_pack["unresolved_covers"] == []


def test_manual_ir_cli_validate_pack_and_resolve(tmp_path, capsys):
    manual_ir_dir = _export_split_manual_ir(tmp_path)
    validation_path = tmp_path / "validation.json"
    pack_path = tmp_path / "pack.json"

    assert main(["validate", "--manual-ir-dir", str(manual_ir_dir), "--output", str(validation_path)]) == 0
    assert json.loads(validation_path.read_text(encoding="utf-8"))["status"] == "passed"

    assert (
        main(
            [
                "pack",
                "--manual-ir-dir",
                str(manual_ir_dir),
                "--audience",
                "newcomer",
                "--section-id",
                "read:newcomer:top-module",
                "--output",
                str(pack_path),
            ]
        )
        == 0
    )
    assert json.loads(pack_path.read_text(encoding="utf-8"))["sections"][0]["section"]["section_id"] == "read:newcomer:top-module"

    assert main(["resolve", "--manual-ir-dir", str(manual_ir_dir), "--object-id", "module:cpu_top"]) == 0
    captured = capsys.readouterr()
    assert json.loads(captured.out)["module_name"] == "cpu_top"
