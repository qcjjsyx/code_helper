"""CLI for parser.verilog."""
from __future__ import annotations

import argparse
import json
import sys
from typing import Optional

from .parser import parse_file


def format_text(result: dict) -> str:
    lines = []
    lines.append(f"解析文件：{result['parsed_file']}")
    top = result.get("top_module_name")
    lines.append(f"顶层module名称：{top if top else '未识别到顶层module'}")
    subs = result.get("internal_subnames", [])
    if subs:
        lines.append(f"内部结构子名称（共{len(subs)}个）：")
        for i, s in enumerate(subs, start=1):
            lines.append(f"  {i}. {s}")
    else:
        lines.append("无内部结构子名称")
    return "\n".join(lines)


def main(argv: Optional[list] = None) -> int:
    parser = argparse.ArgumentParser(prog="parser.verilog")
    subparsers = parser.add_subparsers(dest="cmd")

    p = subparsers.add_parser("parse")
    p.add_argument("--file", required=True, help="Verilog .v 文件路径")
    p.add_argument("--output", default=None, help="输出文件路径（不指定则stdout）")
    p.add_argument("--format", choices=["json", "text"], default="json")

    args = parser.parse_args(argv)
    if args.cmd != "parse":
        parser.print_help()
        return 0

    path = args.file
    try:
        result = parse_file(path)
    except FileNotFoundError:
        print(f"Error: 文件不存在 - {path}", file=sys.stderr)
        return 1
    except ValueError as e:
        if str(e) == "unsupported_format":
            print(f"Error: 仅支持.v格式文件 - {path}", file=sys.stderr)
            return 2
        if str(e) == "read_error":
            print(f"Error: 文件读取失败 - {path}", file=sys.stderr)
            return 3
        print(f"Error: {e}", file=sys.stderr)
        return 3

    if args.format == "json":
        out = json.dumps(result, ensure_ascii=False, indent=2)
    else:
        out = format_text(result)

    if args.output:
        try:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(out)
        except Exception as e:
            print(f"Error: 写入文件失败 - {e}", file=sys.stderr)
            return 3
    else:
        print(out)

    return 0
