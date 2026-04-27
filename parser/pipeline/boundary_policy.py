"""Central parsing-boundary policy for module, component, and helper targets."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from typing import Any, Dict, Literal, Mapping, Optional


BoundaryKind = Literal[
    "module",
    "component_leaf",
    "skip_helper",
    "ignored_external",
    "external_dependency",
]


KNOWN_COMPONENT_FAMILIES = {
    "SelSplit",
    "NatSplit",
    "WaitMerge",
    "ArbMerge",
    "MutexMerge",
    "Fifo1",
    "PmtFifo1",
    "eventSource",
}


TERMINAL_COMPONENT_FAMILY_BY_TYPE = {
    "cArbMerge": "ArbMerge",
    "cFifo": "Fifo1",
    "cMutexMerge": "MutexMerge",
    "cPmtFifo": "PmtFifo1",
    "cNatSplit": "NatSplit",
    "cWaitMerge": "WaitMerge",
    "cSelSplit": "SelSplit",
    "cSplit": "SelSplit",
    "cSplitter": "SelSplit",
    "cSelector": "SelSplit",
    "cCondFork": "SelSplit",
    "eventSource": "eventSource",
}


TERMINAL_COMPONENT_PATTERNS = [
    (
        component_type,
        family,
        re.compile(rf"^{re.escape(component_type)}_?(\d+)?(?:_|$)", re.IGNORECASE),
    )
    for component_type, family in TERMINAL_COMPONENT_FAMILY_BY_TYPE.items()
]


FIFO_LIKE_PATTERNS = [
    ("cPmtFifo", "PmtFifo1", re.compile(r"PmtFifo\d*(?:_|$|[A-Z])", re.IGNORECASE)),
    ("cFifo", "Fifo1", re.compile(r"cFifo\d*(?:_|$|[A-Z])", re.IGNORECASE)),
    ("Fifo", "Fifo1", re.compile(r"Fifo\d*(?:_|$|[A-Z])", re.IGNORECASE)),
]


IGNORED_EXTERNAL_EXACT = {
    "contTap",
    "freeSetDelay",
    "IUMB",
    "BUFM2HM",
    "SHKB110_1024X8X8CM8",
    "HKB110_4096X8X8CM8",
}


@dataclass(frozen=True)
class BoundaryDecision:
    kind: BoundaryKind
    artifact_kind: str
    family: str | None = None
    num_ports: int | None = None
    component_type: str | None = None
    source: str = ""


def decide_boundary(
    module_name: str,
    *,
    module_index: Mapping[str, Path],
    top_module_names: set[str],
    file_path: Path | None = None,
    cc_header: Optional[Dict[str, Any]] = None,
) -> BoundaryDecision:
    if is_skip_helper_module(module_name):
        return BoundaryDecision(
            kind="skip_helper",
            artifact_kind="skip_helper",
            source="skip_helper_rule",
        )

    if module_name in top_module_names:
        return BoundaryDecision(
            kind="module",
            artifact_kind="module",
            source="top_module",
        )

    family_info = infer_component_family(
        module_name=module_name,
        file_path=str(file_path or module_index.get(module_name) or module_name),
        cc_header=cc_header,
    )
    family = family_info.get("family")
    if is_known_family(family) and (file_path is not None or module_name in module_index):
        return BoundaryDecision(
            kind="component_leaf",
            artifact_kind="derived_component",
            family=family,
            num_ports=family_info.get("num_ports"),
            component_type=family_info.get("component_type"),
            source=family_info.get("source", ""),
        )

    if module_name in module_index:
        return BoundaryDecision(
            kind="module",
            artifact_kind="module",
            source="module_index",
        )

    if is_ignored_external_target(module_name):
        return BoundaryDecision(
            kind="ignored_external",
            artifact_kind="external_dependency",
            source="ignored_external_exact",
        )

    return BoundaryDecision(
        kind="external_dependency",
        artifact_kind="external_dependency",
        family=family if isinstance(family, str) else None,
        num_ports=family_info.get("num_ports"),
        component_type=family_info.get("component_type"),
        source=family_info.get("source", "unknown"),
    )


def infer_component_family(
    module_name: str = "",
    file_path: str = "",
    cc_header: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    # cc_header is accepted for call-site compatibility; boundary decisions are name/parser based.
    _ = cc_header
    candidates = [module_name, Path(file_path).stem]
    for candidate in candidates:
        if not candidate:
            continue
        for component_type, family, pattern in TERMINAL_COMPONENT_PATTERNS:
            match = pattern.search(candidate)
            if match:
                group_value = match.group(1) if match.lastindex else None
                num_ports = (
                    None
                    if family in {"Fifo1", "PmtFifo1"}
                    else _extract_num_ports(group_value, module_name, file_path)
                )
                return {
                    "family": family,
                    "num_ports": num_ports,
                    "component_type": component_type,
                    "source": "terminal_component_type",
                }
        for component_type, family, pattern in FIFO_LIKE_PATTERNS:
            if pattern.search(candidate):
                return {
                    "family": family,
                    "num_ports": None,
                    "component_type": component_type,
                    "source": "fifo_like_component_type",
                }
    return {"family": None, "num_ports": None, "source": "unknown"}


def is_known_family(family: Optional[str]) -> bool:
    return family in KNOWN_COMPONENT_FAMILIES


def normalize_family_name(value: str) -> str:
    lowered = value.strip().lower()
    mapping = {
        "selsplit": "SelSplit",
        "natsplit": "NatSplit",
        "natsplitn": "NatSplit",
        "waitmerge": "WaitMerge",
        "waitmergen": "WaitMerge",
        "arbmerge": "ArbMerge",
        "arbmergen": "ArbMerge",
        "mutexmerge": "MutexMerge",
        "mutexmergen": "MutexMerge",
        "fifo": "Fifo1",
        "fifo1": "Fifo1",
        "pmtfifo": "PmtFifo1",
        "pmtfifo1": "PmtFifo1",
    }
    return mapping.get(lowered, value)


def is_skip_helper_module(module_name: str) -> bool:
    return bool(re.fullmatch(r"delay\d+(?:U|Unit)", module_name.strip()))


def is_ignored_external_target(module_name: str) -> bool:
    return module_name.strip() in IGNORED_EXTERNAL_EXACT


def _extract_num_ports(value: Any, module_name: str, file_path: str) -> Optional[int]:
    if isinstance(value, int):
        return value
    if isinstance(value, str) and value.isdigit():
        return int(value)

    candidates = [module_name, Path(file_path).stem]
    for candidate in candidates:
        match = re.search(
            r"(?:SelSplit|NatSplit|WaitMerge|ArbMerge|MutexMerge)_?(\d+)",
            candidate,
            re.IGNORECASE,
        )
        if match:
            return int(match.group(1))
    return None
