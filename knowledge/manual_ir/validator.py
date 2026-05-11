"""Validation helpers for split Manual IR exports."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List

from .split_store import (
    ManualIRSplitError,
    build_object_catalog,
    list_reading_paths,
    load_manifest,
    resolve_manual_ir_object,
)


REQUIRED_AUDIENCES = {"newcomer", "maintainer", "reviewer"}
REQUIRED_SPLIT_GROUPS = {
    "module_cards",
    "channel_cards",
    "component_contracts",
    "flow_paths",
    "reading_paths",
}


def validate_manual_ir_split(
    manual_ir_dir: str | Path,
    *,
    parser_artifacts_root: str | Path | None = None,
) -> Dict[str, Any]:
    root = Path(manual_ir_dir)
    issues: List[Dict[str, str]] = []

    if not root.is_dir():
        return _report(root, issues=[_issue("error", "missing_manual_ir_dir", f"Manual IR directory not found: {root}")])

    try:
        manifest = load_manifest(root)
    except Exception as exc:
        return _report(root, issues=[_issue("error", "missing_manifest", str(exc))])

    _validate_parser_artifacts(parser_artifacts_root, manifest, issues)
    _validate_manifest_shape(root, manifest, issues)

    try:
        catalog = build_object_catalog(root)
    except Exception as exc:
        return _report(root, manifest=manifest, issues=issues + [_issue("error", "invalid_object_catalog", str(exc))])

    objects = _load_catalog_objects(root, catalog, issues)
    _validate_counts(manifest, objects, issues)
    _validate_reading_paths(root, catalog, issues)

    warning_summary = _build_warning_summary(objects)
    return _report(
        root,
        manifest=manifest,
        issues=issues,
        summary={
            "object_count": len(objects),
            "catalog_count": len(catalog),
            "top_module": manifest.get("top_module", ""),
            "warnings": {
                key: len(value)
                for key, value in warning_summary.items()
            },
        },
        warning_summary=warning_summary,
    )


def _validate_parser_artifacts(
    parser_artifacts_root: str | Path | None,
    manifest: Dict[str, Any],
    issues: List[Dict[str, str]],
) -> None:
    artifacts_root = Path(parser_artifacts_root) if parser_artifacts_root else None
    if artifacts_root is None:
        generated_from = manifest.get("generated_from", {})
        candidate = generated_from.get("artifacts_root") if isinstance(generated_from, dict) else ""
        artifacts_root = Path(candidate) if candidate else None
    if artifacts_root is None or not str(artifacts_root):
        issues.append(_issue("warning", "parser_artifacts_not_checked", "Parser artifacts root was not provided."))
        return
    required = [
        artifacts_root / "project_index.json",
        artifacts_root / "build_report.json",
        artifacts_root / "modules",
        artifacts_root / "components",
    ]
    for path in required:
        if not path.exists():
            issues.append(_issue("error", "missing_parser_artifact", f"Parser artifact path not found: {path}"))


def _validate_manifest_shape(root: Path, manifest: Dict[str, Any], issues: List[Dict[str, str]]) -> None:
    files = manifest.get("files")
    if not isinstance(files, dict):
        issues.append(_issue("error", "invalid_manifest_files", "manifest.files must be an object."))
        return
    if not isinstance(files.get("system_views"), str):
        issues.append(_issue("error", "missing_system_views_ref", "manifest.files.system_views must point to system_views.json."))
    for group in REQUIRED_SPLIT_GROUPS:
        if not isinstance(files.get(group), dict):
            issues.append(_issue("error", "missing_manifest_group", f"manifest.files.{group} must be an object."))
            continue
        for _, rel_path in files[group].items():
            if isinstance(rel_path, str) and not (root / rel_path).is_file():
                issues.append(_issue("error", "missing_split_file", f"Split object file not found: {rel_path}"))


def _load_catalog_objects(
    root: Path,
    catalog: Dict[str, Dict[str, str]],
    issues: List[Dict[str, str]],
) -> List[Dict[str, Any]]:
    objects: List[Dict[str, Any]] = []
    for object_id in sorted(catalog):
        try:
            objects.append(resolve_manual_ir_object(root, object_id))
        except Exception as exc:
            issues.append(_issue("error", "unreadable_object", f"{object_id}: {exc}", object_id=object_id))
    return objects


def _validate_counts(manifest: Dict[str, Any], objects: List[Dict[str, Any]], issues: List[Dict[str, str]]) -> None:
    expected_counts = manifest.get("counts", {})
    if not isinstance(expected_counts, dict):
        issues.append(_issue("error", "invalid_counts", "manifest.counts must be an object."))
        return
    actual = {
        "system_views": sum(1 for obj in objects if obj.get("kind") == "system_view"),
        "module_cards": sum(1 for obj in objects if obj.get("kind") == "module_card"),
        "channel_cards": sum(1 for obj in objects if obj.get("kind") == "channel_card"),
        "component_contracts": sum(1 for obj in objects if obj.get("kind") == "component_contract"),
        "flow_paths": sum(1 for obj in objects if obj.get("kind") == "flow_path"),
        "reading_paths": sum(1 for obj in objects if obj.get("kind") == "reading_path"),
    }
    for key, actual_count in actual.items():
        expected = expected_counts.get(key)
        if expected is not None and expected != actual_count:
            issues.append(
                _issue(
                    "error",
                    "count_mismatch",
                    f"manifest.counts.{key}={expected}, actual={actual_count}",
                )
            )


def _validate_reading_paths(
    root: Path,
    catalog: Dict[str, Dict[str, str]],
    issues: List[Dict[str, str]],
) -> None:
    try:
        reading_paths = list_reading_paths(root)
    except Exception as exc:
        issues.append(_issue("error", "unreadable_reading_paths", str(exc)))
        return

    audiences = {path.get("audience") for path in reading_paths}
    missing_audiences = sorted(REQUIRED_AUDIENCES - audiences)
    if missing_audiences:
        issues.append(
            _issue(
                "error",
                "missing_default_reading_paths",
                f"Missing ReadingPath audiences: {', '.join(missing_audiences)}",
            )
        )

    for reading_path in reading_paths:
        reading_id = str(reading_path.get("id", ""))
        for section in reading_path.get("ordered_sections", []):
            section_id = str(section.get("section_id", ""))
            for object_id in section.get("covers", []):
                if object_id not in catalog:
                    issues.append(
                        _issue(
                            "error",
                            "unresolved_section_cover",
                            f"{reading_id}/{section_id} covers missing object {object_id}",
                            object_id=str(object_id),
                        )
                    )
                else:
                    try:
                        resolve_manual_ir_object(root, object_id)
                    except (FileNotFoundError, ManualIRSplitError) as exc:
                        issues.append(
                            _issue(
                                "error",
                                "unreadable_section_cover",
                                f"{reading_id}/{section_id} cannot load {object_id}: {exc}",
                                object_id=str(object_id),
                            )
                        )


def _build_warning_summary(objects: List[Dict[str, Any]]) -> Dict[str, List[str]]:
    summary: Dict[str, List[str]] = {
        "object_warnings": [],
        "partial_or_low_confidence_flows": [],
        "external_dependencies": [],
    }
    for obj in objects:
        object_id = str(obj.get("id", ""))
        for warning in obj.get("warnings", []):
            if isinstance(warning, str) and warning:
                summary["object_warnings"].append(f"{object_id}: {warning}")
        if obj.get("kind") == "flow_path" and (obj.get("warnings") or obj.get("confidence") == "low"):
            summary["partial_or_low_confidence_flows"].append(object_id)
        if obj.get("kind") == "system_view":
            for dependency in obj.get("external_dependencies", []):
                name = dependency.get("name") if isinstance(dependency, dict) else ""
                if name:
                    summary["external_dependencies"].append(name)
    return {key: _dedupe(values) for key, values in summary.items()}


def _report(
    manual_ir_dir: Path,
    *,
    manifest: Dict[str, Any] | None = None,
    issues: List[Dict[str, str]],
    summary: Dict[str, Any] | None = None,
    warning_summary: Dict[str, List[str]] | None = None,
) -> Dict[str, Any]:
    return {
        "schema": "manual_ir_validation_report",
        "schema_version": "0.1",
        "manual_ir_dir": str(manual_ir_dir),
        "top_module": (manifest or {}).get("top_module", ""),
        "status": "failed" if any(issue.get("level") == "error" for issue in issues) else "passed",
        "summary": summary or {},
        "issues": issues,
        "warning_summary": warning_summary or {},
    }


def _issue(level: str, code: str, message: str, *, object_id: str = "") -> Dict[str, str]:
    issue = {
        "level": level,
        "code": code,
        "message": message,
    }
    if object_id:
        issue["object_id"] = object_id
    return issue


def _dedupe(values: List[str]) -> List[str]:
    seen: set[str] = set()
    deduped: List[str] = []
    for value in values:
        if not value or value in seen:
            continue
        seen.add(value)
        deduped.append(value)
    return deduped
