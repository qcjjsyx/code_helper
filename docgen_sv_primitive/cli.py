from __future__ import annotations

import argparse
from pathlib import Path

from docgen_sv_primitive.registry import generate_registry, load_registry, update_registry
from docgen_sv_primitive.render import render_registry_markdown


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Primitive Registry Builder")
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser("init", help="Scan inputs and build registry")
    init_parser.add_argument("--repo", required=True, help="Repo root path")
    init_parser.add_argument("--inputs", nargs="+", required=True, help="Input files or dirs")
    init_parser.add_argument(
        "--force",
        action="store_true",
        help="Rebuild entries even when file hashes are unchanged",
    )

    update_parser = subparsers.add_parser("update", help="Update registry for changed files")
    update_parser.add_argument("--repo", required=True, help="Repo root path")
    update_parser.add_argument("changed_files", nargs="+", help="Changed file paths")
    update_parser.add_argument(
        "--force",
        action="store_true",
        help="Rebuild entries even when file hashes are unchanged",
    )

    render_parser = subparsers.add_parser("render", help="Render docs from registry")
    render_parser.add_argument("--repo", required=True, help="Repo root path")

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    repo_root = Path(args.repo).resolve()
    if args.command == "init":
        inputs = [Path(item).resolve() for item in args.inputs]
        registry = generate_registry(repo_root, inputs, force=args.force)
    elif args.command == "update":
        changed_files = [Path(item).resolve() for item in args.changed_files]
        registry = update_registry(repo_root, changed_files, force=args.force)
    else:
        registry_path = repo_root / ".docgen" / "primitive_registry.json"
        registry = load_registry(registry_path)
    docs_path = repo_root / "docs" / "PRIMITIVES.md"
    render_registry_markdown(registry, docs_path)


if __name__ == "__main__":
    main()
