# Primitive Registry Builder

This repository includes a lightweight Verilog primitive/component registry generator.

## Usage

```bash
python -m docgen_sv init --repo . --inputs base
python -m docgen_sv update --repo . base/<changed_file.v>
python -m docgen_sv render --repo .
```

## Outputs

- `.docgen/primitive_registry.json`: registry data
- `docs/PRIMITIVES.md`: grouped primitive/component documentation
- `docs/REGISTRY_SCHEMA.md`: registry field description

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
