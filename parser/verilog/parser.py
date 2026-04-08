"""Lightweight Verilog parser to extract top module name and instantiated submodule types.

Only uses Python standard library.
"""
from __future__ import annotations

import os
import re
from typing import List, Dict, Optional, Any


def remove_comments(text: str) -> str:
    pattern = r"//.*?$|/\*.*?\*/"
    return re.sub(pattern, "", text, flags=re.DOTALL | re.MULTILINE)


def _find_matching_paren(text: str, open_pos: int) -> int:
    """Return position of closing ')' for '(' at open_pos, or -1."""
    depth = 0
    i = open_pos
    while i < len(text):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def _extract_port_list_string(cleaned_body: str, module_start: int, module_end: int) -> Optional[str]:
    """Extract the port list string between module name ( and ); from module body."""
    head = cleaned_body[module_start:module_start + 200]
    mod_match = re.search(r"\bmodule\s+[A-Za-z_]\w*\s*\(", head, re.IGNORECASE)
    if not mod_match:
        return None
    open_in_head = mod_match.end() - 1
    open_abs = module_start + open_in_head
    close_abs = _find_matching_paren(cleaned_body, open_abs)
    if close_abs < 0:
        return None
    return cleaned_body[open_abs + 1:close_abs].strip()


def _remove_attributes(s: str) -> str:
    """Remove Verilog (* ... *) attributes from string."""
    return re.sub(r"\(\*\s*[^*]*\*\)", " ", s)


def _parse_port_list(port_list_str: str) -> Dict[str, Any]:
    """Parse port list string into interface dict: inputs, output.ports, inout, reset."""
    s = _remove_attributes(port_list_str)
    s = re.sub(r"//.*?$", "", s, flags=re.MULTILINE)
    s = " ".join(s.split())
    inputs_list: List[Dict[str, Any]] = []
    output_ports: List[Dict[str, Any]] = []
    inout_list: List[Dict[str, Any]] = []
    reset_port: Optional[str] = None
    reset_active_low = False

    dir_re = re.compile(
        r"\b(input|output|inout)\b\s*(?:\[(\d+)\s*:\s*(\d+)\])?\s*([A-Za-z_][\w]*)",
        re.IGNORECASE
    )
    cont_re = re.compile(r",\s*(?:\[(\d+)\s*:\s*(\d+)\])?\s*([A-Za-z_][\w]*)")

    pos = 0
    while pos < len(s):
        m = dir_re.search(s, pos)
        if not m:
            break
        direction = m.group(1).lower()
        msb, lsb = m.group(2), m.group(3)
        width = int(msb) - int(lsb) + 1 if (msb is not None and lsb is not None) else 1
        name = m.group(4).strip()
        pos = m.end()

        def add_port(n: str, w: Optional[str], d: str) -> None:
            nonlocal reset_port, reset_active_low
            entry = {"name": n, "width": w}
            if d == "input":
                inputs_list.append({"index": len(inputs_list), **entry})
                if n.lower() in ("rstn", "rst_n", "reset_n"):
                    reset_port = n
                    reset_active_low = True
                elif n.lower() in ("rst", "reset") and reset_port is None:
                    reset_port = n
                    reset_active_low = False
            elif d == "output":
                output_ports.append(entry)
            else:
                inout_list.append(entry)

        add_port(name, width, direction)

        while pos < len(s):
            skip = re.match(r"\s*,\s*", s[pos:])
            if not skip:
                break
            pos += skip.end()
            next_kw = re.search(r"\b(input|output|inout)\b", s[pos:], re.IGNORECASE)
            if next_kw and next_kw.start() == 0:
                break
            cont = cont_re.match(s[pos:])
            if cont:
                msb2, lsb2 = cont.group(1), cont.group(2)
                w2 = f"[{msb2}:{lsb2}]" if (msb2 and lsb2) else None
                add_port(cont.group(3).strip(), w2, direction)
                pos += cont.end()
            else:
                id_m = re.match(r"([A-Za-z_][\w]*)", s[pos:])
                if id_m:
                    add_port(id_m.group(1), width, direction) # type: ignore
                    pos += id_m.end()
                break

    output_obj: Dict[str, Any] = {"ports": output_ports}
    interface: Dict[str, Any] = {
        "inputs": inputs_list,
        "output": output_obj,
        "reset": {"reset_port": reset_port, "reset_active_low": reset_active_low},
    }
    if inout_list:
        interface["inout"] = inout_list
    return interface

