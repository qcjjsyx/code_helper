from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


PORT_DIR_RE = re.compile(r"\b(input|output|inout)\b") ## 匹配端口方向
WIDTH_RE = re.compile(r"(\[[^\]]+\])") ## 匹配位宽
MODULE_RE = re.compile(r"\bmodule\s+([A-Za-z_][\w$]*)\b") ## 匹配模块名
PARAM_BLOCK_RE = re.compile(r"\b(parameter|localparam)\b([^;]*);", re.DOTALL) ## 匹配参数块
PARAM_ITEM_RE = re.compile(r"([A-Za-z_][\w$]*)\s*(?:=\s*([^,]+))?") ## 匹配单个参数项
INSTANCE_RE = re.compile(r"\b([A-Za-z_][\w$]*)\s+([A-Za-z_][\w$]*)\s*\(") ## 匹配模块实例化：模块类型名、实例名，以及左括号


@dataclass
class ParsedModule:
    name: str
    ports: list[dict]
    params: list[dict]
    instances: list[str]
    errors: list[str]


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_file_text(path: Path) -> str:
    data = path.read_bytes()
    return data.decode("utf-8", errors="ignore")


## Remove comments and string literals from the Verilog source code
def strip_comments_and_strings(text: str) -> str:
    text = re.sub(r"//.*?$", "", text, flags=re.MULTILINE)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r'"(?:\\.|[^"])*"', '""', text)
    return text


def extract_module_header(text: str) -> tuple[str | None, str | None, list[str]]:
    errors: list[str] = []
    match = MODULE_RE.search(text)
    if not match:
        return None, None, ["module name not found"]
    name = match.group(1)
    start = match.end()
    paren_start = text.find("(", start)
    if paren_start == -1:
        return name, None, ["module ports not found"]
    depth = 0
    for idx in range(paren_start, len(text)):
        if text[idx] == "(":
            depth += 1
        elif text[idx] == ")":
            depth -= 1
            if depth == 0:
                header = text[paren_start + 1 : idx]
                return name, header, errors
    return name, None, ["module port list not terminated"]


def parse_ports(port_block: str) -> list[dict]:
    ports: list[dict] = []
    if not port_block:
        return ports
    parts: list[str] = []
    current = ""
    depth = 0
    for char in port_block:
        if char in "([{" :
            depth += 1
        elif char in ")]}":
            depth = max(depth - 1, 0)
        if char == "," and depth == 0:
            parts.append(current)
            current = ""
        else:
            current += char
    if current.strip():
        parts.append(current)
    for part in parts:
        segment = part.strip()
        if not segment:
            continue
        direction_match = PORT_DIR_RE.search(segment)
        direction = direction_match.group(1) if direction_match else "unknown"
        width_match = WIDTH_RE.search(segment)
        width = width_match.group(1) if width_match else None
        segment = re.sub(r"=.*", "", segment)
        tokens = re.findall(r"[A-Za-z_][\w$]*", segment)
        name = tokens[-1] if tokens else segment.strip()
        ports.append({"name": name, "direction": direction, "width": width})
    return ports


def parse_port_declarations(text: str) -> dict[str, dict[str, str | None]]:
    decls: dict[str, dict[str, str | None]] = {}
    decl_block_re = re.compile(r"\b(input|output|inout)\b([^;]*);", re.DOTALL)
    for match in decl_block_re.finditer(text):
        direction = match.group(1)
        block = match.group(2)
        shared_width_match = WIDTH_RE.search(block)
        shared_width = shared_width_match.group(1) if shared_width_match else None
        parts: list[str] = []
        current = ""
        depth = 0
        for char in block:
            if char in "([{" :
                depth += 1
            elif char in ")]}":
                depth = max(depth - 1, 0)
            if char == "," and depth == 0:
                parts.append(current)
                current = ""
            else:
                current += char
        if current.strip():
            parts.append(current)
        for part in parts:
            segment = part.strip()
            if not segment:
                continue
            width_match = WIDTH_RE.search(segment)
            width = width_match.group(1) if width_match else shared_width
            tokens = re.findall(r"[A-Za-z_][\w$]*", segment)
            if not tokens:
                continue
            name = tokens[-1]
            decls[name] = {"direction": direction, "width": width}
    return decls


def parse_params(text: str) -> list[dict]:
    params: list[dict] = []
    for match in PARAM_BLOCK_RE.finditer(text):
        block = match.group(2)
        for item in block.split(","):
            item = item.strip()
            if not item:
                continue
            item_match = PARAM_ITEM_RE.search(item)
            if not item_match:
                continue
            name = item_match.group(1)
            default = item_match.group(2).strip() if item_match.group(2) else None
            params.append({"name": name, "default": default})
    return params


def parse_instances(text: str) -> list[str]:
    instances = []
    for match in INSTANCE_RE.finditer(text):
        module_name = match.group(1)
        if module_name in {"module", "if", "for", "case"}:
            continue
        instances.append(module_name)
    return instances


def parse_verilog(path: Path) -> ParsedModule:
    errors: list[str] = []
    raw_text = read_file_text(path)
    cleaned = strip_comments_and_strings(raw_text)
    name, port_block, header_errors = extract_module_header(cleaned)
    errors.extend(header_errors)
    ports = parse_ports(port_block or "")
    decls = parse_port_declarations(cleaned)
    if ports:
        for port in ports:
            decl = decls.get(port["name"])
            if not decl:
                continue
            if port["direction"] == "unknown":
                port["direction"] = decl["direction"]
            if port["width"] is None:
                port["width"] = decl["width"]
    else:
        for name, decl in decls.items():
            ports.append({"name": name, "direction": decl["direction"], "width": decl["width"]})
    params = parse_params(cleaned)
    instances = parse_instances(cleaned)
    if not name:
        name = path.stem
    return ParsedModule(name=name, ports=ports, params=params, instances=instances, errors=errors)


def scan_verilog_files(paths: Iterable[Path]) -> list[Path]:
    results: list[Path] = []
    for path in paths:
        if path.is_dir():
            for file in path.rglob("*.v"):
                results.append(file)
        elif path.is_file() and path.suffix == ".v":
            results.append(path)
    return results
