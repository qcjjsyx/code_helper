"""Parse predefined CPU top-level .v files and save JSON outputs.

Usage: python -m parser.verilog.run_top_parsing
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from .parser import parse_file


def main() -> int:
    base = Path(__file__).resolve().parent.parent
    targets = [
        base / "test_data" / "cpu" / "CPUwithCache.v",
        base / "test_data" / "cpu" / "CPU" / "cpu_top.v",
        base / "test_data" / "cpu" / "Exe" / "exe_top.v",
        base / "test_data" / "cpu" / "Fetch" / "Fetch_top.v",
        base / "test_data" / "cpu" / "IDU" / "idu_top.v",
        base / "test_data" / "cpu" / "LSU" / "lsu_top.v",
        base / "test_data" / "cpu" / "mem_slot" / "mem_slot.v",
        base / "test_data" / "cpu" / "WB" / "writeBack.v",
    ]

    out_dir = base / "artifacts" / "verilog_parser_outputs"
    out_dir.mkdir(parents=True, exist_ok=True)

    any_error = False
    for t in targets:
        if not t.exists():
            print(f"未找到文件：{t}", file=sys.stderr)
            any_error = True
            continue
        try:
            result = parse_file(str(t))
        except FileNotFoundError:
            print(f"Error: 文件不存在 - {t}", file=sys.stderr)
            any_error = True
            continue
        except ValueError as e:
            if str(e) == "unsupported_format":
                print(f"Error: 仅支持.v格式文件 - {t}", file=sys.stderr)
            else:
                print(f"Error: 文件读取失败 - {t}", file=sys.stderr)
            any_error = True
            continue
        except Exception as e:
            print(f"解析失败：{t} -> {e}", file=sys.stderr)
            any_error = True
            continue

        out_path = out_dir / (t.name + ".json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"已写入：{out_path}")

    return 1 if any_error else 0


if __name__ == "__main__":
    raise SystemExit(main())
