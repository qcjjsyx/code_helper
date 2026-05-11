# Manual IR Tool File Map

This file explains the purpose of the Manual IR utility files used by the skill-oriented manual generation workflow.

## Core Utility Files

### `knowledge/manual_ir/split_store.py`

Reads split Manual IR export directories.

Main responsibilities:

- Load `manifest.json`.
- Build an object id catalog across split files.
- Resolve one Manual IR object by stable id, such as `module:arm_soc_top` or `flow:top:i_drv`.
- List and select ReadingPath objects by id or audience.

Use this when an agent needs deterministic access to Manual IR objects without manually interpreting the split directory layout.

### `knowledge/manual_ir/validator.py`

Validates that a split Manual IR directory is usable before manual writing starts.

Main responsibilities:

- Check required split files and manifest groups.
- Check object counts against `manifest.json`.
- Check that default ReadingPath audiences exist: `newcomer`, `maintainer`, and `reviewer`.
- Check that every `ReadingSection.covers` entry resolves to an existing Manual IR object.
- Summarize object warnings, external dependencies, and partial or low-confidence FlowPath objects.

Use this as the preflight step after `knowledge.manual_ir export --output-dir`.

### `knowledge/manual_ir/context_pack.py`

Builds a section-scoped ContextPack for dialogue-driven manual generation.

Main responsibilities:

- Select a ReadingPath by `reading_path_id` or `audience`.
- Optionally narrow to one `section_id`.
- Resolve all Manual IR objects listed in `ReadingSection.covers`.
- Preserve section metadata, source refs, warnings, unresolved covers, and evidence boundary rules.

Use this when an agent needs a compact, explicit evidence package for writing one section or one whole ReadingPath.

## CLI Integration

### `knowledge/manual_ir/cli.py`

Provides command-line access to Manual IR export and the new utility tools.

Relevant commands:

```bash
python -m knowledge.manual_ir export \
  --artifacts-root artifacts/parser_pipeline_rtl \
  --top-module arm_soc_top \
  --output-dir artifacts/manual_ir/arm_soc_top

python -m knowledge.manual_ir validate \
  --manual-ir-dir artifacts/manual_ir/arm_soc_top

python -m knowledge.manual_ir pack \
  --manual-ir-dir artifacts/manual_ir/arm_soc_top \
  --audience newcomer

python -m knowledge.manual_ir resolve \
  --manual-ir-dir artifacts/manual_ir/arm_soc_top \
  --object-id module:arm_soc_top
```

Use this file as the stable command surface for skills or external agents.

### `knowledge/manual_ir/__init__.py`

Exports the new utility functions from the `knowledge.manual_ir` package.

Main responsibilities:

- Expose `build_context_pack`.
- Expose `validate_manual_ir_split`.
- Expose split-store helpers such as `resolve_manual_ir_object` and `build_object_catalog`.

Use this when Python callers import the tools directly instead of going through the CLI.

## Documentation

### `docs/manual_generation_contract.md`

Defines the evidence boundary for dialogue-driven manual generation.

Main responsibilities:

- State that parser artifacts are the ground truth.
- State that Manual IR and ContextPack are the writing inputs.
- Forbid filling partial FlowPath gaps by guessing process, always, FSM, or register behavior.
- Define the parser-level fact types that should be added before enhancing sequential flow explanations.

Use this as the policy reference for a skill or custom agent that generates final manual prose.

## Tests

### `tests/test_manual_ir_tools.py`

Tests the new Manual IR utility layer.

Main coverage:

- Resolving split Manual IR objects by id.
- Validating split Manual IR exports.
- Building ContextPack objects from ReadingPath sections.
- Exercising the `validate`, `pack`, and `resolve` CLI commands.

Use this as the regression suite for the skill-facing utility workflow.
