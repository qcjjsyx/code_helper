import re
from pathlib import Path


def strip_comments(text: str) -> str:
    text = re.sub(r"\(\*.*?\*\)", "", text, flags=re.S)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"//.*", "", text)
    return text


def parse_module_header(text: str):
    match = re.search(
        r"\bmodule\s+([A-Za-z_]\w*)\s*(?:#\s*\((?P<params>.*?)\)\s*)?\((?P<ports>.*?)\)\s*;",
        text,
        re.S,
    )
    if not match:
        return None, "", ""
    return match.group(1), match.group("params") or "", match.group("ports") or ""


def parse_params(text: str):
    params = []
    seen = set()
    for match in re.finditer(
        r"\b(localparam|parameter)\b\s+([A-Za-z_]\w*)\s*=\s*([^,;\n\)]+)",
        text,
    ):
        name = match.group(2)
        if name in seen:
            continue
        seen.add(name)
        default_text = match.group(3).strip()
        params.append({"name": name, "default_text": default_text})
    return params


def _parse_port_segment(direction: str, segment: str):
    width_match = re.search(r"\[[^\]]+\]", segment)
    width = _normalize_width(width_match.group(0).strip() if width_match else None)
    cleaned = segment
    if width_match:
        cleaned = cleaned.replace(width_match.group(0), " ")
    cleaned = re.sub(
        r"\b(?:wire|reg|logic|signed|unsigned|tri|integer)\b", " ", cleaned
    )
    cleaned = cleaned.replace(")", " ").replace(";", " ")
    names = [name.strip() for name in cleaned.split(",") if name.strip()]
    return [
        {"name": name, "direction": direction, "width_text_or_null": width}
        for name in names
    ]


def _normalize_width(width_text):
    if not width_text:
        return "1"
    inner = width_text[1:-1].strip()
    match = re.match(r"^([A-Za-z_]\w*)\s*-\s*1\s*:\s*0$", inner)
    if match:
        return match.group(1)
    return width_text


def parse_ports_from_header(port_text: str):
    ports = []
    if not port_text:
        return ports
    flat = " ".join(port_text.replace("\n", " ").split())
    matches = list(re.finditer(r"\b(input|output|inout)\b", flat))
    for idx, match in enumerate(matches):
        direction = match.group(1)
        start = match.end()
        end = matches[idx + 1].start() if idx + 1 < len(matches) else len(flat)
        segment = flat[start:end]
        ports.extend(_parse_port_segment(direction, segment))
    return _dedupe_ports(ports)


def parse_ports_from_body(text: str):
    ports = []
    for match in re.finditer(r"\b(input|output|inout)\b\s+([^;]+);", text, re.S):
        direction = match.group(1)
        segment = match.group(2)
        ports.extend(_parse_port_segment(direction, segment))
    return _dedupe_ports(ports)


def parse_instantiations(text: str):
    insts = []
    keywords = {
        "module",
        "assign",
        "always",
        "if",
        "else",
        "for",
        "case",
        "endcase",
        "begin",
        "end",
        "generate",
        "endgenerate",
        "wire",
        "reg",
        "localparam",
        "parameter",
        "input",
        "output",
        "inout",
    }
    pattern = re.compile(
        r"(?m)^\s*([A-Za-z_]\w*)\s*(?:#\s*\((?:[^()]*|\([^()]*\))*\)\s*)?([A-Za-z_]\w*)\s*\("
    )
    for match in pattern.finditer(text):
        module_name = match.group(1)
        if module_name in keywords:
            continue
        insts.append(module_name)
    return _dedupe_list(insts)


def extract_customization_guide(raw_text: str) -> str:
    lines = raw_text.splitlines()
    header_lines = []
    for line in lines:
        if re.search(r"\bmodule\b", line):
            break
        header_lines.append(line)

    cleaned = []
    for line in header_lines:
        stripped = line.strip()
        if stripped.startswith("//"):
            stripped = stripped[2:].strip()
        elif stripped.startswith("/*"):
            stripped = stripped[2:].strip()
        if stripped.endswith("*/"):
            stripped = stripped[:-2].strip()
        if stripped.startswith("*"):
            stripped = stripped[1:].strip()
        cleaned.append(stripped)

    start = None
    for idx, line in enumerate(cleaned):
        if re.search(r"Instantiation|Modification", line, re.I):
            start = idx
            break
    if start is None:
        return ""

    guide_lines = []
    for line in cleaned[start:]:
        if not line:
            continue
        if "====" in line:
            continue
        guide_lines.append(line)
    return "\n".join(guide_lines).strip()


def parse_verilog_file(path: Path):
    errors = []
    raw = path.read_text(encoding="utf-8", errors="ignore")
    cleaned = strip_comments(raw)

    name, _, port_text = parse_module_header(cleaned)
    if not name:
        errors.append("module name not found")

    params = parse_params(cleaned)
    ports = parse_ports_from_header(port_text)
    if not ports:
        ports = parse_ports_from_body(cleaned)

    instantiations = parse_instantiations(cleaned)
    customization_guide = extract_customization_guide(raw)

    return {
        "name": name or "",
        "params": params,
        "ports": ports,
        "instantiations": instantiations,
        "customization_guide": customization_guide,
        "errors": errors,
    }


def _dedupe_list(items):
    seen = set()
    result = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def _dedupe_ports(ports):
    seen = set()
    result = []
    for port in ports:
        key = (port["name"], port["direction"], port["width_text_or_null"])
        if key in seen:
            continue
        seen.add(key)
        result.append(port)
    return result
