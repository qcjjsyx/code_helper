import json
from pathlib import Path

from knowledge.loaders.knowledge_base import load_knowledge_base
from knowledge.manual_ir import build_manual_ir


def _write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def test_build_manual_ir_builds_module_local_split_flow_path(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    _write_json(artifacts_root / "project_index.json", {"top_modules": [{"name": "top"}], "stats": {}})
    _write_json(
        artifacts_root / "modules" / "top.json",
        {
            "name": "top",
            "artifact_kind": "module",
            "file": "test_data/top.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "i_driveIn", "direction": "input", "width_text": "1"},
                    {"name": "o_driveA", "direction": "output", "width_text": "1"},
                    {"name": "o_driveB", "direction": "output", "width_text": "1"},
                ]
            },
            "direct_children": {"modules": [], "components": ["cSplit"]},
            "transitive_summary": {"reachable_modules": [], "reachable_components": ["cSplit"], "families_used": ["SelSplit"]},
            "instances": [
                {
                    "instance_name": "u_split",
                    "module_type": "cSplit",
                    "artifact_kind": "derived_component",
                    "family": "SelSplit",
                    "connections": [
                        {"port": "i_drive", "signal": "i_driveIn", "port_direction": "input", "signal_role": "event_drive"},
                        {"port": "o_driveNext0", "signal": "o_driveA", "port_direction": "output", "signal_role": "event_drive"},
                        {"port": "o_driveNext1", "signal": "o_driveB", "port_direction": "output", "signal_role": "event_drive"},
                    ],
                }
            ],
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "top")

    assert len(manual_ir.objects.flow_paths) == 1
    path = manual_ir.objects.flow_paths[0]
    assert path.id == "flow:top:i_driveIn"
    assert path.path_type == "event_path"
    assert path.startpoints[0].signal == "i_driveIn"
    assert [endpoint.signal for endpoint in path.endpoints] == ["o_driveA", "o_driveB"]
    assert [(step.node_kind, step.node_name, step.role) for step in path.steps] == [
        ("component", "u_split", "splitter")
    ]
    assert path.branch_points[0].node == "u_split"
    assert path.covered_channels == [
        "channel:top:i_driveIn",
        "channel:top:o_driveA",
        "channel:top:o_driveB",
    ]
    assert path.warnings == []


def test_build_manual_ir_uses_parser_signal_terms_for_concat_event_input(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    _write_json(artifacts_root / "project_index.json", {"top_modules": [{"name": "arbMsg"}], "stats": {}})
    _write_json(
        artifacts_root / "modules" / "arbMsg.json",
        {
            "name": "arbMsg",
            "artifact_kind": "module",
            "file": "test_data/arbMsg.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "i_driveWest", "direction": "input", "width_text": "1"},
                    {"name": "i_driveEast", "direction": "input", "width_text": "1"},
                    {"name": "i_driveNorth", "direction": "input", "width_text": "1"},
                    {"name": "i_driveSouth", "direction": "input", "width_text": "1"},
                    {"name": "i_driveLocal", "direction": "input", "width_text": "1"},
                    {"name": "o_driveNext", "direction": "output", "width_text": "1"},
                ]
            },
            "direct_children": {"modules": [], "components": ["cArbMerge5_51b"]},
            "transitive_summary": {
                "reachable_modules": [],
                "reachable_components": ["cArbMerge5_51b"],
                "families_used": ["ArbMerge"],
            },
            "instances": [
                {
                    "instance_name": "arbMerge",
                    "module_type": "cArbMerge5_51b",
                    "artifact_kind": "derived_component",
                    "family": "ArbMerge",
                    "connections": [
                        {
                            "port": "i_drive_5",
                            "signal": "{i_driveLocal,i_driveSouth,i_driveNorth,i_driveEast,i_driveWest}",
                            "signal_terms": [
                                "i_driveLocal",
                                "i_driveSouth",
                                "i_driveNorth",
                                "i_driveEast",
                                "i_driveWest",
                            ],
                            "port_direction": "input",
                            "signal_role": "event_drive",
                        },
                        {
                            "port": "o_driveNext",
                            "signal": "o_driveNext",
                            "port_direction": "output",
                            "signal_role": "event_drive",
                        },
                    ],
                }
            ],
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "arbMsg")
    paths_by_start = {
        path.startpoints[0].signal: path
        for path in manual_ir.objects.flow_paths
    }

    path = paths_by_start["i_driveEast"]
    assert [endpoint.signal for endpoint in path.endpoints] == ["o_driveNext"]
    assert [(step.node_kind, step.node_name, step.role) for step in path.steps] == [
        ("component", "arbMerge", "arbiter")
    ]
    assert {point.node for point in path.join_points} == {"arbMerge"}
    assert {point.node for point in path.blocking_points} == {"arbMerge"}
    assert path.warnings == []


