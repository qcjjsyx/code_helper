from pathlib import Path

from .parser import (
    extract_cc_block,
    infer_cc_identity,
    parse_module_header,
    parse_ports,
    strip_comments_keep_cc,
)


def _port_names(ports):
    return {p["name"] for p in ports}


def _first_existing(candidates, port_names):
    for item in candidates:
        if item in port_names:
            return item
    return candidates[0] if candidates else ""


def _build_roles_and_params(identity, ports):
    family = identity["family"]
    num_ports = identity["num_ports"]
    port_names = _port_names(ports)

    params = {
        "DATA_WIDTH": "{TODO}",
        "DELAY": "{TODO}",
    }
    roles = {
        "upstream": [],
        "downstream": [],
        "fire": [],
    }
    contract = {}

    if family == "MutexMergeN":
        contract["mutex_model"] = "environment_mutex_assumed"
    elif family == "ArbMergeN":
        contract["arb_policy"] = "TODO"
    else:
        contract["TODO"] = "fill contract"

    if isinstance(num_ports, int):
        params["NUM_PORTS"] = num_ports # type: ignore
    elif family not in {"Fifo1", "PmtFifo", "PmtFifo1"}:
        params["NUM_PORTS"] = "TODO"

    if family in {"Fifo1", "PmtFifo", "PmtFifo1"}:
        roles["upstream"] = [_first_existing(["i_drive"], port_names)]
        roles["downstream"] = [_first_existing(["o_driveNext"], port_names)]
        fire_port = _first_existing(["o_fire", "o_fire_1"], port_names)
        if fire_port in port_names:
            roles["fire"] = [fire_port]

    return params, roles, contract


def _yaml_inline_list(items):
    return "[" + ", ".join(items) + "]"


def build_header(module_name: str, identity, ports):
    family = identity["family"]
    params, roles, contract = _build_roles_and_params(identity, ports)

    lines = [
        "schema: cc_header_v1",
        f"name: {module_name or 'TODO: set module name'}",
        f"family: {family}",
        "params:",
    ]

    if "NUM_PORTS" in params:
        lines.append(f"  NUM_PORTS: {params['NUM_PORTS']}")
    lines.append(f"  DATA_WIDTH: {params['DATA_WIDTH']}")
    lines.append(f"  DELAY: {params['DELAY']}")

    lines.extend(
        [
            "roles:",
            f"  upstream: {_yaml_inline_list(roles['upstream'])}",
            f"  downstream: {_yaml_inline_list(roles['downstream'])}",
            f"  fire: {_yaml_inline_list(roles['fire'])}",
        ]
    )
    lines.append("contract:")
    for key, value in contract.items():
        lines.append(f"  {key}: {value}")

    return "\n".join(f"//@cc: {line}" for line in lines) + "\n"


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
    identity = infer_cc_identity(path.name)
    header = build_header(module_name, identity, ports) # type: ignore
    updated = insert_header(text, header)
    if inplace:
        path.write_text(updated, encoding="utf-8")
    else:
        return True, updated
    return True, None
