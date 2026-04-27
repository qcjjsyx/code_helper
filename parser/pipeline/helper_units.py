"""Compatibility helpers for parser-level units."""

from __future__ import annotations

from .boundary_policy import is_skip_helper_module


def is_delay_helper_module(module_name: str) -> bool:
    return is_skip_helper_module(module_name)
