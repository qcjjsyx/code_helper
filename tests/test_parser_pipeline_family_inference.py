from pathlib import Path

from parser_pipeline.family_inference import infer_family


def test_infer_family_supports_underscore_and_compact_names():
    assert infer_family(module_name="cSelSplit_2_fetch")["family"] == "SelSplit"
    assert infer_family(module_name="cSelSplit_2_fetch")["num_ports"] == 2

    assert infer_family(module_name="cNatSplit2_lsu")["family"] == "NatSplit"
    assert infer_family(module_name="cNatSplit2_lsu")["num_ports"] == 2

    assert infer_family(module_name="cMutexMerge2_d_lsu")["family"] == "MutexMerge"
    assert infer_family(module_name="cMutexMerge2_d_lsu")["num_ports"] == 2

    assert infer_family(module_name="cFifo1_cpu")["family"] == "Fifo1"


def test_cc_header_family_has_priority():
    header = {"family": "NatSplitN", "params": {"NUM_PORTS": 3}}
    inferred = infer_family(
        module_name="something_else",
        file_path=str(Path("test_data/cpu/Fetch/cSelSplit_2_fetch.v")),
        cc_header=header,
    )
    assert inferred["family"] == "NatSplit"
    assert inferred["num_ports"] == 3
