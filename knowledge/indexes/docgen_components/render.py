def render_components_md(kb: dict) -> str:
    entries = kb.get("components", [])
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

            guide = entry.get("customization_guide") or {}
            sections = guide.get("sections", [])
            if sections and any(section.get("text") for section in sections):
                lines.append("- customization_guide:")
                lines.append("```")
                for section in sections:
                    title = section.get("title", "")
                    text = section.get("text", "")
                    if not text:
                        continue
                    lines.append(f"{title}:")
                    lines.append(text)
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
        width = port.get("width_text")
        type_text = port.get("type_text")
        segment = f"{direction} {name}"
        if width:
            segment = f"{segment} {width}"
        if type_text:
            segment = f"{segment} {type_text}"
        parts.append(segment)
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
