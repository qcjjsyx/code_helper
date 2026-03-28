"""Discover module definitions under input roots."""

from __future__ import annotations

from pathlib import Path
from typing import Dict, Iterable, List, Set

from .module_parser import find_module_name


def build_module_index(repo_root: Path, inputs: Iterable[str], explicit_top_paths: Set[Path]) -> Dict[str, Path]:
    module_index: Dict[str, Path] = {}
    for file_path in discover_verilog_files(repo_root, inputs, explicit_top_paths):
        module_name = find_module_name(file_path)
        if module_name and module_name not in module_index:
            module_index[module_name] = file_path
    return module_index


def discover_verilog_files(repo_root: Path, inputs: Iterable[str], explicit_top_paths: Set[Path]) -> List[Path]:
    files: List[Path] = []
    for item in inputs:
        path = Path(item)
        if not path.is_absolute():
            path = repo_root / path
        if path.is_file():
            if _should_include_file(path, explicit_top_paths):
                files.append(path)
            continue
        if not path.is_dir():
            continue
        for pattern in ("*.v", "*.sv"):
            for file_path in sorted(path.rglob(pattern)):
                if _should_include_file(file_path, explicit_top_paths):
                    files.append(file_path)
    return sorted(set(files))


def _should_include_file(path: Path, explicit_top_paths: Set[Path]) -> bool:
    if path in explicit_top_paths:
        return True
    name = path.name.lower()
    return not (
        name.endswith("_tb.v")
        or name.endswith("_tb.sv")
        or name.startswith("tb_")
    )
