import json
from pathlib import Path

from knowledge.manual_ir.cli import main


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


def test_manual_ir_cli_export_writes_output_file(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    output_path = tmp_path / "manual_ir" / "cpu_top.json"
    _write_minimal_artifacts(artifacts_root)

    exit_code = main(
        [
            "export",
            "--artifacts-root",
            str(artifacts_root),
            "--top-module",
            "cpu_top",
            "--output",
            str(output_path),
        ]
    )

    assert exit_code == 0
    payload = json.loads(output_path.read_text(encoding="utf-8"))
    assert payload["schema"] == "manual_ir"
    assert payload["top_module"] == "cpu_top"
    assert [item["module_name"] for item in payload["objects"]["module_cards"]] == ["cpu_top"]
    assert [item["handshake"]["drive"] for item in payload["objects"]["channel_cards"]] == ["i_drvFProducer"]
    assert [item["component_name"] for item in payload["objects"]["component_contracts"]] == ["cFifo1_cpu"]


def test_manual_ir_cli_export_writes_split_output_dir(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    output_dir = tmp_path / "manual_ir" / "cpu_top"
    _write_minimal_artifacts(artifacts_root)

    exit_code = main(
        [
            "export",
            "--artifacts-root",
            str(artifacts_root),
            "--top-module",
            "cpu_top",
            "--output-dir",
            str(output_dir),
        ]
    )

    assert exit_code == 0

    manifest = json.loads((output_dir / "manifest.json").read_text(encoding="utf-8"))
    assert manifest["schema"] == "manual_ir"
    assert manifest["top_module"] == "cpu_top"
    assert manifest["counts"]["system_views"] == 1
    assert manifest["counts"]["module_cards"] == 1
    assert manifest["counts"]["channel_cards"] == 1
    assert manifest["counts"]["component_contracts"] == 1
    assert manifest["files"]["system_views"] == "system_views.json"
    assert manifest["files"]["module_cards"] == {"cpu_top": "module_cards/cpu_top.json"}
    assert manifest["files"]["channel_cards"] == {
        "channel:cpu_top:i_drvFProducer": "channel_cards/channel_cpu_top_i_drvFProducer.json",
    }
    assert manifest["files"]["component_contracts"] == {
        "cFifo1_cpu": "component_contracts/cFifo1_cpu.json",
    }

    system_views = json.loads((output_dir / "system_views.json").read_text(encoding="utf-8"))
    module_card = json.loads((output_dir / "module_cards" / "cpu_top.json").read_text(encoding="utf-8"))
    channel_card = json.loads(
        (output_dir / "channel_cards" / "channel_cpu_top_i_drvFProducer.json").read_text(encoding="utf-8")
    )
    component_contract = json.loads(
        (output_dir / "component_contracts" / "cFifo1_cpu.json").read_text(encoding="utf-8")
    )
    assert system_views[0]["id"] == "system:cpu_top"
    assert module_card["module_name"] == "cpu_top"
    assert channel_card["handshake"]["drive"] == "i_drvFProducer"
    assert component_contract["component_name"] == "cFifo1_cpu"


def test_manual_ir_cli_export_prints_to_stdout(tmp_path, capsys):
    artifacts_root = tmp_path / "artifacts"
    _write_minimal_artifacts(artifacts_root)

    exit_code = main(
        [
            "export",
            "--artifacts-root",
            str(artifacts_root),
            "--top-module",
            "cpu_top",
        ]
    )

    captured = capsys.readouterr()
    assert exit_code == 0
    payload = json.loads(captured.out)
    assert payload["top_module"] == "cpu_top"
    assert captured.err == ""


def test_manual_ir_cli_export_rejects_output_file_and_output_dir_together(tmp_path, capsys):
    artifacts_root = tmp_path / "artifacts"
    _write_minimal_artifacts(artifacts_root)

    exit_code = main(
        [
            "export",
            "--artifacts-root",
            str(artifacts_root),
            "--top-module",
            "cpu_top",
            "--output",
            str(tmp_path / "manual_ir.json"),
            "--output-dir",
            str(tmp_path / "manual_ir"),
        ]
    )

    captured = capsys.readouterr()
    assert exit_code == 1
    assert "--output and --output-dir cannot be used together" in captured.err


def test_manual_ir_cli_export_returns_error_for_missing_top_module(tmp_path, capsys):
    artifacts_root = tmp_path / "artifacts"
    _write_minimal_artifacts(artifacts_root)

    exit_code = main(
        [
            "export",
            "--artifacts-root",
            str(artifacts_root),
            "--top-module",
            "missing_top",
        ]
    )

    captured = capsys.readouterr()
    assert exit_code == 1
    assert "top module not found: missing_top" in captured.err
