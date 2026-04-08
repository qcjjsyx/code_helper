import argparse
from pathlib import Path

from .kb import init_repo, update_repo, render_repo


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Component Knowledge Base Builder for selected Verilog components."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser("init", help="Initialize component KB.")
    init_parser.add_argument("--repo", required=True, help="Repository root.")
    init_parser.add_argument(
        "--inputs",
        nargs="+",
        required=True,
        help="Directories or files to scan for component sources.",
    )
    init_parser.add_argument(
        "--force",
        action="store_true",
        help="Rebuild entries even when file hashes are unchanged.",
    )

    update_parser = subparsers.add_parser("update", help="Update component KB.")
    update_parser.add_argument("--repo", required=True, help="Repository root.")
    update_parser.add_argument(
        "changed_files",
        nargs="+",
        help="Changed files or directories to update.",
    )
    update_parser.add_argument(
        "--force",
        action="store_true",
        help="Rebuild entries even when file hashes are unchanged.",
    )

    render_parser = subparsers.add_parser("render", help="Render COMPONENTS.md.")
    render_parser.add_argument("--repo", required=True, help="Repository root.")

    args = parser.parse_args(argv)
    repo_root = Path(args.repo).resolve()

    if args.command == "init":
        init_repo(repo_root, args.inputs, force=args.force)
        return 0
    if args.command == "update":
        update_repo(repo_root, args.changed_files, force=args.force)
        return 0
    if args.command == "render":
        render_repo(repo_root)
        return 0

    return 1
