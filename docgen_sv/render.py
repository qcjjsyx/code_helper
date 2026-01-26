from __future__ import annotations

from pathlib import Path


def render_registry_markdown(registry: dict, docs_path: Path) -> None:
    entries = registry.get("entries", [])
    categories: dict[str, list[dict]] = {}
    for entry in entries:
        category = entry.get("category", "unknown")
        categories.setdefault(category, []).append(entry)

    lines = ["# Primitives & Components", ""]
    for category in sorted(categories):
        lines.append(f"## {category}")
        lines.append("")
        for entry in sorted(categories[category], key=lambda item: item["name"]):
            status = " **(deleted)**" if entry.get("deleted") else ""
            lines.append(f"### {entry['name']}{status}")
            lines.append(f"- kind: `{entry['kind']}`")
            lines.append(f"- file: `{entry['file']}`")
            lines.append("- ports:")
            for port in entry.get("ports", []):
                width = port.get("width") or "null"
                lines.append(
                    f"  - `{port['name']}` ({port.get('direction', 'unknown')}, {width})"
                )
            lines.append("- deps_primitives:")
            for dep in entry.get("deps_primitives", []):
                lines.append(f"  - `{dep}`")
            lines.append("- tech_cells:")
            for cell in entry.get("tech_cells", []):
                lines.append(f"  - `{cell}`")
            reset = entry.get("reset", {})
            lines.append(
                "- reset: "
                f"present={reset.get('present')}, "
                f"signal={reset.get('signal')}, "
                f"active_low={reset.get('active_low')}"
            )
            if entry.get("semantics_1line"):
                lines.append(f"- semantics: {entry['semantics_1line']}")
            lines.append("")

    docs_path.parent.mkdir(parents=True, exist_ok=True)
    docs_path.write_text("\n".join(lines).strip() + "\n", encoding="utf-8")
