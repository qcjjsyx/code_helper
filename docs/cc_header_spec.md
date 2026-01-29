# CC Header Spec (v1)

This document defines the minimal `//@cc:` YAML-in-comment header for control components.

## Format

- A header is a consecutive block of lines beginning with `//@cc:`.
- The block must appear before the `module` declaration.
- Each line after the prefix is YAML (subset) with indentation support.

Example:

```
//@cc: schema: cc_header_v1
//@cc: name: MyModule
//@cc: family: ArbMergeN
//@cc: params:
//@cc:   NUM_PORTS: 3
//@cc: roles:
//@cc:   inputs: [i_drive0, i_drive1, i_drive2]
//@cc: contract:
//@cc:   arb_policy: lowest-index-first
```

## Required Fields

- `schema`: must be `cc_header_v1`
- `name`: module name
- `family`: one of `SelSplit`, `NatSplitN`, `WaitMergeN`, `ArbMergeN`, `MutexMergeN`, `Fifo1`, `PmtFifo1`
- `params`, `roles`, `contract`: may be empty but must exist

## Lint Rules (MVP)

1) Header block exists and `schema=cc_header_v1`.
2) `family` is one of the 7 families.
3) Ports referenced in `roles` must exist in the module port list.
4) `ArbMergeN` requires `contract.arb_policy` (non-empty).
5) `MutexMergeN` requires `contract.mutex_model=environment_mutex_assumed`.
6) If `params.NUM_PORTS` is a literal int, `roles.inputs` or `roles.channels` count must match (warning).

## TODO Handling

`TODO` values are treated as warnings by default, and as errors in `--strict` mode.
