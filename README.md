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

## Outputs

- `.docgen/primitive_registry.json`: registry data
- `docs/PRIMITIVES.md`: grouped primitive/component documentation
- `docs/REGISTRY_SCHEMA.md`: registry field description
- `.docgen/component_kb.json`: component knowledge base data
- `docs/COMPONENTS.md`: grouped component documentation

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
