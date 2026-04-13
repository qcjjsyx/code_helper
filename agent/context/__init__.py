"""Context management interfaces for the documentation agent."""

from .manager import AgentContextManager, InMemoryContextManager
from .models import (
    AgentSession,
    ContextBudget,
    ContextItem,
    ContextRequest,
    ContextScope,
    ContextSelection,
    ContextSnapshot,
    ConversationTurn,
    TaskKind,
)

__all__ = [
    "AgentContextManager",
    "AgentSession",
    "ContextBudget",
    "ContextItem",
    "ContextRequest",
    "ContextScope",
    "ContextSelection",
    "ContextSnapshot",
    "ConversationTurn",
    "InMemoryContextManager",
    "TaskKind",
]
