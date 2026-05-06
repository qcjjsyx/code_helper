from pathlib import Path

from parser.pipeline.module_parser import parse_named_connections, parse_verilog_file


REPO_ROOT = Path(__file__).resolve().parents[1]


def test_parse_module_extracts_instances_connections_and_overrides():
    path = REPO_ROOT / "test_data" / "cpu" / "Exe" / "exe_top.v"
    parsed = parse_verilog_file(path)

    assert parsed["name"] == "exe_top"
    assert any(port["name"] == "i_decoderExeBus_343" for port in parsed["ports"])
    assert any(signal["name"] == "w_driveNextalu" for signal in parsed["local_signals"])

    delay_instances = [
        instance for instance in parsed["instances"] if instance["instance_name"] == "delay_free_cpu_sel"
    ]
    assert delay_instances, "expected to parse delay_free_cpu_sel instance"
    assert delay_instances[0]["parameter_overrides"]["$0"] == "15"

    split_instances = [
        instance for instance in parsed["instances"] if instance["module_type"] == "cSelSplit_6_exe"
    ]
    assert split_instances, "expected to parse cSelSplit_6_exe instantiation"
    ports = {item["port"]: item["signal"] for item in split_instances[0]["connections"]}
    assert ports["i_drive"] == "w_driveFifoToSel_dealy1"
    assert ports["valid5"] == "w_bru_1"


def test_parse_named_connections_records_simple_concat_signal_terms():
    connections = parse_named_connections(
        ".i_drive_5({i_driveLocal,i_driveSouth,i_driveNorth,i_driveEast,i_driveWest}),"
        ".o_driveNext(o_driveNext)"
    )

    drive_connection = connections[0]
    assert drive_connection["signal"] == "{i_driveLocal,i_driveSouth,i_driveNorth,i_driveEast,i_driveWest}"
    assert drive_connection["signal_terms"] == [
        "i_driveLocal",
        "i_driveSouth",
        "i_driveNorth",
        "i_driveEast",
        "i_driveWest",
    ]
    assert "signal_terms" not in connections[1]


def test_parse_module_extracts_non_ansi_port_declarations(tmp_path):
    path = tmp_path / "cFifo1.v"
    path.write_text(
        """
        module cFifo1(
          i_drive, i_freeNext, rst,
          o_free, o_driveNext,
          o_fire_1
        );

        input i_drive, i_freeNext, rst;
        output o_free, o_driveNext;
        output o_fire_1;
        endmodule
        """,
        encoding="utf-8",
    )

    parsed = parse_verilog_file(path)

    assert parsed["ports"] == [
        {"name": "i_drive", "direction": "input", "width_text": "1"},
        {"name": "i_freeNext", "direction": "input", "width_text": "1"},
        {"name": "rst", "direction": "input", "width_text": "1"},
        {"name": "o_free", "direction": "output", "width_text": "1"},
        {"name": "o_driveNext", "direction": "output", "width_text": "1"},
        {"name": "o_fire_1", "direction": "output", "width_text": "1"},
    ]
    assert parsed["reset"] == {"reset_port": "rst", "reset_active_low": False}


def test_parse_module_extracts_non_ansi_widths_and_event_source_ports(tmp_path):
    path = tmp_path / "eventSource.v"
    path.write_text(
        """
        module eventSource(rst, switch, fire, data_bus);
        input rst, switch;
        input [7:0] data_bus;
        output fire;
        endmodule
        """,
        encoding="utf-8",
    )

    parsed = parse_verilog_file(path)
    ports = {port["name"]: port for port in parsed["ports"]}

    assert list(ports) == ["rst", "switch", "fire", "data_bus"]
    assert ports["rst"] == {"name": "rst", "direction": "input", "width_text": "1"}
    assert ports["switch"] == {"name": "switch", "direction": "input", "width_text": "1"}
    assert ports["fire"] == {"name": "fire", "direction": "output", "width_text": "1"}
    assert ports["data_bus"] == {"name": "data_bus", "direction": "input", "width_text": "[7:0]"}


def test_parse_module_marks_scalar_local_signals_as_width_one(tmp_path):
    path = tmp_path / "scalar_locals.v"
    path.write_text(
        """
        module scalar_locals(output done);
          wire scalar_wire;
          reg scalar_reg;
          logic [3:0] vector_logic;
        endmodule
        """,
        encoding="utf-8",
    )

    parsed = parse_verilog_file(path)
    local_signals = {signal["name"]: signal for signal in parsed["local_signals"]}

    assert parsed["ports"] == [{"name": "done", "direction": "output", "width_text": "1"}]
    assert local_signals["scalar_wire"]["width_text"] == "1"
    assert local_signals["scalar_reg"]["width_text"] == "1"
    assert local_signals["vector_logic"]["width_text"] == "[3:0]"
