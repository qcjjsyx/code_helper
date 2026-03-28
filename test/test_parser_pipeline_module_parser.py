from pathlib import Path

from parser_pipeline.module_parser import parse_verilog_file


REPO_ROOT = Path(__file__).resolve().parents[1]


def test_parse_module_extracts_instances_connections_and_overrides():
    path = REPO_ROOT / "CPU" / "Exe" / "exe_top.v"
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