def test_build_manual_ir_uses_parser_transparent_delay_flow(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    _write_json(artifacts_root / "project_index.json", {"top_modules": [{"name": "top"}], "stats": {}})
    _write_json(
        artifacts_root / "modules" / "top.json",
        {
            "name": "top",
            "artifact_kind": "module",
            "file": "test_data/top.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "i_driveIn", "direction": "input", "width_text": "1"},
                    {"name": "o_driveOut", "direction": "output", "width_text": "1"},
                ]
            },
            "direct_children": {"modules": [], "components": []},
            "transitive_summary": {"reachable_modules": [], "reachable_components": [], "families_used": []},
            "instances": [],
            "transparent_flows": [
                {
                    "instance_name": "u_delay",
                    "module_type": "delay8U",
                    "artifact_kind": "transparent_helper",
                    "source": "skip_helper_rule",
                    "input_port": "inR",
                    "input_signal": "i_driveIn",
                    "output_port": "outR",
                    "output_signal": "o_driveOut",
                    "signal_role": "event_drive",
                }
            ],
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "top")

    path = manual_ir.objects.flow_paths[0]
    assert [endpoint.signal for endpoint in path.endpoints] == ["o_driveOut"]
    assert [(step.node_kind, step.node_name, step.role) for step in path.steps] == [
        ("signal_group", "u_delay", "transparent_delay")
    ]
    assert path.warnings == []


def test_build_manual_ir_marks_join_blocking_and_partial_flows(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    _write_json(artifacts_root / "project_index.json", {"top_modules": [{"name": "top"}], "stats": {}})
    _write_json(
        artifacts_root / "modules" / "top.json",
        {
            "name": "top",
            "artifact_kind": "module",
            "file": "test_data/top.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "i_drive0", "direction": "input", "width_text": "1"},
                    {"name": "i_drive1", "direction": "input", "width_text": "1"},
                    {"name": "i_drivePartial", "direction": "input", "width_text": "1"},
                    {"name": "o_driveOut", "direction": "output", "width_text": "1"},
                ]
            },
            "direct_children": {"modules": [], "components": ["cMerge", "cFifo"]},
            "transitive_summary": {
                "reachable_modules": [],
                "reachable_components": ["cMerge", "cFifo"],
                "families_used": ["MutexMerge", "Fifo1"],
            },
            "instances": [
                {
                    "instance_name": "u_merge",
                    "module_type": "cMerge",
                    "artifact_kind": "derived_component",
                    "family": "MutexMerge",
                    "connections": [
                        {"port": "i_drive0", "signal": "i_drive0", "port_direction": "input", "signal_role": "event_drive"},
                        {"port": "i_drive1", "signal": "i_drive1", "port_direction": "input", "signal_role": "event_drive"},
                        {"port": "o_driveNext", "signal": "w_drive", "port_direction": "output", "signal_role": "event_drive"},
                    ],
                },
                {
                    "instance_name": "u_fifo",
                    "module_type": "cFifo",
                    "artifact_kind": "derived_component",
                    "family": "Fifo1",
                    "connections": [
                        {"port": "i_drive", "signal": "w_drive", "port_direction": "input", "signal_role": "event_drive"},
                        {"port": "o_driveNext", "signal": "o_driveOut", "port_direction": "output", "signal_role": "event_drive"},
                    ],
                },
            ],
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "top")
    paths_by_start = {
        path.startpoints[0].signal: path
        for path in manual_ir.objects.flow_paths
    }

    merged_path = paths_by_start["i_drive0"]
    assert [endpoint.signal for endpoint in merged_path.endpoints] == ["o_driveOut"]
    assert {point.node for point in merged_path.join_points} == {"u_merge"}
    assert {point.node for point in merged_path.blocking_points} == {"u_merge", "u_fifo"}
    assert merged_path.confidence == "medium"

    partial_path = paths_by_start["i_drivePartial"]
    assert partial_path.endpoints == []
    assert partial_path.confidence == "low"
    assert partial_path.warnings == [
        "no module output event drive reached from start signal i_drivePartial."
    ]


def test_maintainer_complex_flows_are_complete_and_not_truncated(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    _write_json(artifacts_root / "project_index.json", {"top_modules": [{"name": "top"}], "stats": {}})

    complex_count = 22
    ports = []
    instances = []
    for index in range(complex_count):
        ports.append({"name": f"i_drive{index}", "direction": "input", "width_text": "1"})
        ports.append({"name": f"o_drive{index}", "direction": "output", "width_text": "1"})
        instances.append(
            {
                "instance_name": f"u_fifo_{index}",
                "module_type": "cFifo",
                "artifact_kind": "derived_component",
                "family": "Fifo1",
                "connections": [
                    {
                        "port": "i_drive",
                        "signal": f"i_drive{index}",
                        "port_direction": "input",
                        "signal_role": "event_drive",
                    },
                    {
                        "port": "o_driveNext",
                        "signal": f"o_drive{index}",
                        "port_direction": "output",
                        "signal_role": "event_drive",
                    },
                ],
            }
        )
    ports.append({"name": "i_drivePartial", "direction": "input", "width_text": "1"})

    _write_json(
        artifacts_root / "modules" / "top.json",
        {
            "name": "top",
            "artifact_kind": "module",
            "file": "test_data/top.v",
            "module_role": "top",
            "interface": {"ports": ports},
            "direct_children": {"modules": [], "components": []},
            "transitive_summary": {"reachable_modules": [], "reachable_components": [], "families_used": ["Fifo1"]},
            "instances": instances,
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "top")
    maintainer = manual_ir.objects.reading_paths[1]
    sections_by_id = {
        section.section_id: section
        for section in maintainer.ordered_sections
    }

    assert len(sections_by_id["read:maintainer:complex-flows"].covers) == complex_count
    assert "flow:top:i_drive21" in sections_by_id["read:maintainer:complex-flows"].covers
    assert "flow:top:i_drivePartial" not in sections_by_id["read:maintainer:complex-flows"].covers
    assert sections_by_id["read:maintainer:partial-flows"].covers == ["flow:top:i_drivePartial"]
