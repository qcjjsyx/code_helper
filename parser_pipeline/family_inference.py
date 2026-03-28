"""Infer component family from cc headers, module names, or file names."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, Optional


FAMILY_PATTERNS = [
    ("SelSplit", re.compile(r"cSelSplit_?(\d+)?", re.IGNORECASE)),
    ("NatSplit", re.compile(r"cNatSplit_?(\d+)?", re.IGNORECASE)),
    ("WaitMerge", re.compile(r"cWaitMerge_?(\d+)?", re.IGNORECASE)),
    ("ArbMerge", re.compile(r"cArbMerge_?(\d+)?", re.IGNORECASE)),
    ("MutexMerge", re.compile(r"cMutexMerge_?(\d+)?", re.IGNORECASE)),
    ("PmtFifo1", re.compile(r"cPmtFifo1?_?", re.IGNORECASE)),
    ("Fifo1", re.compile(r"cFifo1_?", re.IGNORECASE)),
]


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
        "fifo1": "Fifo1",
        "pmtfifo": "PmtFifo1",
        "pmtfifo1": "PmtFifo1",
    }
    return mapping.get(lowered, value)


def infer_family(
    module_name: str = "",
    file_path: str = "",
    cc_header: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    if cc_header:
        family = cc_header.get("family")
        if isinstance(family, str) and family.strip():
            normalized = normalize_family_name(family)
            num_ports = _extract_num_ports(
                cc_header.get("params", {}).get("NUM_PORTS"), module_name, file_path
            )
            return {
                "family": normalized,
                "num_ports": num_ports,
                "source": "cc_header",
            }

    candidates = [module_name, Path(file_path).stem]
    for candidate in candidates:
        if not candidate:
            continue
        for family, pattern in FAMILY_PATTERNS:
            match = pattern.search(candidate)
            if match:
                group_value = match.group(1) if match.lastindex else None
                num_ports = _extract_num_ports(group_value, module_name, file_path)
                return {
                    "family": family,
                    "num_ports": num_ports,
                    "source": "name_inference",
                }
    return {"family": None, "num_ports": None, "source": "unknown"}


def is_known_family(family: Optional[str]) -> bool:
    return family in {
        "SelSplit",
        "NatSplit",
        "WaitMerge",
        "ArbMerge",
        "MutexMerge",
        "Fifo1",
        "PmtFifo1",
    }


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
