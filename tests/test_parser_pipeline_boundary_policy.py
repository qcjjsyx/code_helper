from pathlib import Path

from parser.pipeline.boundary_policy import (
    decide_boundary,
    is_ignored_external_target,
    is_skip_helper_module,
)


def test_boundary_policy_classifies_component_leaf_names():
    module_index = {
        name: Path(f"{name}.v")
        for name in (
            "cFifo2",
            "cSelSplit3",
            "lsu_cFifo1_lsu",
            "ldwmFifo_lsu",
            "cMergeFifo1",
        )
    }

    for module_name in module_index:
        decision = decide_boundary(
            module_name,
            module_index=module_index,
            top_module_names=set(),
            file_path=module_index[module_name],
            cc_header={},
        )
        assert decision.kind == "component_leaf"
        assert decision.artifact_kind == "derived_component"

    assert decide_boundary(
        "cSelSplit3",
        module_index=module_index,
        top_module_names=set(),
        file_path=module_index["cSelSplit3"],
        cc_header={},
    ).family == "SelSplit"
    assert decide_boundary(
        "lsu_cFifo1_lsu",
        module_index=module_index,
        top_module_names=set(),
        file_path=module_index["lsu_cFifo1_lsu"],
        cc_header={},
    ).family == "Fifo1"


def test_boundary_policy_classifies_skip_helpers():
    assert is_skip_helper_module("delay1U") is True
    assert is_skip_helper_module("delay16U") is True
    assert is_skip_helper_module("delay1Unit") is True

    assert is_skip_helper_module("delay_free_cpu") is False
    assert is_skip_helper_module("delayU") is False
    assert is_skip_helper_module("delayfooU") is False
    assert is_skip_helper_module("delay1u") is False

    decision = decide_boundary(
        "delay1U",
        module_index={"delay1U": Path("delay1U.v")},
        top_module_names=set(),
        file_path=Path("delay1U.v"),
        cc_header={},
    )
    assert decision.kind == "skip_helper"


def test_boundary_policy_classifies_ignored_and_external_targets():
    assert is_ignored_external_target("contTap") is True
    assert is_ignored_external_target("freeSetDelay") is True
    assert is_ignored_external_target("IUMB") is True
    assert is_ignored_external_target("iumb") is False

    ignored = decide_boundary(
        "contTap",
        module_index={},
        top_module_names=set(),
        file_path=None,
        cc_header={},
    )
    assert ignored.kind == "ignored_external"
    assert ignored.artifact_kind == "external_dependency"

    external = decide_boundary(
        "unknown_block",
        module_index={},
        top_module_names=set(),
        file_path=None,
        cc_header={},
    )
    assert external.kind == "external_dependency"
    assert external.artifact_kind == "external_dependency"


def test_boundary_policy_keeps_known_indexed_modules_as_modules():
    decision = decide_boundary(
        "regular_module",
        module_index={"regular_module": Path("regular_module.v")},
        top_module_names=set(),
        file_path=Path("regular_module.v"),
        cc_header={},
    )
    assert decision.kind == "module"
    assert decision.artifact_kind == "module"
