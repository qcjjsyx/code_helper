import json
from pathlib import Path

from knowledge.loaders.knowledge_base import load_knowledge_base
from knowledge.manual_ir import build_manual_ir


def _write_json(path: Path, payload: dict) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def test_build_manual_ir_maps_core_objects_and_indexes(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    modules_dir = artifacts_root / "modules"
    components_dir = artifacts_root / "components"
    modules_dir.mkdir(parents=True)
    components_dir.mkdir(parents=True)

    _write_json(
        artifacts_root / "project_index.json",
        {
            "top_modules": [{"name": "cpu_top"}],
            "stats": {"module_count": 3, "component_count": 2},
        },
    )
    _write_json(
        modules_dir / "cpu_top.json",
        {
            "name": "cpu_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/CPU/cpu_top.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "rst", "direction": "input"},
                    {"name": "i_driveFromTPUtoCPU", "direction": "input"},
                    {"name": "o_driveFromCPUtoTPU", "direction": "output"},
                    {"name": "switch", "direction": "input"},
                ]
            },
            "direct_children": {"modules": ["Fetch_top", "Leaf_mod"], "components": ["cFifo1_cpu"]},
            "transitive_summary": {
                "reachable_modules": ["Fetch_top", "Leaf_mod"],
                "reachable_components": ["cFifo1_cpu", "cSelSplit_2_fetch"],
                "families_used": ["Fifo1", "SelSplit"],
            },
            "flow_graph": {"signals": [], "edges": []},
            "instances": [
                {"module_type": "Fetch_top", "artifact_kind": "module"},
                {"module_type": "Leaf_mod", "artifact_kind": "module"},
                {"module_type": "cFifo1_cpu", "artifact_kind": "derived_component"},
                {"module_type": "Icache", "artifact_kind": "external_dependency", "instance_name": "u_icache"},
            ],
            "warnings": [],
        },
    )
    _write_json(
        modules_dir / "Fetch_top.json",
        {
            "name": "Fetch_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/Fetch/Fetch_top.v",
            "module_role": "submodule",
            "interface": {"ports": [{"name": "selFetch", "direction": "input"}]},
            "direct_children": {"modules": [], "components": ["cSelSplit_2_fetch", "cFifo1_cpu"]},
            "transitive_summary": {
                "reachable_modules": [],
                "reachable_components": ["cSelSplit_2_fetch", "cFifo1_cpu"],
                "families_used": ["Fifo1", "SelSplit"],
            },
            "flow_graph": {"signals": [], "edges": []},
            "instances": [
                {"module_type": "cSelSplit_2_fetch", "artifact_kind": "derived_component"},
                {"module_type": "cFifo1_cpu", "artifact_kind": "derived_component"},
            ],
            "warnings": [],
        },
    )
    _write_json(
        modules_dir / "Leaf_mod.json",
        {
            "name": "Leaf_mod",
            "artifact_kind": "module",
            "file": "test_data/cpu/Leaf_mod.v",
            "module_role": "submodule",
            "interface": {"ports": [{"name": "i_drive", "direction": "input"}]},
            "direct_children": {"modules": [], "components": []},
            "transitive_summary": {"reachable_modules": [], "reachable_components": [], "families_used": []},
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )
    _write_json(
        components_dir / "cFifo1_cpu.json",
        {
            "name": "cFifo1_cpu",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/cFifo1_cpu.v",
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
            "implementation_summary": {"internal_dependencies": ["sender"]},
            "warnings": [],
        },
    )
    _write_json(
        components_dir / "cSelSplit_2_fetch.json",
        {
            "name": "cSelSplit_2_fetch",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/Fetch/cSelSplit_2_fetch.v",
            "family": "SelSplit",
            "role_mapping": {
                "upstream": {"ports": ["i_drive", "o_free"]},
                "downstream": {"ports": ["o_drive0", "i_free0", "o_drive1", "i_free1"]},
                "payload": {"ports": ["i_data"]},
                "condition": {"ports": ["sel"]},
            },
            "flow_semantics": {
                "event_behavior": "selected routing",
                "data_behavior": "payload follows selection",
                "completion_behavior": "selected free returns",
            },
            "contract": {
                "invariants": ["selected only"],
                "release_rule": {"policy": "selected_only", "details": "selected free only"},
            },
            "implementation_summary": {"internal_dependencies": ["contTap"]},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "cpu_top")

    assert manual_ir.top_module == "cpu_top"
    assert [item.module_name for item in manual_ir.objects.module_cards] == ["cpu_top", "Fetch_top", "Leaf_mod"]
    assert manual_ir.objects.module_cards[-1].module_role == "component"
    contracts_by_name = {item.component_name: item for item in manual_ir.objects.component_contracts}
    assert set(contracts_by_name) == {"cFifo1_cpu", "cSelSplit_2_fetch"}
    assert len(contracts_by_name["cFifo1_cpu"].warnings) == 1
    assert "component referenced by multiple parent modules:" in contracts_by_name["cFifo1_cpu"].warnings[0]
    assert "cpu_top" in contracts_by_name["cFifo1_cpu"].warnings[0]
    assert "Fetch_top" in contracts_by_name["cFifo1_cpu"].warnings[0]
    assert contracts_by_name["cSelSplit_2_fetch"].document_role == "splitter"
    assert manual_ir.objects.system_views[0].families_used == ["Fifo1", "SelSplit"]
    assert manual_ir.objects.system_views[0].external_dependencies[0].name == "Icache"
    assert manual_ir.indexes.by_family["SelSplit"] == ["contract:cSelSplit_2_fetch"]
    assert "module:Fetch_top" in manual_ir.indexes.by_module["Fetch_top"]
    assert manual_ir.warnings == [
        "flow path extraction is deferred in this phase.",
        "reading path planning is deferred in this phase.",
    ]


def test_build_manual_ir_uses_direct_children_when_instances_are_missing(tmp_path):
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
            "interface": {"ports": []},
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
            "interface": {"ports": []},
            "direct_children": {"modules": [], "components": []},
            "transitive_summary": {"reachable_modules": [], "reachable_components": []},
            "flow_graph": {"signals": [], "edges": []},
        },
    )
    _write_json(
        components_dir / "cFifo1_cpu.json",
        {
            "name": "cFifo1_cpu",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/cFifo1_cpu.v",
            "family": "Fifo1",
            "role_mapping": {},
            "flow_semantics": {},
            "contract": {"invariants": [], "release_rule": {}},
            "implementation_summary": {},
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "cpu_top")

    assert [item.module_name for item in manual_ir.objects.module_cards] == ["cpu_top", "Fetch_top"]
    assert [item.component_name for item in manual_ir.objects.component_contracts] == ["cFifo1_cpu"]


def test_build_manual_ir_populates_module_cards_from_interface_facts(tmp_path):
    artifacts_root = tmp_path / "artifacts"
    modules_dir = artifacts_root / "modules"
    components_dir = artifacts_root / "components"
    modules_dir.mkdir(parents=True)
    components_dir.mkdir(parents=True)

    _write_json(
        artifacts_root / "project_index.json",
        {
            "top_modules": [{"name": "cpu_top"}],
            "stats": {"module_count": 2, "component_count": 2},
        },
    )
    _write_json(
        modules_dir / "cpu_top.json",
        {
            "name": "cpu_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/CPU/cpu_top.v",
            "module_role": "top",
            "interface": {
                "ports": [
                    {"name": "rst", "direction": "input"},
                    {"name": "switch", "direction": "input"},
                    {"name": "i_driveFromTPUtoCPU", "direction": "input"},
                    {"name": "i_dataTPUtoCPU_80", "direction": "input"},
                    {"name": "o_freeFromCPUtoTPU", "direction": "output"},
                    {"name": "o_driveFromCPUtoTPU", "direction": "output"},
                    {"name": "i_freeFromTPUtoCPU", "direction": "input"},
                    {"name": "o_driveFromCPUtoTS", "direction": "output"},
                    {"name": "o_dataCPUtoTS_128", "direction": "output"},
                    {"name": "i_freeFromTStoCPU", "direction": "input"},
                    {"name": "i_driveFromTStoCPU", "direction": "input"},
                    {"name": "o_freeFromCPUtoTS", "direction": "output"},
                ]
            },
            "direct_children": {"modules": ["Fetch_top"], "components": ["cFifo1_cpu"]},
            "transitive_summary": {
                "reachable_modules": ["Fetch_top"],
                "reachable_components": ["cFifo1_cpu", "cSelSplit_2_fetch"],
                "families_used": ["Fifo1", "SelSplit"],
            },
            "flow_graph": {"signals": [], "edges": []},
            "instances": [
                {"module_type": "Fetch_top", "artifact_kind": "module"},
                {"module_type": "cFifo1_cpu", "artifact_kind": "derived_component"},
                {"module_type": "Icache", "artifact_kind": "external_dependency", "instance_name": "u_icache"},
            ],
            "warnings": [],
        },
    )
    _write_json(
        modules_dir / "Fetch_top.json",
        {
            "name": "Fetch_top",
            "artifact_kind": "module",
            "file": "test_data/cpu/Fetch/Fetch_top.v",
            "module_role": "submodule",
            "interface": {
                "ports": [
                    {"name": "switch", "direction": "input"},
                    {"name": "i_driveFromEXCPtoCPU", "direction": "input"},
                    {"name": "o_freeFromCPUtoEXCP", "direction": "output"},
                    {"name": "i_driveFromWBtoCPU", "direction": "input"},
                    {"name": "o_freeFromCPUtoWB", "direction": "output"},
                    {"name": "o_driveFromCPUtoIcache", "direction": "output"},
                    {"name": "i_freeFromIcachetoCPU", "direction": "input"},
                    {"name": "i_driveFromTStoCPU", "direction": "input"},
                    {"name": "o_freeFromCPUtoTS", "direction": "output"},
                    {"name": "o_driveFromFetchtoDecoder", "direction": "output"},
                    {"name": "i_freeFromDecodertoFetch", "direction": "input"},
                ]
            },
            "direct_children": {"modules": [], "components": ["cSelSplit_2_fetch", "cFifo1_cpu"]},
            "transitive_summary": {
                "reachable_modules": [],
                "reachable_components": ["cSelSplit_2_fetch", "cFifo1_cpu"],
                "families_used": ["Fifo1", "SelSplit"],
            },
            "flow_graph": {"signals": [], "edges": []},
            "instances": [
                {"module_type": "cSelSplit_2_fetch", "artifact_kind": "derived_component"},
                {"module_type": "cFifo1_cpu", "artifact_kind": "derived_component"},
            ],
            "warnings": [],
        },
    )
    _write_json(
        components_dir / "cFifo1_cpu.json",
        {
            "name": "cFifo1_cpu",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/cFifo1_cpu.v",
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
            "implementation_summary": {"internal_dependencies": ["sender"]},
            "warnings": [],
        },
    )
    _write_json(
        components_dir / "cSelSplit_2_fetch.json",
        {
            "name": "cSelSplit_2_fetch",
            "artifact_kind": "derived_component",
            "file": "test_data/cpu/Fetch/cSelSplit_2_fetch.v",
            "family": "SelSplit",
            "role_mapping": {
                "upstream": {"ports": ["i_drive", "o_free"]},
                "downstream": {"ports": ["o_drive0", "i_free0", "o_drive1", "i_free1"]},
                "payload": {"ports": ["i_data"]},
                "condition": {"ports": ["sel"]},
            },
            "flow_semantics": {
                "event_behavior": "selected routing",
                "data_behavior": "payload follows selection",
                "completion_behavior": "selected free returns",
            },
            "contract": {
                "invariants": ["selected only"],
                "release_rule": {"policy": "selected_only", "details": "selected free only"},
            },
            "implementation_summary": {"internal_dependencies": ["contTap"]},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "cpu_top")
    cards_by_name = {item.module_name: item for item in manual_ir.objects.module_cards}

    cpu_top_card = cards_by_name["cpu_top"]
    assert cpu_top_card.document_role == "glue"
    assert cpu_top_card.key_interfaces.ingress_channels == [
        "i_driveFromTPUtoCPU",
        "i_driveFromTStoCPU",
    ]
    assert cpu_top_card.key_interfaces.egress_channels == [
        "o_driveFromCPUtoTPU",
        "o_driveFromCPUtoTS",
    ]
    assert cpu_top_card.key_interfaces.control_signals == ["switch"]
    assert cpu_top_card.upstream_modules == []
    assert cpu_top_card.downstream_modules == []
    assert {point.via for point in cpu_top_card.backpressure_points} == {
        "i_freeFromTPUtoCPU",
        "i_freeFromTStoCPU",
    }
    assert any("直接包含 1 个子模块和 1 个结构子" in item for item in cpu_top_card.responsibilities)
    assert any("外部依赖 Icache" in item for item in cpu_top_card.risk_points)

    fetch_top_card = cards_by_name["Fetch_top"]
    assert fetch_top_card.document_role == "glue"
    assert fetch_top_card.upstream_modules == []
    assert fetch_top_card.downstream_modules == []
    assert {item.component: item.role for item in fetch_top_card.key_component_roles} == {
        "cFifo1_cpu": "fifo_stage",
        "cSelSplit_2_fetch": "splitter",
    }


def test_build_manual_ir_builds_boundary_channel_cards(tmp_path):
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
            "interface": {
                "ports": [
                    {"name": "i_drvFProducer", "direction": "input", "width_text": "1"},
                    {"name": "o_free2Producer", "direction": "output", "width_text": "1"},
                    {"name": "i_dataFProducer", "direction": "input", "width_text": "[31:0]"},
                    {"name": "o_drv2Consumer", "direction": "output", "width_text": "1"},
                    {"name": "i_freeFConsumer", "direction": "input", "width_text": "1"},
                    {"name": "o_data2Consumer", "direction": "output", "width_text": "[31:0]"},
                    {"name": "o_drv2NoFree", "direction": "output", "width_text": "1"},
                ]
            },
            "direct_children": {"modules": [], "components": []},
            "transitive_summary": {"reachable_modules": [], "reachable_components": [], "families_used": []},
            "flow_graph": {"signals": [], "edges": []},
            "warnings": [],
        },
    )

    kb = load_knowledge_base(artifacts_root)
    manual_ir = build_manual_ir(kb, "cpu_top")

    channels_by_drive = {
        item.handshake.drive: item
        for item in manual_ir.objects.channel_cards
    }
    assert set(channels_by_drive) == {"i_drvFProducer", "o_drv2Consumer", "o_drv2NoFree"}

    ingress = channels_by_drive["i_drvFProducer"]
    assert ingress.channel_type == "event_with_payload"
    assert ingress.producer.owner_kind == "external"
    assert ingress.producer.owner_name == "Producer"
    assert ingress.consumer.owner_kind == "module"
    assert ingress.consumer.owner_name == "cpu_top"
    assert ingress.consumer.free_signal == "o_free2Producer"
    assert ingress.payload.signals == ["i_dataFProducer"]
    assert ingress.payload.width_text == "[31:0]"

    egress = channels_by_drive["o_drv2Consumer"]
    assert egress.producer.owner_kind == "module"
    assert egress.producer.owner_name == "cpu_top"
    assert egress.consumer.owner_kind == "external"
    assert egress.consumer.owner_name == "Consumer"
    assert egress.consumer.free_signal == "i_freeFConsumer"
    assert egress.payload.signals == ["o_data2Consumer"]
    assert egress.handshake.backpressure_supported is True

    no_free = channels_by_drive["o_drv2NoFree"]
    assert no_free.confidence == "low"
    assert no_free.handshake.free == ""
    assert no_free.warnings == ["no matching free signal found for drive signal o_drv2NoFree."]
    assert "channel:cpu_top:o_drv2Consumer" in manual_ir.indexes.by_module["cpu_top"]
    assert "channel:cpu_top:o_drv2Consumer" in manual_ir.indexes.by_tag["channel"]
