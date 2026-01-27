def render_components_md(kb: dict) -> str:
    entries = kb.get("entries", [])
    groups = {}
    for entry in entries:
        group = entry.get("component_type") or "unknown"
        groups.setdefault(group, []).append(entry)

    lines = ["# Components"]
    for group_name in sorted(groups.keys()):
        lines.append("")
        lines.append(f"## {group_name}")
        for entry in sorted(groups[group_name], key=lambda e: e.get("name", "")):
            lines.append("")
            lines.append(f"### {entry.get('name', '')}")
            lines.append(f"- file: {entry.get('file', '')}")
            lines.append(f"- params: {format_params(entry.get('params', []))}")
            lines.append(f"- ports: {format_ports(entry.get('ports', []))}")

            deps = entry.get("deps", {})
            lines.append(
                "- deps: components={components} primitives={primitives} unresolved={unresolved}".format(
                    components=format_list(deps.get("components", [])),
                    primitives=format_list(deps.get("primitives", [])),
                    unresolved=format_list(deps.get("unresolved", [])),
                )
            )

            contract = entry.get("contract", {})
            outputs = contract.get("outputs", {})
            lines.append(
                "- contract: inputs={inputs} outputs=driveNext:{drive_next}, data:{data}, free:{free}, freeNext:{free_next}".format(
                    inputs=format_inputs(contract.get("inputs", [])),
                    drive_next=outputs.get("driveNext_port"),
                    data=outputs.get("data_port"),
                    free=outputs.get("free_port"),
                    free_next=outputs.get("freeNext_port"),
                )
            )

            arbitration = contract.get("arbitration_policy")
            selection = contract.get("selection_encoding")
            join = contract.get("join_condition")
            if arbitration or selection or join:
                lines.append(
                    "- policy: arbitration={arb} selection={sel} join={join}".format(
                        arb=arbitration, sel=selection, join=join
                    )
                )

            guide = entry.get("customization_guide") or ""
            if guide:
                lines.append("- customization_guide:")
                lines.append("```")
                lines.append(guide)
                lines.append("```")

    lines.append("")
    return "\n".join(lines)


def format_params(params):
    if not params:
        return "(none)"
    parts = []
    for param in params:
        name = param.get("name", "")
        default = param.get("default_text")
        parts.append(f"{name}={default}" if default is not None else name)
    return ", ".join(parts)


def format_ports(ports):
    if not ports:
        return "(none)"
    parts = []
    for port in ports:
        direction = port.get("direction", "unknown")
        name = port.get("name", "")
        width = port.get("width_text_or_null")
        if width:
            parts.append(f"{direction} {name} {width}")
        else:
            parts.append(f"{direction} {name}")
    return ", ".join(parts)


def format_list(items):
    return "[" + ", ".join(items) + "]"


def format_inputs(inputs):
    if not inputs:
        return "[]"
    parts = []
    for item in inputs:
        parts.append(
            "idx{idx}:drive={drive},data={data},free={free}".format(
                idx=item.get("index"),
                drive=item.get("drive_port"),
                data=item.get("data_port"),
                free=item.get("free_port"),
            )
        )
    return "[" + "; ".join(parts) + "]"
