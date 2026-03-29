"""CLI for the Qwen-backed project documentation agent."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Optional

from .agent import ProjectDocAgent


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(prog="ai_agent")
    subparsers = parser.add_subparsers(dest="command", required=True)

    ask_parser = subparsers.add_parser("ask", help="Ask a question about the parsed project")
    ask_parser.add_argument("--repo", required=True)
    ask_parser.add_argument("--question", required=True)
    ask_parser.add_argument("--artifacts-root", default=None)
    ask_parser.add_argument("--model", default=None)
    ask_parser.add_argument("--base-url", default=None)
    ask_parser.add_argument("--previous-response-id", default=None)
    ask_parser.add_argument("--max-context-items", type=int, default=6)
    ask_parser.add_argument("--temperature", type=float, default=0.2)
    ask_parser.add_argument("--json", action="store_true")

    manual_parser = subparsers.add_parser("generate-manual", help="Generate a Markdown code manual for a top module")
    manual_parser.add_argument("--repo", required=True)
    manual_parser.add_argument("--top-module", required=True)
    manual_parser.add_argument("--artifacts-root", default=None)
    manual_parser.add_argument("--model", default=None)
    manual_parser.add_argument("--base-url", default=None)
    manual_parser.add_argument("--previous-response-id", default=None)
    manual_parser.add_argument("--max-context-items", type=int, default=6)
    manual_parser.add_argument("--temperature", type=float, default=0.2)
    manual_parser.add_argument("--output", default=None)
    manual_parser.add_argument("--json", action="store_true")

    args = parser.parse_args(argv)

    if args.command == "ask":
        repo_root = Path(args.repo).resolve()
        agent = ProjectDocAgent.from_repo(
            repo_root,
            artifacts_root=args.artifacts_root,
            model=args.model,
            base_url=args.base_url,
            max_context_items=args.max_context_items,
            temperature=args.temperature,
        )
        answer = agent.ask(args.question, previous_response_id=args.previous_response_id)
        if args.json:
            print(
                json.dumps(
                    {
                        "answer": answer.answer,
                        "response_id": answer.response_id,
                        "selected_artifacts": answer.selected_artifacts,
                        "artifact_files": answer.artifact_files,
                    },
                    ensure_ascii=False,
                    indent=2,
                )
            )
        else:
            print(answer.answer)
            print("")
            print("Selected artifacts:")
            for name, file_path in zip(answer.selected_artifacts, answer.artifact_files):
                print(f"- {name}: {file_path}")
            if answer.response_id:
                print(f"\nresponse_id: {answer.response_id}")
        return 0

    if args.command == "generate-manual":
        repo_root = Path(args.repo).resolve()
        agent = ProjectDocAgent.from_repo(
            repo_root,
            artifacts_root=args.artifacts_root,
            model=args.model,
            base_url=args.base_url,
            max_context_items=args.max_context_items,
            temperature=args.temperature,
        )
        manual = agent.generate_manual(
            args.top_module,
            previous_response_id=args.previous_response_id,
        )
        if args.output:
            output_path = Path(args.output)
            if not output_path.is_absolute():
                output_path = repo_root / output_path
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(manual.markdown, encoding="utf-8")
        if args.json:
            print(
                json.dumps(
                    {
                        "top_module": manual.top_module,
                        "markdown": manual.markdown,
                        "response_id": manual.response_id,
                        "selected_modules": manual.selected_modules,
                        "selected_components": manual.selected_components,
                    },
                    ensure_ascii=False,
                    indent=2,
                )
            )
        else:
            print(manual.markdown)
            if manual.response_id:
                print(f"\nresponse_id: {manual.response_id}")
        return 0

    return 1
