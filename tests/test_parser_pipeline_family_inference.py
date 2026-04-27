from pathlib import Path

from parser.pipeline.boundary_policy import (
    TERMINAL_COMPONENT_FAMILY_BY_TYPE,
)
from parser.pipeline.family_inference import infer_family


def test_terminal_component_type_list_is_the_parser_stop_boundary():
    assert {
        "cArbMerge": "ArbMerge",
        "cFifo": "Fifo1",
        "cMutexMerge": "MutexMerge",
        "cPmtFifo": "PmtFifo1",
        "cNatSplit": "NatSplit",
        "cWaitMerge": "WaitMerge",
        "cSelSplit": "SelSplit",
    }.items() <= TERMINAL_COMPONENT_FAMILY_BY_TYPE.items()


def test_infer_family_uses_terminal_component_type_prefixes():
    cases = {
        "cArbMerge5_route": ("ArbMerge", "cArbMerge", 5),
        "cFifo2": ("Fifo1", "cFifo", None),
        "cFifo3_fetch": ("Fifo1", "cFifo", None),
        "cMutexMerge10_64b_exe": ("MutexMerge", "cMutexMerge", 10),
        "cPmtFifo1": ("PmtFifo1", "cPmtFifo", None),
        "cNatSplit2_lsu": ("NatSplit", "cNatSplit", 2),
        "cWaitMerge_3_launch": ("WaitMerge", "cWaitMerge", 3),
        "cSelSplit_2_fetch": ("SelSplit", "cSelSplit", 2),
    }

    for module_name, (family, component_type, num_ports) in cases.items():
        inferred = infer_family(module_name=module_name)
        assert inferred["family"] == family
        assert inferred["component_type"] == component_type
        assert inferred["num_ports"] == num_ports
        assert inferred["source"] == "terminal_component_type"


def test_terminal_component_type_matching_is_prefix_based():
    assert infer_family(module_name="cFifo2_socmem")["family"] == "Fifo1"
    assert infer_family(module_name="my_cSelSplit_2")["family"] is None


def test_fifo_like_names_are_terminal_components_even_without_cfifo_prefix():
    cases = {
        "lsu_cFifo1_lsu": ("Fifo1", "cFifo"),
        "ldwmFifo_lsu": ("Fifo1", "Fifo"),
        "swFifo_lsu": ("Fifo1", "Fifo"),
        "cLastFifo1": ("Fifo1", "Fifo"),
        "cMergeFifo1": ("Fifo1", "Fifo"),
        "cFifo1ArbSend": ("Fifo1", "cFifo"),
        "cMergePmtFifo1": ("PmtFifo1", "cPmtFifo"),
    }

    for module_name, (family, component_type) in cases.items():
        inferred = infer_family(module_name=module_name)
        assert inferred["family"] == family
        assert inferred["component_type"] == component_type
        assert inferred["source"] == "fifo_like_component_type"


def test_cc_header_family_does_not_override_parser_boundary_rules():
    header = {"family": "NatSplitN", "params": {"NUM_PORTS": 3}}
    inferred = infer_family(
        module_name="cFifo2",
        file_path=str(Path("test_data/cpu/Fetch/cSelSplit_2_fetch.v")),
        cc_header=header,
    )
    assert inferred["family"] == "Fifo1"
    assert inferred["num_ports"] is None
    assert inferred["source"] == "terminal_component_type"
