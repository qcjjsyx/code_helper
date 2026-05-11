# Manual Generation Contract

This contract defines the evidence boundary for dialogue-driven code manual generation.

## Evidence Sources

Use these sources in order:

1. Parser pipeline artifacts are the ground truth for parsed RTL facts.
2. Manual IR objects are the writing-oriented intermediate representation.
3. ReadingPath and ContextPack determine section order, coverage, and evidence policy.

Do not use raw RTL text as a semantic source for final manual prose unless the same fact is already represented in parser artifacts or Manual IR.

## Required Workflow

1. Run parser pipeline build.
2. Export split Manual IR.
3. Validate the split Manual IR.
4. Build ContextPack JSON for the selected ReadingPath or section.
5. Generate manual prose from ContextPack objects and section metadata.

## Section Rules

For each section:

- Follow `section.intent`.
- Produce the shapes listed in `section.expected_outputs`.
- Respect every item in `section.evidence_policy`.
- Prioritize objects according to `section.coverage_priority`.
- Use `section.grouping_hints` to group large object sets.
- Preserve `section.review_questions` as review or maintenance prompts when useful.
- Write to the chapter and anchor indicated by `section.artifact_target`.

## Boundary Rules

- Partial FlowPath is a real parser boundary, not a gap to fill with guessing.
- Low-confidence FlowPath must remain marked as uncertain.
- External dependencies must be described as interface-only unless parser facts say more.
- Transparent delay helpers can explain event pass-through, but they are not formal component leaves.
- ComponentContract behavior must stay within parser/family template facts.

## FlowPath Enhancement Policy

If a flow cannot be completed because it crosses process, always, FSM, or register logic, do not infer the missing path in Manual IR or prose.

Prefer adding parser-level fact types such as:

- `process_event_generation`
- `fsm_state_event_relation`
- `register_driven_event`
- `sequential_event_boundary`

Only after such facts exist should Manual IR or ContextPack expose the new evidence for writing.
