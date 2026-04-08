import os
from pathlib import Path

from agent.writer.config import load_config


def test_load_config_reads_repo_dotenv(tmp_path, monkeypatch):
    repo_root = tmp_path / "repo"
    repo_root.mkdir()
    (repo_root / ".env").write_text(
        "\n".join(
            [
                "DASHSCOPE_API_KEY=test-key",
                "QWEN_MODEL=qwen-max",
                "QWEN_BASE_URL=https://example.invalid/v1",
            ]
        ),
        encoding="utf-8",
    )
    monkeypatch.delenv("DASHSCOPE_API_KEY", raising=False)
    monkeypatch.delenv("QWEN_MODEL", raising=False)
    monkeypatch.delenv("QWEN_BASE_URL", raising=False)

    config = load_config(repo_root)

    assert config.api_key == "test-key"
    assert config.model == "qwen-max"
    assert config.base_url == "https://example.invalid/v1"
