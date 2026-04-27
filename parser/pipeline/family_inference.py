"""Compatibility wrappers for component-family inference."""

from __future__ import annotations

from .boundary_policy import (
    TERMINAL_COMPONENT_FAMILY_BY_TYPE,
    infer_component_family,
    is_known_family,
    normalize_family_name,
)


def infer_family(*args, **kwargs):
    return infer_component_family(*args, **kwargs)
