"""CLI entrypoint for parser.pipeline."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys
from typing import Optional

from .hierarchy_builder import build_project
from .result_writer import write_results


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(prog="parser.pipeline")
    subparsers = parser.add_subparsers(dest="command", required=True)

    build_parser = subparsers.add_parser("build", help="Build module/component JSON artifacts")
    build_parser.add_argument("--inputs", required=True, help="RTL project directory containing read_rtl_list.tcl and rtl_top_list.tcl")
    build_parser.add_argument("--output", default="artifacts/parser_pipeline_result")

    args = parser.parse_args(argv)
    repo_root = Path.cwd().resolve()

    if args.command == "build":
        output_dir = Path(args.output)
        if not output_dir.is_absolute():
            output_dir = repo_root / output_dir
        try:
            result = build_project(repo_root, args.inputs, output_dir)
        except (FileNotFoundError, NotADirectoryError) as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1
        write_results(output_dir, result)
        return 0
    return 1
