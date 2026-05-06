from pathlib import Path

from parser.pipeline.boundary_policy import is_skip_helper_module
from parser.pipeline.hierarchy_builder import build_project_from_filelists


REPO_ROOT = Path(__file__).resolve().parents[1]


def _write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.strip() + "\n", encoding="utf-8")


def _write_family_templates(repo_root: Path) -> None:
    _write_text(
        repo_root / "parser" / "schemas" / "json_templates" / "family_level.json",
        """
        {
          "templates": [
            {
              "family": "Fifo1",
              "contract": {"invariants": [], "release_rule": {}}
            },
            {
              "family": "SelSplit",
              "contract": {"invariants": [], "release_rule": {}}
            }
          ]
        }
        """,
    )


def test_cpu_top_hierarchy_reaches_modules_and_components(tmp_path):
    result = build_project_from_filelists(
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
    assert cpu_top["interface_summary"]["signal_groups"]["event_inputs"] == [
        "i_driveFromDcachetoMem",
        "i_driveFromIcachetoMem",
        "i_driveFromTPUtoCPU",
        "i_driveFromTStoCPU",
    ]
    assert cpu_top["interface_summary"]["signal_groups"]["event_outputs"] == [
        "o_driveFromCPUtoTPU",
        "o_driveFromCPUtoTS",
        "o_driveFromMemtoDcache",
        "o_driveFromMemtoIcache",
    ]
    assert cpu_top["interface_summary"]["control_signals"] == ["switch"]
    assert cpu_top["interface_summary"]["backpressure_signals"] == [
        "i_freeFromDcachetoMem",
        "i_freeFromIcachetoMem",
        "i_freeFromTPUtoCPU",
        "i_freeFromTStoCPU",
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
    delay_issues = [
        item for item in result["build_report"]["issues"]
        if "delay" in item.get("message", "").lower()
    ]
    assert delay_issues == []
    cont_tap_issues = [
        item for item in result["build_report"]["issues"]
        if "conttap" in item.get("message", "").lower()
    ]
    assert cont_tap_issues == []

    remaining_delay_instances = [
        instance
        for module_json in result["modules"].values()
        for instance in module_json["instances"]
        if is_skip_helper_module(instance["module_type"])
    ]
    assert remaining_delay_instances == []


def test_hierarchy_stops_at_terminal_component_types(tmp_path):
    _write_family_templates(tmp_path)
    _write_text(
        tmp_path / "top.v",
        """
        module top();
          cFifo2 u_fifo();
          lsu_cFifo1_lsu u_data_fifo();
          cSelSplit3 u_split();
          delay2U u_delay();
          delay1Unit u_unit_delay();
          child u_child();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "child.v",
        """
        module child();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "cFifo2.v",
        """
        module cFifo2(i_drive, i_freeNext, rst, o_free, o_driveNext, o_fire_1);
          input i_drive, i_freeNext, rst;
          output o_free, o_driveNext;
          output o_fire_1;
          fifo_leaf u_leaf();
          delay4U u_delay();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "cSelSplit3.v",
        """
        module cSelSplit3();
          split_leaf u_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "lsu_cFifo1_lsu.v",
        """
        module lsu_cFifo1_lsu();
          data_fifo_leaf u_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "fifo_leaf.v",
        """
        module fifo_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "data_fifo_leaf.v",
        """
        module data_fifo_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "split_leaf.v",
        """
        module split_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "delay2U.v",
        """
        module delay2U();
          delay_leaf u_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "delay4U.v",
        """
        module delay4U();
          delay_leaf u_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "delay1Unit.v",
        """
        module delay1Unit();
          delay_leaf u_leaf();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "delay_leaf.v",
        """
        module delay_leaf();
        endmodule
        """,
    )

    result = build_project_from_filelists(
        repo_root=tmp_path,
        inputs=["."],
        tops=["top.v"],
        output_dir=tmp_path / "artifacts" / "parser_pipeline_result",
    )

    assert sorted(result["modules"]) == ["child", "top"]
    assert sorted(result["components"]) == ["cFifo2", "cSelSplit3", "lsu_cFifo1_lsu"]
    assert result["modules"]["top"]["direct_children"] == {
        "modules": ["child"],
        "components": ["cFifo2", "cSelSplit3", "lsu_cFifo1_lsu"],
    }
    assert result["components"]["cFifo2"]["family"] == "Fifo1"
    assert result["components"]["lsu_cFifo1_lsu"]["family"] == "Fifo1"
    assert result["components"]["cFifo2"]["implementation_summary"] == {
        "internal_dependencies": ["fifo_leaf"],
        "stops_at_family_level": True,
    }
    assert result["components"]["cFifo2"]["role_mapping"] == {
        "upstream": {"ports": ["i_drive", "o_free"]},
        "downstream": {"ports": ["o_driveNext", "i_freeNext"]},
        "payload": {"ports": []},
        "fire": {"ports": ["o_fire_1"]},
    }
    assert result["components"]["lsu_cFifo1_lsu"]["implementation_summary"] == {
        "internal_dependencies": ["data_fifo_leaf"],
        "stops_at_family_level": True,
    }
    assert all(instance["module_type"] != "delay2U" for instance in result["modules"]["top"]["instances"])
    assert all(instance["module_type"] != "delay1Unit" for instance in result["modules"]["top"]["instances"])
    assert not any(item["name"] == "fifo_leaf" for item in result["project_index"]["artifacts"]["modules"])
    assert not any(item["name"] == "data_fifo_leaf" for item in result["project_index"]["artifacts"]["modules"])
    assert not any(item["name"] == "split_leaf" for item in result["project_index"]["artifacts"]["modules"])
    assert not any(item["name"] == "delay2U" for item in result["project_index"]["artifacts"]["modules"])
    assert not any(item["name"] == "delay4U" for item in result["project_index"]["artifacts"]["modules"])
    assert not any(item["name"] == "delay1Unit" for item in result["project_index"]["artifacts"]["modules"])
    assert result["build_report"]["issues"] == []


def test_skip_helper_delay_records_transparent_event_flow(tmp_path):
    _write_family_templates(tmp_path)
    _write_text(
        tmp_path / "top.v",
        """
        module top(i_driveIn, o_driveOut);
          input i_driveIn;
          output o_driveOut;
          delay8U u_delay(.inR(i_driveIn), .outR(o_driveOut), .rst(rst));
        endmodule
        """,
    )
    _write_text(
        tmp_path / "delay8U.v",
        """
        module delay8U(inR, outR, rst);
          input inR, rst;
          output outR;
        endmodule
        """,
    )

    result = build_project_from_filelists(
        repo_root=tmp_path,
        inputs=["."],
        tops=["top.v"],
        output_dir=tmp_path / "artifacts" / "parser_pipeline_result",
    )

    top = result["modules"]["top"]
    assert top["instances"] == []
    assert top["transparent_flows"] == [
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
    ]
    assert any(
        edge["transparent"] is True
        and edge["signal"] == "i_driveIn"
        and edge["edge_kind"] == "signal_to_instance"
        for edge in top["flow_graph"]["edges"]
    )
    assert any(
        edge["transparent"] is True
        and edge["signal"] == "o_driveOut"
        and edge["edge_kind"] == "instance_to_signal"
        for edge in top["flow_graph"]["edges"]
    )


def test_component_leaf_with_missing_family_template_uses_empty_contract(tmp_path):
    _write_family_templates(tmp_path)
    _write_text(
        tmp_path / "top.v",
        """
        module top();
          eventSource u_event();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "eventSource.v",
        """
        module eventSource();
          inner_leaf u_inner();
        endmodule
        """,
    )
    _write_text(
        tmp_path / "inner_leaf.v",
        """
        module inner_leaf();
        endmodule
        """,
    )

    result = build_project_from_filelists(
        repo_root=tmp_path,
        inputs=["."],
        tops=["top.v"],
        output_dir=tmp_path / "artifacts" / "parser_pipeline_result",
    )

    assert sorted(result["modules"]) == ["top"]
    assert sorted(result["components"]) == ["eventSource"]
    event_source = result["components"]["eventSource"]
    assert event_source["family"] == "eventSource"
    assert event_source["contract"] == {}
    assert event_source["template_source"] == "missing_family_template"
    assert "family template missing for eventSource; using empty contract" in event_source["warnings"]
    assert result["modules"]["top"]["direct_children"] == {
        "modules": [],
        "components": ["eventSource"],
    }
