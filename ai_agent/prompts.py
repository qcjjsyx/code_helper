"""Prompt construction for the project documentation agent."""

from __future__ import annotations

import json
from typing import Iterable

from .knowledge_base import ArtifactRecord, ProjectKnowledgeBase
from .manual_context import ManualContext


SYSTEM_PROMPT = """你是一个面向异步电路 Verilog 项目的代码手册助手。
你的唯一 ground truth 是当前提供给你的 parser_pipeline JSON 上下文。

回答规则：
1. 只基于提供的 JSON 作答，不要臆测缺失的实现细节。
2. 优先解释模块层级、结构子组成、event flow、data flow、背压/完成关系。
3. 如果上下文不足，明确说缺少哪个模块或结构子的 JSON。
4. 默认用中文回答，风格简洁、结构清楚。
5. 回答时尽量引用具体模块名、结构子名、family 名和端口/信号角色。
"""


MANUAL_SYSTEM_PROMPT = """你是一个面向异步电路 Verilog 项目的代码手册生成器。
你的唯一 ground truth 是当前提供给你的 parser_pipeline JSON 上下文。

写作要求：
1. 只基于 JSON 作答，不要补不存在的实现细节。
2. 使用中文 Markdown 输出。
3. 手册要让新接手项目的人快速建立系统认知。
4. 至少覆盖：模块职责、层级结构、关键结构子、event flow、data flow、背压/完成关系、重点风险点。
5. 先讲整体，再讲关键子模块，再讲支撑这些功能的结构子。
6. 如果某处证据不足，要明确标注“根据当前 JSON 无法进一步确认”。
"""


def build_user_prompt(question: str, kb: ProjectKnowledgeBase, records: Iterable[ArtifactRecord]) -> str:
    selected = list(records)
    payload = {
        "project_index_summary": {
            "top_modules": kb.project_index.get("top_modules", []),
            "stats": kb.project_index.get("stats", {}),
        },
        "selected_artifacts": [
            {
                "name": record.name,
                "artifact_kind": record.artifact_kind,
                "file": record.file,
                "payload": record.payload,
            }
            for record in selected
        ],
        "question": question,
    }
    return json.dumps(payload, ensure_ascii=False, indent=2)


def build_manual_prompt(context: ManualContext) -> str:
    payload = {
        "task": "为指定顶层模块生成代码手册",
        "top_module": context.top_module,
        "top_module_payload": context.top_module_payload,
        "module_summaries": context.module_summaries,
        "component_summaries": context.component_summaries,
        "required_sections": [
            "模块概览",
            "层级结构",
            "关键结构子与作用",
            "事件流",
            "数据流",
            "等待/背压/完成关系",
            "阅读建议与风险点",
        ],
    }
    return json.dumps(payload, ensure_ascii=False, indent=2)
