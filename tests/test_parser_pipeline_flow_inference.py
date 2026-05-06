from parser.pipeline.flow_inference import build_flow_graph, extract_signal_terms, infer_signal_role


def test_signal_role_rules_cover_core_protocol_names():
    assert infer_signal_role("i_driveToExe") == "event_drive"
    assert infer_signal_role("i_drvFCPU") == "event_drive"
    assert infer_signal_role("o_drv2CPU") == "event_drive"
    assert infer_signal_role("o_freeFrmExe") == "event_free"
    assert infer_signal_role("o_dataCPUtoTS_128") == "payload_data"
    assert infer_signal_role("rstn") == "reset"
    assert infer_signal_role("valid0") == "condition"
    assert infer_signal_role("addrvance") == "unknown"


def test_flow_graph_uses_port_directions_for_edges():
    graph = build_flow_graph(
        {
            "ports": [{"name": "rst", "direction": "input", "width_text": None}],
            "local_signals": [{"name": "w_drive", "kind": "wire", "width_text": None}],
            "instances": [
                {
                    "instance_name": "u0",
                    "module_type": "child",
                    "connections": [
                        {
                            "port": "i_drive",
                            "signal": "w_drive",
                            "port_direction": "input",
                            "signal_role": "event_drive",
                        },
                        {
                            "port": "o_free",
                            "signal": "w_free",
                            "port_direction": "output",
                            "signal_role": "event_free",
                        },
                    ],
                }
            ],
        }
    )

    assert any(edge["edge_kind"] == "signal_to_instance" for edge in graph["edges"])
    assert any(edge["edge_kind"] == "instance_to_signal" for edge in graph["edges"])
    assert any(signal["name"] == "w_drive" for signal in graph["signals"])


def test_flow_graph_expands_simple_concat_signal_terms():
    signal = "{i_driveLocal,i_driveSouth,i_driveNorth,i_driveEast,i_driveWest}"
    assert extract_signal_terms(signal) == [
        "i_driveLocal",
        "i_driveSouth",
        "i_driveNorth",
        "i_driveEast",
        "i_driveWest",
    ]

    graph = build_flow_graph(
        {
            "ports": [{"name": "i_driveEast", "direction": "input", "width_text": "1"}],
            "local_signals": [],
            "instances": [
                {
                    "instance_name": "arbMerge",
                    "module_type": "cArbMerge5_51b",
                    "connections": [
                        {
                            "port": "i_drive_5",
                            "signal": signal,
                            "signal_terms": extract_signal_terms(signal),
                            "port_direction": "input",
                            "signal_role": "event_drive",
                        }
                    ],
                }
            ],
        }
    )

    assert any(item["name"] == signal and item["kind"] == "expression" for item in graph["signals"])
    assert any(item["name"] == "i_driveEast" for item in graph["signals"])
    assert any(edge["signal"] == signal and "source_expression" not in edge for edge in graph["edges"])
    assert any(
        edge["signal"] == "i_driveEast"
        and edge["source_expression"] == signal
        and edge["edge_kind"] == "signal_to_instance"
        for edge in graph["edges"]
    )
