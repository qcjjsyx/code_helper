from dataclasses import dataclass, field
from typing import List, Tuple

from .parser import FAMILIES, normalize_port_ref, parse_ports, parse_yaml_min, strip_comments_keep_cc, extract_cc_block, parse_module_header


@dataclass
class LintResult:
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)

    def ok(self) -> bool:
        return not self.errors


def lint_text(text: str, strict: bool = False) -> LintResult:
    result = LintResult()
    cc_text, cc_lines = extract_cc_block(text)
    if not cc_text:
        result.errors.append("missing //@cc: header block")
        return result

    header = parse_yaml_min(cc_text)
    if not isinstance(header, dict):
        result.errors.append("header must be a mapping at top level")
        return result
    schema = header.get("schema")
    if schema != "cc_header_v1":
        result.errors.append("schema must be cc_header_v1")

    family = header.get("family") # type: ignore
    if family not in FAMILIES:
        result.errors.append("family must be one of: " + ", ".join(FAMILIES))

    stripped = strip_comments_keep_cc(text)
    module_name, port_text = parse_module_header(stripped)
    ports = parse_ports(port_text)
    port_names = {port["name"] for port in ports}

    roles = header.get("roles", {}) # type: ignore
    role_port_names = _collect_role_ports(roles)
    for role_port in role_port_names:
        base = normalize_port_ref(role_port)
        if base and base not in port_names:
            result.errors.append(f"role port '{role_port}' not found in module ports")

    contract = header.get("contract", {}) # type: ignore
    if family == "ArbMergeN":
        if not contract.get("arb_policy"):
            result.errors.append("ArbMergeN requires contract.arb_policy")
    if family == "MutexMergeN":
        if contract.get("mutex_model") != "environment_mutex_assumed":
            result.errors.append(
                "MutexMergeN requires contract.mutex_model=environment_mutex_assumed"
            )

    params = header.get("params", {}) # type: ignore
    num_ports = params.get("NUM_PORTS")
    if isinstance(num_ports, int):
        channels = roles.get("inputs") or roles.get("channels")
        if isinstance(channels, list) and len(channels) != num_ports:
            result.warnings.append(
                f"roles inputs/channels count {len(channels)} != NUM_PORTS {num_ports}"
            )

    if _contains_todo(header):
        msg = "header contains TODO"
        if strict:
            result.errors.append(msg)
        else:
            result.warnings.append(msg)

    if not module_name:
        result.errors.append("module name not found")

    return result


def _collect_role_ports(roles) -> List[str]:
    collected = []
    if isinstance(roles, dict):
        for key, value in roles.items():
            if key == "num_ports_semantics":
                continue
            collected.extend(_collect_role_ports(value))
    elif isinstance(roles, list):
        for item in roles:
            collected.extend(_collect_role_ports(item))
    elif isinstance(roles, str):
        if "TODO" not in roles:
            collected.append(roles)
    return collected


def _contains_todo(value) -> bool:
    if isinstance(value, dict):
        return any(_contains_todo(v) for v in value.values())
    if isinstance(value, list):
        return any(_contains_todo(v) for v in value)
    if isinstance(value, str):
        return "TODO" in value
    return False
