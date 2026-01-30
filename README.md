# Primitive Registry Builder

This repository includes a lightweight Verilog primitive registry generator and a
component knowledge base builder for selected pipeline components.

## Usage

```bash
python -m docgen_sv_primitive init --repo . --inputs base
python -m docgen_sv_primitive update --repo . base/<changed_file.v>
python -m docgen_sv_primitive render --repo .
```

### Component Knowledge Base Builder

```bash
python -m docgen_components init --repo . --inputs pipeline
python -m docgen_components init --repo . --inputs pipeline --force
python -m docgen_components update --repo . pipeline/<changed_file.v>
python -m docgen_components update --repo . pipeline/<changed_file.v> --force
python -m docgen_components render --repo .
```

### CC Header Tools

Generate and validate `//@cc:` YAML-in-comment headers for control components.

```bash
python -m cc_header_tools lint --repo . --inputs pipeline --strict
python -m cc_header_tools scan --repo . --inputs pipeline
python -m cc_header_tools skeleton --repo . --family ArbMergeN --file pipeline/cArbMergeN_modName.v --inplace
python -m cc_header_tools autogen --repo . --inputs pipeline --only-missing --inplace
```

Lint rules (summary):
- `//@cc:` block exists and `schema=cc_header_v1`
- `family` is one of 7 families
- `roles` ports must exist in module ports (slice refs allowed; base name checked)
- `ArbMergeN` requires `contract.arb_policy`
- `MutexMergeN` requires `contract.mutex_model=environment_mutex_assumed`
- If `params.NUM_PORTS` is an int, `roles.inputs`/`roles.channels` count must match (warning)
- `TODO` fields are warnings by default, errors with `--strict`

Autogen:
- Inserts a conservative header before `module` when missing
- Fills known facts; unknowns become `TODO`
- Family inferred by name pattern; unknown family is marked with a TODO note
- Does not alter existing formatting aside from the inserted header

## Outputs

- `.docgen/primitive_registry.json`: registry data
- `docs/PRIMITIVES.md`: grouped primitive/component documentation
- `docs/REGISTRY_SCHEMA.md`: registry field description
- `.docgen/component_kb.json`: component knowledge base data
- `docs/COMPONENTS.md`: grouped component documentation
- `docs/cc_header_spec.md`: CC header spec
- `templates/cc_headers/*.txt`: CC header templates for 7 families

## Configuration

Override classification in `docgen_sv/config.json`:

```json
{
  "kind_overrides": {
    "MyModule": "component"
  },
  "category_overrides": {
    "MyModule": "custom_category"
  }
}
```
