"""Read optional //@cc headers as hints for derived components."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict

from tools.cc_header_tools.parser import extract_cc_block, parse_yaml_min


def read_cc_header(path: Path) -> Dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    cc_text, _ = extract_cc_block(text)
    if not cc_text:
        return {}
    parsed = parse_yaml_min(cc_text)
    return parsed if isinstance(parsed, dict) else {}
