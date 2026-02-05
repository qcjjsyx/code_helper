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
    template_path = (
        Path(__file__).resolve().parents[1] / "templates" / "cc_headers" / "autogen.txt"
    )
    template = template_path.read_text(encoding="utf-8")
    family_note = "note: TODO set family\n" if add_family_note else ""
    if family == "ArbMergeN":
        contract_block = "  arb_policy: TODO"
    elif family == "MutexMergeN":
        contract_block = "  mutex_model: TODO"
    else:
        contract_block = "  TODO: fill contract"
    filled = template.format(
        module_name=module_name or "TODO: set module name",
        family=family,
        family_note=family_note,
        port_list=port_list,
        contract_block=contract_block,
    )
    return "\n".join(f"//@cc: {line}" for line in filled.splitlines()) + "\n"


def insert_header(text: str, header_block: str) -> str:
    lines = text.splitlines(keepends=True)
    for idx, line in enumerate(lines):
        if "module" in line:
            return "".join(lines[:idx]) + header_block + "\n" + "".join(lines[idx:])
    return header_block + "\n" + text


def remove_all_cc_blocks(text: str):
    lines = text.splitlines(keepends=True)
    kept = []
    idx = 0
    removed_blocks = 0
    while idx < len(lines):
        if lines[idx].lstrip().startswith("//@cc:"):
            removed_blocks += 1
            idx += 1
            while idx < len(lines) and lines[idx].lstrip().startswith("//@cc:"):
                idx += 1
            continue
        kept.append(lines[idx])
        idx += 1
    return "".join(kept), removed_blocks


def autogen_for_file(path: Path, inplace: bool, only_missing: bool, force: bool = False):
    text = path.read_text(encoding="utf-8", errors="ignore")
    cc_text, _ = extract_cc_block(text)
    ### 
    if cc_text:
        if not force:
            if only_missing:
                return False, "exists"
            return False, "exists"
        text, _ = remove_all_cc_blocks(text)

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
