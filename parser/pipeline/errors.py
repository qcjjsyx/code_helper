"""Shared error and warning helpers for parser_pipeline."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict


@dataclass(frozen=True)
class BuildIssue:
    """A structured issue surfaced during parsing or build."""

    level: str
    message: str
    file: str = ""
    module: str = ""
    context: Dict[str, Any] | None = None

    def to_dict(self) -> Dict[str, Any]:
        payload: Dict[str, Any] = {
            "level": self.level,
            "message": self.message,
        }
        if self.file:
            payload["file"] = self.file
        if self.module:
            payload["module"] = self.module
        if self.context:
            payload["context"] = self.context
        return payload
