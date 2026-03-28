"""CLI entrypoint for parser_pipeline."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Optional

from .hierarchy_builder import build_project
from .result_writer import write_results


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(prog="parser_pipeline")
    subparsers = parser.add_subparsers(dest="command", required=True)

    build_parser = subparsers.add_parser("build", help="Build module/component JSON artifacts")
    build_parser.add_argument("--repo", required=True)
    build_parser.add_argument("--inputs", nargs="+", required=True)
    build_parser.add_argument("--tops", nargs="+", required=True)
    build_parser.add_argument("--output", default="parser_pipeline_result")

    args = parser.parse_args(argv)
    repo_root = Path(args.repo).resolve()

    if args.command == "build":
        output_dir = repo_root / args.output
        result = build_project(repo_root, args.inputs, args.tops, output_dir)
        write_results(output_dir, result)
        return 0
    return 1
