"""Thin wrapper over the official Qwen OpenAI-compatible chat API."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .config import AgentConfig


@dataclass(frozen=True)
class QwenResponse:
    response_id: str | None
    text: str
    raw: Any


class QwenClient:
    def __init__(self, config: AgentConfig):
        self._config = config

    def create_response(
        self,
        *,
        system_prompt: str,
        user_prompt: str,
        previous_response_id: str | None = None,
    ) -> QwenResponse:
        if not self._config.api_key:
            raise RuntimeError(
                "Missing Qwen API key. Set DASHSCOPE_API_KEY or QWEN_API_KEY before using ai_agent."
            )

        try:
            from openai import OpenAI
        except ImportError as exc:
            raise RuntimeError(
                "The openai package is required for ai_agent. Install dependencies from requirements.txt."
            ) from exc

        client = OpenAI(
            api_key=self._config.api_key,
            base_url=self._config.base_url,
        )
        response = client.chat.completions.create(
            model=self._config.model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=self._config.temperature,
        )
        text = _extract_output_text(response)
        return QwenResponse(
            response_id=getattr(response, "id", None),
            text=text,
            raw=response,
        )


def _extract_output_text(response: Any) -> str:
    choices = getattr(response, "choices", None) or []
    chunks = []
    for choice in choices:
        message = getattr(choice, "message", None)
        if message is None:
            continue
        content = getattr(message, "content", None)
        if isinstance(content, str) and content.strip():
            chunks.append(content.strip())
    return "\n".join(chunks).strip()
