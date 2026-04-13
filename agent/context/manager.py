"""Context manager interfaces and a small baseline implementation.

The goal of this module is to reserve stable extension points for future work:
- session-level memory
- rolling summaries for long conversations
- context-window budgeting and compression
- chapter-local state for multi-stage manual generation
- pluggable persistence backends

The current `InMemoryContextManager` is intentionally minimal. It is useful for
tests and for keeping the agent code structured, but it does not yet implement
advanced summarization, compaction, or durable storage.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import replace
from pathlib import Path
from typing import Dict, List
from uuid import uuid4

from .models import (
    AgentSession,
    ContextRequest,
    ContextSelection,
    ContextSnapshot,
    ConversationTurn,
)


class AgentContextManager(ABC):
    """Abstract interface for agent context and session management."""

    @abstractmethod
    def open_session(
        self,
        *,
        repo_root: Path,
        top_module: str | None = None,
        metadata: Dict[str, object] | None = None,
    ) -> AgentSession:
        """Create a new agent session."""

    @abstractmethod
    def get_session(self, session_id: str) -> AgentSession | None:
        """Return session metadata if available."""

    @abstractmethod
    def select_context(self, request: ContextRequest) -> ContextSelection:
        """Select the items that should enter the current model context."""

    @abstractmethod
    def record_turn(self, session_id: str, turn: ConversationTurn) -> None:
        """Record a finished or in-progress interaction turn."""

    @abstractmethod
    def snapshot(self, session_id: str) -> ContextSnapshot | None:
        """Return a snapshot of the known session state."""


class InMemoryContextManager(AgentContextManager):
    """Baseline in-memory manager.

    This implementation keeps:
    - session metadata
    - a short list of recent turns
    - simple top-N context selection based on request order

    Future backends can replace this with:
    - persistent storage
    - token-aware ranking and compression
    - explicit pinned memory and long-horizon summaries
    """

    def __init__(self) -> None:
        self._sessions: Dict[str, AgentSession] = {}
        self._turns: Dict[str, List[ConversationTurn]] = {}

    def open_session(
        self,
        *,
        repo_root: Path,
        top_module: str | None = None,
        metadata: Dict[str, object] | None = None,
    ) -> AgentSession:
        session_id = uuid4().hex
        session = AgentSession(
            session_id=session_id,
            repo_root=str(repo_root),
            top_module=top_module,
            metadata=dict(metadata or {}),
        )
        self._sessions[session_id] = session
        self._turns[session_id] = []
        return session

    def get_session(self, session_id: str) -> AgentSession | None:
        return self._sessions.get(session_id)

    def select_context(self, request: ContextRequest) -> ContextSelection:
        max_items = request.budget.max_items
        if max_items < 0:
            selected = list(request.candidate_items)
            omitted: List[str] = []
        else:
            selected = list(request.candidate_items[:max_items])
            omitted = [item.item_id for item in request.candidate_items[max_items:]]

        notes = [
            "Using baseline in-memory context selection.",
            "Advanced ranking, summarization, and token compression are reserved for future work.",
        ]
        if request.pinned_item_ids:
            notes.append("Pinned item support is reserved in the interface but not yet prioritized by this backend.")

        return ContextSelection(
            selected_items=selected,
            omitted_item_ids=omitted,
            selection_notes=notes,
            budget=request.budget,
        )

    def record_turn(self, session_id: str, turn: ConversationTurn) -> None:
        if session_id not in self._sessions:
            return
        turns = self._turns.setdefault(session_id, [])
        turns.append(turn)
        previous_response_id = turn.metadata.get("response_id")
        if isinstance(previous_response_id, str) and previous_response_id:
            self._sessions[session_id] = replace(
                self._sessions[session_id],
                previous_response_id=previous_response_id,
            )

    def snapshot(self, session_id: str) -> ContextSnapshot | None:
        session = self._sessions.get(session_id)
        if session is None:
            return None
        return ContextSnapshot(
            session=session,
            recent_turns=list(self._turns.get(session_id, [])),
        )
