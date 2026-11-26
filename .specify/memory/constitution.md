# ARTEX Constitution

## Core Principles

### I. Capability Over Name
Planners and skills declare capabilities, never concrete server names. Runtime resolution maps a capability to the registered servers that satisfy it.

### II. One Shape For Every Tool
Every tool call returns `{target, status, findings[], raw_ref}`. Raw text is a reference, never the result. Every tool carries one capability tag and one risk class.

### III. Executable Coverage Over Catalogue-Only
Every catalogued repo, including high-risk repos, gets an executable server wrapper. A missing binary is reported explicitly, never silently skipped or faked.

### IV. Guard Is Operator-Owned
Built-in interception guard and scope/target enforcement are out of this build. This feature adds no approval, sandbox, kill-switch or quota mechanism; the operator supplies their own layer afterwards.

### V. Prefer Small, Reuse Existing
Use the repository's existing tool-execution and skill-loading patterns. No new abstraction when an existing helper or standard mechanism suffices.

## Development Workflow

- Spec-kit SDD: specify → plan → tasks → implement. Review gates precede task generation and implementation.
- Verify with build and tests; do not execute high-risk tools against any target during verification.
- Operator-authored untracked files are preserved, never overwritten.

## Governance

This constitution governs this feature. Amendments require an explicit operator instruction and a note in the spec.

**Version**: 1.0 | **Ratified**: 2026-11-26 | **Last Amended**: 2026-11-26
