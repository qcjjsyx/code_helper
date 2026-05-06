"""Verilog parser focused on module headers, signals, and instantiations."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from .flow_inference import extract_signal_terms, infer_signal_role


KEYWORDS = {
    "module",
    "endmodule",
    "assign",
    "always",
    "if",
    "else",
    "for",
    "while",
    "case",
    "endcase",
    "begin",
    "end",
    "generate",
    "endgenerate",
    "wire",
    "reg",
    "logic",
    "input",
    "output",
    "inout",
    "localparam",
    "parameter",
    "function",
    "task",
}


def strip_comments(text: str) -> str:
    text = re.sub(r"\(\*.*?\*\)", " ", text, flags=re.S)
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    text = re.sub(r"//.*", "", text)
    return text


def find_module_name(path: Path) -> str:
    text = path.read_text(encoding="utf-8", errors="ignore")
    cleaned = strip_comments(text)
    module_info = extract_module_header(cleaned)
    return module_info["name"]


## 读取一个 Verilog 文件并产出统一的结构化解析结果，包括模块名、参数、端口、局部信号、实例化等信息
def parse_verilog_file(path: Path) -> Dict[str, Any]:
    raw = path.read_text(encoding="utf-8", errors="ignore")
    cleaned = strip_comments(raw)
    module_info = extract_module_header(cleaned)
    body = module_info["body"]
    ports = parse_ports(module_info["ports_text"])
    if not ports:
        ports = parse_body_port_declarations(body, module_info["ports_text"])
    instances = parse_instantiations(body)
    local_signals = parse_local_signals(body)

    warnings: List[str] = []
    if not module_info["name"]:
        warnings.append("module name not found")

    return {
        "name": module_info["name"],
        "file": str(path),
        "params": parse_parameters(module_info["params_text"]),
        "ports": ports,
        "reset": derive_reset(ports),
        "local_signals": local_signals,
        "instances": instances,
        "warnings": warnings,
    }

## 把一个module文本拆成“名字 + 参数区 + 端口区 + 正文区”
def extract_module_header(text: str) -> Dict[str, str]:
    module_match = re.search(r"\bmodule\s+([A-Za-z_]\w*)", text)
    if not module_match:
        return {
            "name": "",
            "params_text": "",
            "ports_text": "",
            "body": text,
        }

    name = module_match.group(1)
    pos = module_match.end()
    pos = _skip_ws(text, pos)

    params_text = ""
    if pos < len(text) and text[pos] == "#":
        pos += 1
        pos = _skip_ws(text, pos)
        if pos < len(text) and text[pos] == "(":
            close = find_matching_paren(text, pos)
            params_text = text[pos + 1 : close]
            pos = close + 1

    pos = _skip_ws(text, pos)
    ports_text = ""
    if pos < len(text) and text[pos] == "(":
        close = find_matching_paren(text, pos)
        ports_text = text[pos + 1 : close]
        pos = close + 1

    semi = text.find(";", pos)
    body_start = semi + 1 if semi >= 0 else pos
    endmodule = re.search(r"\bendmodule\b", text[body_start:])
    body_end = body_start + endmodule.start() if endmodule else len(text)
    body = text[body_start:body_end]
    return {
        "name": name,
        "params_text": params_text,
        "ports_text": ports_text,
        "body": body,
    }


def find_matching_paren(text: str, open_pos: int) -> int:
    depth = 0
    for index in range(open_pos, len(text)):
        char = text[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return index
    return -1


def parse_parameters(params_text: str) -> List[Dict[str, Any]]:
    if not params_text.strip():
        return []

    params: List[Dict[str, Any]] = []
    seen = set()
    for segment in split_top_level(params_text):
        item = segment.strip()
        if not item:
            continue
        if "=" in item:
            left, right = item.split("=", 1)
            default_text = right.strip()
        else:
            left = item
            default_text = None
        left = re.sub(
            r"\b(localparam|parameter|integer|int|logic|wire|reg|signed|unsigned)\b",
            " ",
            left,
        )
        left = re.sub(r"\[[^\]]+\]", " ", left)
        match = re.search(r"([A-Za-z_]\w*)\s*$", left.strip())
        if not match:
            continue
        name = match.group(1)
        if name in seen:
            continue
        seen.add(name)
        params.append(
            {
                "name": name,
                "default_text": default_text,
            }
        )
    return params


def parse_ports(ports_text: str) -> List[Dict[str, Any]]:
    flat = " ".join(ports_text.replace("\n", " ").split())
    if not flat:
        return []

    matches = list(re.finditer(r"\b(input|output|inout)\b", flat))
    ports: List[Dict[str, Any]] = []
    for index, match in enumerate(matches):
        direction = match.group(1)
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(flat)
        ports.extend(_parse_port_segment(direction, flat[start:end]))
    return _dedupe_ports(ports)

## 检测非ANSI的端口，处理那些在module body里声明的端口，或者在ANSI端口列表里声明了名字但没有声明方向的端口
def parse_body_port_declarations(body: str, ports_text: str = "") -> List[Dict[str, Any]]:
    declared_ports: List[Dict[str, Any]] = []
    for match in re.finditer(r"\b(input|output|inout)\b\s*(.*?);", body, re.S):
        direction = match.group(1)
        declared_ports.extend(_parse_port_segment(direction, match.group(2)))

    declared_ports = _dedupe_ports(declared_ports)
    header_order = _parse_header_port_names(ports_text)
    if not header_order:
        return declared_ports

    by_name = {port["name"]: port for port in declared_ports}
    ordered = [by_name[name] for name in header_order if name in by_name]
    ordered_names = {port["name"] for port in ordered}
    ordered.extend(port for port in declared_ports if port["name"] not in ordered_names)
    return ordered


def parse_local_signals(body: str) -> List[Dict[str, Any]]:
    signals: List[Dict[str, Any]] = []
    for match in re.finditer(r"\b(wire|reg|logic)\b\s*(.*?);", body, re.S):
        kind = match.group(1)
        segment = match.group(2).strip()
        width_match = re.search(r"\[[^\]]+\]", segment)
        width_text = width_match.group(0).strip() if width_match else "1"
        if width_match:
            segment = segment.replace(width_match.group(0), " ")
        segment = re.sub(r"\b(signed|unsigned)\b", " ", segment)
        for item in split_top_level(segment):
            name = item.strip()
            if not name:
                continue
            if "=" in name:
                name = name.split("=", 1)[0].strip()
            name = re.sub(r"\[[^\]]+\]", "", name).strip()
            if not re.fullmatch(r"[A-Za-z_]\w*", name):
                continue
            signals.append(
                {
                    "name": name,
                    "kind": kind,
                    "width_text": width_text,
                }
            )
    return _dedupe_named_items(signals)


def parse_instantiations(body: str) -> List[Dict[str, Any]]:
    instances: List[Dict[str, Any]] = []
    pattern = re.compile(r"(?m)^\s*([A-Za-z_]\w*)\b")
    cursor = 0

    while True:
        match = pattern.search(body, cursor)
        if not match:
            break
        module_type = match.group(1)
        cursor = match.end()
        if module_type in KEYWORDS:
            continue

        pos = _skip_ws(body, match.end())
        parameter_overrides: Dict[str, str] = {}
        if pos < len(body) and body[pos] == "#":
            pos += 1
            pos = _skip_ws(body, pos)
            if pos >= len(body) or body[pos] != "(":
                continue
            param_close = find_matching_paren(body, pos)
            if param_close < 0:
                continue
            parameter_overrides = parse_parameter_overrides(body[pos + 1 : param_close])
            pos = _skip_ws(body, param_close + 1)

        inst_match = re.match(r"([A-Za-z_]\w*)", body[pos:])
        if not inst_match:
            continue
        instance_name = inst_match.group(1)
        pos += inst_match.end()
        pos = _skip_ws(body, pos)
        if pos >= len(body) or body[pos] != "(":
            continue
        close = find_matching_paren(body, pos)
        if close < 0:
            continue
        connections_text = body[pos + 1 : close]
        end_pos = _skip_ws(body, close + 1)
        if end_pos >= len(body) or body[end_pos] != ";":
            continue

        connections = parse_named_connections(connections_text)
        instances.append(
            {
                "module_type": module_type,
                "instance_name": instance_name,
                "parameter_overrides": parameter_overrides,
                "connections": connections,
            }
        )
        cursor = end_pos + 1

    return instances


def parse_parameter_overrides(params_text: str) -> Dict[str, str]:
    overrides: Dict[str, str] = {}
    for index, segment in enumerate(split_top_level(params_text)):
        item = segment.strip()
        if not item:
            continue
        named_match = re.match(r"\.([A-Za-z_]\w*)\s*\((.*)\)$", item, re.S)
        if named_match:
            overrides[named_match.group(1)] = named_match.group(2).strip()
        else:
            overrides[f"${index}"] = item
    return overrides


def parse_named_connections(connections_text: str) -> List[Dict[str, Any]]:
    connections: List[Dict[str, Any]] = []
    for segment in split_top_level(connections_text):
        item = segment.strip()
        if not item:
            continue
        match = re.match(r"\.([A-Za-z_]\w*)\s*\((.*)\)$", item, re.S)
        if not match:
            continue
        port_name = match.group(1)
        signal = match.group(2).strip()
        connection = {
            "port": port_name,
            "signal": signal,
            "port_direction": "unknown",
            "signal_role": infer_signal_role(signal),
        }
        signal_terms = extract_signal_terms(signal)
        if signal_terms and signal_terms != [signal]:
            connection["signal_terms"] = signal_terms
        connections.append(connection)
    return connections


def derive_reset(ports: List[Dict[str, Any]]) -> Dict[str, Any]:
    for port in ports:
        lowered = port["name"].lower()
        if lowered in {"rstn", "rst_n", "reset_n"}:
            return {"reset_port": port["name"], "reset_active_low": True}
        if lowered in {"rst", "reset"}:
            return {"reset_port": port["name"], "reset_active_low": False}
    return {"reset_port": None, "reset_active_low": False}


def split_top_level(text: str) -> List[str]:
    if not text:
        return []
    items: List[str] = []
    depth_paren = 0
    depth_brace = 0
    depth_bracket = 0
    current: List[str] = []
    for char in text:
        if char == "," and depth_paren == 0 and depth_brace == 0 and depth_bracket == 0:
            items.append("".join(current))
            current = []
            continue
        current.append(char)
        if char == "(":
            depth_paren += 1
        elif char == ")":
            depth_paren -= 1
        elif char == "{":
            depth_brace += 1
        elif char == "}":
            depth_brace -= 1
        elif char == "[":
            depth_bracket += 1
        elif char == "]":
            depth_bracket -= 1
    if current:
        items.append("".join(current))
    return items


def _parse_port_segment(direction: str, segment: str) -> List[Dict[str, Any]]:
    width_match = re.search(r"\[[^\]]+\]", segment)
    width_text = width_match.group(0).strip() if width_match else "1"
    cleaned = segment
    if width_match:
        cleaned = cleaned.replace(width_match.group(0), " ")
    cleaned = re.sub(r"\b(?:wire|reg|logic|signed|unsigned|tri)\b", " ", cleaned)
    cleaned = cleaned.replace(")", " ").replace(";", " ")
    names = [name.strip() for name in cleaned.split(",") if name.strip()]
    ports: List[Dict[str, Any]] = []
    for name in names:
        token_match = re.search(r"([A-Za-z_]\w*)$", name)
        if not token_match:
            continue
        ports.append(
            {
                "name": token_match.group(1),
                "direction": direction,
                "width_text": width_text,
            }
        )
    return ports


def _parse_header_port_names(ports_text: str) -> List[str]:
    names: List[str] = []
    for item in split_top_level(ports_text):
        cleaned = item.strip()
        if not cleaned:
            continue
        cleaned = re.sub(r"\b(input|output|inout|wire|reg|logic|signed|unsigned|tri)\b", " ", cleaned)
        cleaned = re.sub(r"\[[^\]]+\]", " ", cleaned)
        match = re.search(r"([A-Za-z_]\w*)\s*$", cleaned)
        if match:
            names.append(match.group(1))
    return names


def _dedupe_ports(ports: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    seen = set()
    deduped: List[Dict[str, Any]] = []
    for port in ports:
        key = (port["name"], port["direction"], port.get("width_text"))
        if key in seen:
            continue
        seen.add(key)
        deduped.append(port)
    return deduped


def _dedupe_named_items(items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    seen = set()
    deduped: List[Dict[str, Any]] = []
    for item in items:
        key = item["name"]
        if key in seen:
            continue
        seen.add(key)
        deduped.append(item)
    return deduped


def _skip_ws(text: str, pos: int) -> int:
    while pos < len(text) and text[pos].isspace():
        pos += 1
    return pos
