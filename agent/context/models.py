"""Context-management data structures for the agent layer.

These models are intentionally lightweight in the current version:
- they define the shapes an agent-oriented context manager should speak
- they do not assume a specific storage backend
- they leave room for future summarization, memory, and session persistence
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Literal


ContextItemKind = Literal[
    "artifact",
    "manual_ir",
    "conversation_summary",
    "chapter_plan",
    "external_note",
    "constraint",
]
ContextScope = Literal["turn", "session", "document"]
TaskKind = Literal["qa", "manual_generation", "chapter_generation", "critique"]


@dataclass(frozen=True)
class AgentSession:
    session_id: str
    repo_root: str
    top_module: str | None = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    previous_response_id: str | None = None


@dataclass(frozen=True)
class ContextItem:
    item_id: str
    kind: ContextItemKind
    title: str
    content: Dict[str, Any]
    scope: ContextScope = "turn"
    source_refs: List[str] = field(default_factory=list)
    estimated_tokens: int | None = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ContextBudget:
    max_items: int = 6
    max_tokens: int | None = None
    reserved_output_tokens: int | None = None


@dataclass(frozen=True)
class ContextRequest:
    task_kind: TaskKind
    query: str
    session_id: str | None = None
    top_module: str | None = None
    section_name: str | None = None
    budget: ContextBudget = field(default_factory=ContextBudget)
    candidate_items: List[ContextItem] = field(default_factory=list)
    pinned_item_ids: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ContextSelection:
    selected_items: List[ContextItem] = field(default_factory=list)
    omitted_item_ids: List[str] = field(default_factory=list)
    selection_notes: List[str] = field(default_factory=list)
    budget: ContextBudget = field(default_factory=ContextBudget)


@dataclass(frozen=True)
class ConversationTurn:
    turn_id: str
    user_input: str
    assistant_output: str = ""
    selected_item_ids: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ContextSnapshot:
    session: AgentSession
    pinned_items: List[ContextItem] = field(default_factory=list)
    rolling_summary: str | None = None
    recent_turns: List[ConversationTurn] = field(default_factory=list)
