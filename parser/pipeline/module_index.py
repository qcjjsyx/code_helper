"""Discover module definitions under input roots."""

from __future__ import annotations

from pathlib import Path
import re
from typing import Dict, Iterable, List, Set

from .module_parser import find_module_name


def build_module_index(repo_root: Path, inputs: Iterable[str], explicit_top_paths: Set[Path]) -> Dict[str, Path]:
    module_index: Dict[str, Path] = {}
    for file_path in discover_verilog_files(repo_root, inputs, explicit_top_paths):
        module_name = find_module_name(file_path)
        if module_name and module_name not in module_index:
            module_index[module_name] = file_path
    return module_index


def resolve_explicit_verilog_files(repo_root: Path, entries: Iterable[str]) -> Set[Path]:
    files: List[Path] = []
    for item in entries:
        path = _resolve_input_path(repo_root, item)
        if not path.exists():
            raise FileNotFoundError(path)
        if path.is_file() and path.suffix.lower() == ".tcl":
            files.extend(_expand_tcl_file_list(path))
        elif path.is_file() and _is_verilog_source_file(path):
            files.append(path.resolve())
    return set(files)


def discover_verilog_files(repo_root: Path, inputs: Iterable[str], explicit_top_paths: Set[Path]) -> List[Path]:
    files: List[Path] = []
    for item in inputs:
        path = _resolve_input_path(repo_root, item)
        if path.is_file() and path.suffix.lower() == ".tcl":
            files.extend(_expand_tcl_file_list(path, explicit_top_paths))
            continue
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
    if not _is_verilog_source_file(path):
        return False
    if path in explicit_top_paths:
        return True
    name = path.name.lower()
    return not (
        name.endswith("_tb.v")
        or name.endswith("_tb.sv")
        or name.startswith("tb_")
    )


def _resolve_input_path(repo_root: Path, item: str) -> Path:
    path = Path(item)
    if not path.is_absolute():
        path = repo_root / item
    return path.resolve()


def _expand_tcl_file_list(tcl_path: Path, explicit_top_paths: Set[Path] | None = None) -> List[Path]:
    explicit_top_paths = explicit_top_paths or set()
    files: List[Path] = []
    for entry in _parse_tcl_file_entries(tcl_path):
        if not _is_verilog_like_entry(entry):
            continue
        files.extend(_resolve_tcl_entry_matches(tcl_path, entry, explicit_top_paths))
    return files


def _parse_tcl_file_entries(tcl_path: Path) -> List[str]:
    entries: List[str] = []
    pattern = re.compile(r"([^\s\"']+\.(?:sv|vh|v))", flags=re.IGNORECASE)
    for raw_line in tcl_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        matches = pattern.findall(line)
        if matches:
            entries.extend(matches)
            continue
        entries.append(line)
    return entries


def _resolve_tcl_entry_matches(
    tcl_path: Path,
    entry: str,
    explicit_top_paths: Set[Path],
) -> List[Path]:
    manifest_root = tcl_path.parent
    direct_path = (manifest_root / entry).resolve()
    matches: List[Path] = []
    if direct_path.exists() and direct_path.is_file():
        if _matches_tcl_entry(direct_path, entry, manifest_root) and _should_include_file(direct_path, explicit_top_paths):
            matches.append(direct_path)
    else:
        matches.extend(
            path.resolve()
            for path in manifest_root.rglob("*")
            if path.is_file()
            and _matches_tcl_entry(path, entry, manifest_root)
            and _should_include_file(path.resolve(), explicit_top_paths)
        )

    if matches:
        unique_matches = sorted(set(matches))
        if len(unique_matches) == 1:
            return unique_matches
        return [_select_preferred_match(unique_matches, manifest_root)]

    if Path(entry).suffix.lower() in {".v", ".sv"}:
        raise FileNotFoundError(f"{entry} referenced by {tcl_path} was not found")
    return []


def _is_verilog_like_entry(entry: str) -> bool:
    return Path(entry).suffix.lower() in {".v", ".sv", ".vh"}


def _is_verilog_source_file(path: Path) -> bool:
    return path.suffix.lower() in {".v", ".sv"}


def _select_preferred_match(matches: List[Path], manifest_root: Path) -> Path:
    return min(matches, key=lambda path: _path_preference_key(path, manifest_root))


def _path_preference_key(path: Path, manifest_root: Path) -> tuple[int, int, int, str]:
    try:
        relative = path.relative_to(manifest_root)
    except ValueError:
        relative = path
    lowered_parts = [part.lower() for part in relative.parts[:-1]]
    suspicious_penalty = sum(
        1
        for part in lowered_parts
        if any(token in part for token in ("backup", "copy", "old"))
    )
    return (
        suspicious_penalty,
        len(relative.parts),
        len(str(relative)),
        str(relative),
    )


def _matches_tcl_entry(path: Path, entry: str, manifest_root: Path) -> bool:
    try:
        relative = path.relative_to(manifest_root)
    except ValueError:
        return False
    relative_text = relative.as_posix()
    if "/" in entry or "\\" in entry:
        normalized_entry = entry.replace("\\", "/")
        return relative_text == normalized_entry
    return path.name == entry
