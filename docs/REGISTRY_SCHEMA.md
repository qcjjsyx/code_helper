# Registry Schema (v1)

## Top-level fields

- `meta`: metadata for the registry generation
  - `generated_at`: ISO timestamp of generation
  - `repo_root`: absolute path to repo root
  - `entries_count`: total number of entries
- `entries`: list of primitive/component entries

## Entry fields

- `name`: module name
- `kind`: `primitive` or `component`
- `file`: repo-relative path
- `sha256`: content hash
- `language`: `verilog`
- `ports`: list of `{name, direction, width}`
- `params`: list of `{name, default}`
- `deps_primitives`: list of instantiated project modules
- `tech_cells`: list of instantiated technology cells
- `reset`: `{present, signal, active_low}`
- `category`: auto category (v1)
- `protocol`: protocol identifier (v1 defaults to `unknown`)
- `port_roles`: mapping of port name to role (v1 empty)
- `semantics_1line`: optional summary
- `constraints`: list of constraints (v1 empty)
- `gotchas`: list of gotchas (v1 empty)
- `updated_at`: ISO timestamp of entry update
- `deleted`: boolean when source file removed
- `parse_errors`: optional list of parse errors
