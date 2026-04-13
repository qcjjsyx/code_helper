from pathlib import Path

from agent.context import ContextBudget, ContextItem, ContextRequest, InMemoryContextManager


def test_in_memory_context_manager_respects_max_items():
    manager = InMemoryContextManager()
    request = ContextRequest(
        task_kind="qa",
        query="解释 fetch path",
        budget=ContextBudget(max_items=2),
        candidate_items=[
            ContextItem(item_id="a", kind="artifact", title="A", content={"name": "A"}),
            ContextItem(item_id="b", kind="artifact", title="B", content={"name": "B"}),
            ContextItem(item_id="c", kind="artifact", title="C", content={"name": "C"}),
        ],
    )

    selection = manager.select_context(request)

    assert [item.item_id for item in selection.selected_items] == ["a", "b"]
    assert selection.omitted_item_ids == ["c"]


def test_in_memory_context_manager_keeps_basic_session_snapshot():
    manager = InMemoryContextManager()
    session = manager.open_session(repo_root=Path("/tmp/repo"), top_module="cpu_top")

    snapshot = manager.snapshot(session.session_id)

    assert snapshot is not None
    assert snapshot.session.session_id == session.session_id
    assert snapshot.session.top_module == "cpu_top"
