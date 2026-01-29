import re
from pathlib import Path


FAMILIES = [
    "SelSplit",
    "NatSplitN",
    "WaitMergeN",
    "ArbMergeN",
    "MutexMergeN",
    "Fifo1",
    "PmtFifo1",
]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def extract_cc_block(text: str):
    lines = text.splitlines()
    block = []
    in_block = False
    for line in lines:
        if line.lstrip().startswith("//@cc:"):
            in_block = True
            content = line.split("//@cc:", 1)[1]
            block.append(content.lstrip())
        else:
            if in_block:
                break
    if not block:
        return None, []
    return "\n".join(block).strip(), block


def strip_comments_keep_cc(text: str) -> str:
    lines = []
    for line in text.splitlines():
        if line.lstrip().startswith("//@cc:"):
            lines.append(line)
        else:
            lines.append(line)
    text = "\n".join(lines)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"//(?!@cc:).*", "", text)
    return text


def parse_module_header(text: str):
    match = re.search(
        r"\bmodule\s+([A-Za-z_]\w*)\s*(?:#\s*\((?P<params>.*?)\)\s*)?\((?P<ports>.*?)\)\s*;",
        text,
        re.S,
    )
    if not match:
        return None, ""
    return match.group(1), match.group("ports") or ""


def parse_ports(port_text: str):
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
    return _dedupe(ports)


def _parse_port_segment(direction: str, segment: str):
    width_match = re.search(r"\[[^\]]+\]", segment)
    cleaned = segment
    if width_match:
        cleaned = cleaned.replace(width_match.group(0), " ")
    cleaned = re.sub(r"\b(?:wire|reg|logic|signed|unsigned|tri|integer)\b", " ", cleaned)
    cleaned = cleaned.replace(")", " ").replace(";", " ")
    names = [name.strip() for name in cleaned.split(",") if name.strip()]
    return [{"name": name, "direction": direction} for name in names]


def parse_yaml_min(text: str):
    lines = [ln.rstrip("\n") for ln in text.splitlines() if ln.strip() != ""]
    idx = 0

    def parse_block(expected_indent: int):
        nonlocal idx
        obj = {}
        while idx < len(lines):
            line = lines[idx]
            indent = len(line) - len(line.lstrip(" "))
            if indent < expected_indent:
                break
            content = line.lstrip(" ")
            if content.startswith("- "):
                return parse_list(expected_indent)
            if ":" in content:
                key, rest = content.split(":", 1)
                key = key.strip()
                rest = rest.strip()
                idx += 1
                if rest == "":
                    if idx < len(lines):
                        next_line = lines[idx]
                        next_indent = len(next_line) - len(next_line.lstrip(" "))
                        if next_indent > indent and next_line.lstrip(" ").startswith("- "):
                            obj[key] = parse_list(indent + 2)
                            continue
                    obj[key] = parse_block(indent + 2)
                else:
                    obj[key] = _parse_value(rest)
            else:
                idx += 1
        return obj

    def parse_list(expected_indent: int):
        nonlocal idx
        lst = []
        while idx < len(lines):
            line = lines[idx]
            indent = len(line) - len(line.lstrip(" "))
            if indent < expected_indent:
                break
            content = line.lstrip(" ")
            if not content.startswith("- "):
                break
            item = content[2:].strip()
            idx += 1
            if item.endswith(":") and ":" not in item[:-1]:
                key = item[:-1].strip()
                value = parse_block(indent + 2)
                lst.append({key: value})
            else:
                lst.append(_parse_value(item))
        return lst

    return parse_block(0)


def _parse_value(value: str):
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [item.strip() for item in inner.split(",")]
    if value.startswith("{") and value.endswith("}"):
        inner = value[1:-1].strip()
        if not inner:
            return {}
        pairs = inner.split(",")
        result = {}
        for pair in pairs:
            if ":" not in pair:
                continue
            k, v = pair.split(":", 1)
            result[k.strip()] = _parse_value(v.strip())
        return result
    if re.fullmatch(r"\d+", value):
        return int(value)
    return value


def _dedupe(items):
    seen = set()
    result = []
    for item in items:
        name = item["name"]
        if name in seen:
            continue
        seen.add(name)
        result.append(item)
    return result


def normalize_port_ref(name: str) -> str:
    name = name.strip()
    match = re.match(r"^([A-Za-z_]\w*)", name)
    return match.group(1) if match else name


def infer_family(module_name: str, file_name: str) -> str:
    candidates = [module_name or "", file_name or ""]
    for cand in candidates:
        if "SelSplit" in cand:
            return "SelSplit"
        if "NatSplit" in cand:
            return "NatSplitN"
        if "WaitMerge" in cand:
            return "WaitMergeN"
        if "ArbMerge" in cand:
            return "ArbMergeN"
        if "MutexMerge" in cand:
            return "MutexMergeN"
        if "PmtFifo" in cand:
            return "PmtFifo1"
        if "Fifo" in cand:
            return "Fifo1"
    return "unknown"
