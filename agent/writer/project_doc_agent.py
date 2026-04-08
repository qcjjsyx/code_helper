"""High-level project documentation agent backed by parser artifacts and Qwen."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import List

from .config import AgentConfig, load_config
from .qwen_client import QwenClient
from ..prompts.prompt_builder import (
    MANUAL_SYSTEM_PROMPT,
    SYSTEM_PROMPT,
    build_manual_prompt,
    build_user_prompt,
)
from knowledge.loaders.knowledge_base import load_knowledge_base
from knowledge.manual_ir.manual_context import build_manual_context
from knowledge.retrieval.retriever import retrieve_relevant_artifacts


@dataclass(frozen=True)
class AgentAnswer:
    answer: str
    response_id: str | None
    selected_artifacts: List[str]
    artifact_files: List[str]


@dataclass(frozen=True)
class GeneratedManual:
    top_module: str
    markdown: str
    response_id: str | None
    selected_modules: List[str]
    selected_components: List[str]


class ProjectDocAgent:
    def __init__(self, config: AgentConfig):
        self._config = config
        self._kb = load_knowledge_base(config.artifacts_root)
        self._client = QwenClient(config)

    @classmethod
    def from_repo(
        cls,
        repo_root: Path,
        *,
        artifacts_root: str | None = None,
        api_key: str | None = None,
        base_url: str | None = None,
        model: str | None = None,
        max_context_items: int = 6,
        temperature: float = 0.2,
    ) -> "ProjectDocAgent":
        config = load_config(
            repo_root,
            artifacts_root=artifacts_root,
            api_key=api_key,
            base_url=base_url,
            model=model,
            max_context_items=max_context_items,
            temperature=temperature,
        )
        return cls(config)

    def ask(self, question: str, *, previous_response_id: str | None = None) -> AgentAnswer:
        selected = retrieve_relevant_artifacts(
            question,
            self._kb,
            top_k=self._config.max_context_items,
        )
        user_prompt = build_user_prompt(question, self._kb, selected)
        response = self._client.create_response(
            system_prompt=SYSTEM_PROMPT,
            user_prompt=user_prompt,
            previous_response_id=previous_response_id,
        )
        return AgentAnswer(
            answer=response.text,
            response_id=response.response_id,
            selected_artifacts=[record.name for record in selected],
            artifact_files=[record.file for record in selected],
        )

    def generate_manual(
        self,
        top_module: str,
        *,
        previous_response_id: str | None = None,
    ) -> GeneratedManual:
        context = build_manual_context(self._kb, top_module)
        prompt = build_manual_prompt(context)
        response = self._client.create_response(
            system_prompt=MANUAL_SYSTEM_PROMPT,
            user_prompt=prompt,
            previous_response_id=previous_response_id,
        )
        return GeneratedManual(
            top_module=top_module,
            markdown=response.text,
            response_id=response.response_id,
            selected_modules=[item["name"] for item in context.module_summaries],
            selected_components=[item["name"] for item in context.component_summaries],
        )
