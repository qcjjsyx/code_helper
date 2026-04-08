import argparse
import sys
from pathlib import Path

from .autogen import autogen_for_file, remove_all_cc_blocks
from .lint import lint_text
from .parser import FAMILIES, extract_cc_block, infer_cc_identity, read_text


def main(argv=None):
    parser = argparse.ArgumentParser(description="Control Component Header Tools")
    sub = parser.add_subparsers(dest="command", required=True)

    lint_p = sub.add_parser("lint", help="Lint //@cc: headers")
    lint_p.add_argument("--repo", required=True)
    lint_p.add_argument("--inputs", nargs="+", required=True)
    lint_p.add_argument("--strict", action="store_true")

    scan_p = sub.add_parser("scan", help="Scan files for header issues")
    scan_p.add_argument("--repo", required=True)
    scan_p.add_argument("--inputs", nargs="+", required=True)
    scan_p.add_argument("--strict", action="store_true")

    skel_p = sub.add_parser("skeleton", help="Insert header skeleton")
    skel_p.add_argument("--repo", required=True)
    skel_p.add_argument("--family", required=True, choices=FAMILIES)
    skel_p.add_argument("--file", required=True)
    skel_p.add_argument("--inplace", action="store_true")

    strip_p = sub.add_parser("strip", help="Remove //@cc: headers")
    strip_p.add_argument("--repo", required=True)
    strip_p.add_argument("--inputs", nargs="+", required=True)
    strip_p.add_argument("--inplace", action="store_true")

    auto_p = sub.add_parser("autogen", help="Auto-generate headers for files")
    auto_p.add_argument("--repo", required=True)
    auto_p.add_argument("--inputs", nargs="+", required=True)
    auto_p.add_argument("--inplace", action="store_true")
    auto_p.add_argument("--only-missing", action="store_true")
    auto_p.add_argument("--force", action="store_true")
    auto_p.add_argument("--strict", action="store_true")

    args = parser.parse_args(argv)
    repo_root = Path(args.repo).resolve()

    if args.command == "lint":
        return run_lint(repo_root, args.inputs, args.strict)
    if args.command == "scan":
        return run_scan(repo_root, args.inputs, args.strict)
    if args.command == "skeleton":
        return run_skeleton(repo_root, args.family, args.file, args.inplace)
    if args.command == "strip":
        return run_strip(repo_root, args.inputs, args.inplace)
    if args.command == "autogen":
        return run_autogen(
            repo_root,
            args.inputs,
            args.inplace,
            args.only_missing,
            args.force,
            args.strict,
        )
    return 1


def discover_files(repo_root: Path, inputs):
    files = []
    for item in inputs:
        path = Path(item)
        if not path.is_absolute():
            path = repo_root / path
        if path.is_dir():
            files.extend(sorted(path.rglob("*.v")))
            files.extend(sorted(path.rglob("*.sv")))
        elif path.is_file():
            files.append(path)
    return files


def run_lint(repo_root: Path, inputs, strict: bool):
    files = discover_files(repo_root, inputs)
    errors = 0
    for path in files:
        text = read_text(path)
        cc_text, _ = extract_cc_block(text)
        if not cc_text and infer_cc_identity(path.name)["family"] == "unknown":
            continue
        result = lint_text(text, strict=strict)
        if result.errors or result.warnings:
            for err in result.errors:
                print(f"{path}: ERROR: {err}")
            for warn in result.warnings:
                print(f"{path}: WARN: {warn}")
        if result.errors:
            errors += 1
    return 1 if errors else 0


def run_scan(repo_root: Path, inputs, strict: bool):
    files = discover_files(repo_root, inputs)
    bad = []
    for path in files:
        text = read_text(path)
        cc_text, _ = extract_cc_block(text)
        if not cc_text and infer_cc_identity(path.name)["family"] == "unknown":
            continue
        result = lint_text(text, strict=strict)
        if result.errors:
            bad.append(path)
    for path in bad:
        print(path)
    return 1 if bad else 0


def run_skeleton(repo_root: Path, family: str, file_path: str, inplace: bool):
    template_path = repo_root / "parser" / "families" / "cc_headers" / f"{family}.txt"
    if not template_path.exists():
        print(f"template not found: {template_path}")
        return 1
    template = template_path.read_text(encoding="utf-8")
    target = Path(file_path)
    if not target.is_absolute():
        target = repo_root / target
    original = target.read_text(encoding="utf-8", errors="ignore")
    if inplace:
        updated = _insert_header(original, template)
        target.write_text(updated, encoding="utf-8")
        return 0
    sys.stdout.write(_insert_header(original, template))
    return 0


def run_strip(repo_root: Path, inputs, inplace: bool):
    files = discover_files(repo_root, inputs)
    changed = 0
    for path in files:
        text = read_text(path)
        updated, removed_blocks = remove_all_cc_blocks(text)
        if removed_blocks == 0:
            continue
        changed += 1
        if inplace:
            path.write_text(updated, encoding="utf-8")
        else:
            sys.stdout.write(updated)
    return 0 if changed else 0


def run_autogen(
    repo_root: Path, inputs, inplace: bool, only_missing: bool, force: bool, strict: bool
):
    files = discover_files(repo_root, inputs)
    failed = 0
    for path in files:
        changed, output = autogen_for_file(path, inplace, only_missing, force)
        if output is not None:
            sys.stdout.write(output)
        if not inplace and changed:
            continue
        if inplace:
            text = path.read_text(encoding="utf-8", errors="ignore")
            cc_text, _ = extract_cc_block(text)
            if not cc_text:
                continue
            result = lint_text(text, strict)
            if result.errors:
                failed += 1
    return 1 if failed else 0


def _insert_header(text: str, header: str) -> str:
    lines = text.splitlines(keepends=True)
    for idx, line in enumerate(lines):
        if "module" in line:
            return "".join(lines[:idx]) + header + "\n" + "".join(lines[idx:])
    return header + "\n" + text