def find_top_module_and_span(text: str):
    """Return (top_module_name, start_index, end_index) or (None, None, None).

    Uses a simple depth scan over module/endmodule tokens to find the first
    top-level module (depth 0 -> 1) and its matching endmodule (depth back to 0).
    """
    mod_re = re.compile(r"\bmodule\b\s+([A-Za-z_]\w*)", flags=re.IGNORECASE)
    end_re = re.compile(r"\bendmodule\b", flags=re.IGNORECASE)

    # collect events
    events = []
    for m in mod_re.finditer(text):
        events.append((m.start(), "module", m.group(1)))
    for m in end_re.finditer(text):
        events.append((m.start(), "endmodule", None))
    if not events:
        return None, None, None
    events.sort(key=lambda x: x[0])

    depth = 0
    top_name = None
    top_start = None
    top_end = None
    for pos, kind, name in events:
        if kind == "module":
            if depth == 0:
                # entering a top-level module
                top_name = name
                top_start = pos
            depth += 1
        else:
            if depth > 0:
                depth -= 1
                if depth == 0 and top_name is not None and top_end is None:
                    top_end = pos + len("endmodule")
                    break

    if top_name is None:
        return None, None, None
    return top_name, top_start, top_end


def extract_instantiated_submodules(text: str) -> List[str]:
    """Find module-type names from instantiation statements within given text.

    Matches patterns like:
      Fetch_top u_Fetch_top(...);
      Fetch_top #(.P(...)) u_Fetch_top (...);
    Returns unique list preserving first-seen order.
    """
    # Match patterns like:
    #   ModuleType InstanceName (...);
    #   ModuleType #(...) InstanceName (...);
    # We capture ModuleType in group 1. The parameter area is simplified (no nesting handling).
    pattern = re.compile(r"\b([A-Za-z_]\w*)\b\s*(?:#\s*\(.*?\))?\s+([A-Za-z_]\w*)\s*\(", flags=re.IGNORECASE | re.DOTALL)
    seen: List[str] = []
    for m in pattern.finditer(text):
        # extract the module type (first group)
        name = m.group(1)
        if name.lower() in {"module", "assign", "if", "for", "while", "generate", "begin", "end", "function", "task", "interface", "endmodule"}:
            continue
        if name not in seen:
            seen.append(name)
    return seen


def parse_file(path: str) -> Dict[str, Any]:
    """Parse a .v file and return dict with parsed_file, top_module_name, internal_subnames, and optionally interface.

    Raises FileNotFoundError if not exists; ValueError for unsupported format or read errors.
    """
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    if not path.lower().endswith(".v"):
        raise ValueError("unsupported_format")
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            raw = f.read()
    except Exception:
        raise ValueError("read_error")
    if not raw:
        raise ValueError("read_error")

    cleaned = remove_comments(raw)
    top_name, start, end = find_top_module_and_span(cleaned)

    submodules = []
    interface = None
    if top_name is not None and start is not None and end is not None:
        # extract text inside top module body
        body = cleaned[start:end]
        submodules = extract_instantiated_submodules(body)
        # remove top module name from submodules if appears
        submodules = [s for s in submodules if s != top_name]
        # extract module port list and parse into interface (inputs / output / reset)
        port_list_str = _extract_port_list_string(cleaned, start, end)
        if port_list_str:
            interface = _parse_port_list(port_list_str)

    result: Dict[str, Any] = {
        "parsed_file": os.path.abspath(path),
        "top_module_name": top_name,
        "internal_subnames": submodules,
    }
    if interface is not None:
        result["interface"] = interface
    return result
