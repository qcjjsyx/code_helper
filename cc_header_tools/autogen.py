from pathlib import Path

from .parser import (
    extract_cc_block,
    infer_family,
    parse_module_header,
    parse_ports,
    strip_comments_keep_cc,
)


def build_header(module_name: str, family: str, ports, add_family_note: bool):
    port_list = ", ".join(sorted({p["name"] for p in ports}))
    lines = []
    lines.append("schema: cc_header_v1")
    lines.append(f"name: {module_name or 'TODO: set module name'}")
    lines.append(f"family: {family}")
    if add_family_note:
        lines.append("note: TODO set family")
    lines.append("params:")
    lines.append("  NUM_PORTS: TODO")
    lines.append("roles:")
    lines.append(f"  TODO: fill roles; ports: {port_list}")
    # lines.append("  inputs: []")
    # lines.append("  outputs: []")
    lines.append("  upstream: []")
    lines.append("  downstream: []")
    lines.append("contract:")
    if family == "ArbMergeN":
        lines.append("  arb_policy: TODO")
    elif family == "MutexMergeN":
        lines.append("  mutex_model: TODO")
    else:
        lines.append("  TODO: fill contract")
    return "\n".join(f"//@cc: {line}" for line in lines) + "\n"


def insert_header(text: str, header_block: str) -> str:
    lines = text.splitlines(keepends=True)
    for idx, line in enumerate(lines):
        if "module" in line:
            return "".join(lines[:idx]) + header_block + "\n" + "".join(lines[idx:])
    return header_block + "\n" + text


def autogen_for_file(path: Path, inplace: bool, only_missing: bool):
    text = path.read_text(encoding="utf-8", errors="ignore")
    cc_text, _ = extract_cc_block(text)
    ### 
    if cc_text:
        if only_missing:
            return False, "exists"
        return False, "exists"

    stripped = strip_comments_keep_cc(text)
    module_name, port_text = parse_module_header(stripped)
    ports = parse_ports(port_text)
    family = infer_family(module_name or "", path.name)
    add_family_note = family == "unknown"
    header = build_header(module_name, family, ports, add_family_note) # type: ignore
    updated = insert_header(text, header)
    if inplace:
        path.write_text(updated, encoding="utf-8")
    else:
        return True, updated
    return True, None
