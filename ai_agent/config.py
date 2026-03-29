"""Configuration helpers for the Qwen-backed project agent."""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from .env_loader import load_dotenv

DEFAULT_QWEN_BASE_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1"
DEFAULT_QWEN_MODEL = "qwen-plus"


@dataclass(frozen=True)
class AgentConfig:
    repo_root: Path
    artifacts_root: Path
    api_key: str | None
    base_url: str
    model: str
    max_context_items: int
    temperature: float


def load_config(
    repo_root: Path,
    *,
    artifacts_root: str | None = None,
    api_key: str | None = None,
    base_url: str | None = None,
    model: str | None = None,
    max_context_items: int = 6,
    temperature: float = 0.2,
) -> AgentConfig:
    repo_root = repo_root.resolve()
    load_dotenv(repo_root / ".env")

    resolved_artifacts = (
        Path(artifacts_root).expanduser()
        if artifacts_root
        else repo_root / "artifacts" / "parser_pipeline_result"
    )
    if not resolved_artifacts.is_absolute():
        resolved_artifacts = (repo_root / resolved_artifacts).resolve()

    return AgentConfig(
        repo_root=repo_root,
        artifacts_root=resolved_artifacts,
        api_key=api_key or os.getenv("DASHSCOPE_API_KEY") or os.getenv("QWEN_API_KEY"),
        base_url=base_url or os.getenv("QWEN_BASE_URL", DEFAULT_QWEN_BASE_URL),
        model=model or os.getenv("QWEN_MODEL", DEFAULT_QWEN_MODEL),
        max_context_items=max_context_items,
        temperature=temperature,
    )
