# Research: ARTEX Tool & Skill Expansion

> **Scope revision (2026-11-26)**: the operator decided to keep ARTEX core (guard, intercept, target gate) unchanged. Only skill-level restrictions were removed. Guard-related items below are superseded and were not implemented.
## Decision 1: One generic server binary, one process per repo

**Decision**: Build a single generic tool-server binary that reads a declarative catalog entry (`--tool <name>`) and speaks a minimal JSON-RPC protocol over stdio. Each catalogued repo is launched as its own process with its own entry. No per-repo Go source file.

**Rationale**: The brief requires an independent server per repo with `tools/list`, `tools/call` and `ping`. A parameterised binary satisfies that with one implementation and makes adding a repo a catalog line instead of a new program. There is no MCP server dependency in `go.mod`; `mcphttp/` is a client only. A tiny stdio JSON-RPC loop needs no new dependency.

**Alternatives considered**: (a) hand-written server per repo — ~60 programs, rejected; (b) add an MCP framework dependency — rejected because the protocol surface needed here is three methods and the project avoids new dependencies; (c) shell wrappers registered as `kind: command` tools only — rejected because it does not provide `tools/list`/`ping`.

## Decision 2: Catalog is the single source of truth

**Decision**: `tools/catalog.json` holds name, binary, default arguments, capability, risk class, timeout and health timeout for every repo. The DB tool registry is seeded from that catalog.

**Rationale**: The existing `tools` table has only `key, description, schema, agents, enabled, kind, exec`. Capability/risk/timeout need new columns; seeding them from one catalog avoids drift between wrapper, registry and skill metadata.

**Alternatives considered**: encoding capability in the tool description — rejected because capability queries then require string parsing and cannot be reliable.

## Decision 3: Uniform record produced by the server, not by each tool

**Decision**: The server captures stdout+stderr, writes the raw output to a file under `data/toolraw/`, and returns `{target, status, findings[], raw_ref}`. A missing binary returns `status: "not_installed"` with empty findings. Non-zero exit returns `status: "error"`.

**Rationale**: Requirement A2 forbids raw text as the result. Writing raw to a file keeps the envelope small and gives `raw_ref` a real target.

**Alternatives considered**: embedding full raw output in the record — rejected for large scanners; returning only parsed findings — rejected because debugging needs the raw output.

## Decision 4: Guard/scope removal — neutralise enforcement, keep transport plumbing

**Finding**: Guard and scope enforcement is not confined to `guard/`. `TargetScope`/`TargetGate` appear in 56 Go files across `intercept/`, `egress/`, `agent/` and `server/`, including dialers, HTTP redirects and their tests. Deleting the whole subsystem would rewrite core networking and remove a large test suite.

**Decision**: Remove the shipped `guard` package and the `scopesentry` skill from the build, and default target/intercept enforcement to off at its entry points so no active approval or scope check remains. Keep dialer/DB plumbing intact.

**Rationale**: Satisfies "no active enforcement path" with a small, reviewable, git-revertible diff while keeping the build and remaining tests green. The operator's own guard layer can then be installed without double enforcement.

**Alternatives considered**: full deletion of `intercept/` + `egress/` gate paths — rejected as a 56-file rewrite with high regression risk; leaving guards enabled — rejected by the operator's explicit instruction.

## Decision 5: Skills rebuild preserves operator files

**Finding**: `skills/artex`, `skills/hacktricks`, `skills/nuclei`, `skills/peass` are untracked operator work. The skill loader (`server/pathconfine.go` → `skill.Registry`) parses frontmatter tolerantly, so extra keys such as `capabilities` and `tools_required` are safe.

**Decision**: Rewrite `SKILL.md` in place with the required frontmatter and an explicit "when to use" + test case, and move any operator-authored extra content into `references/` instead of deleting it.

**Alternatives considered**: replacing whole skill directories — rejected because it destroys untracked work.

## Open items resolved

- No extension hooks: `.specify/extensions.yml` does not exist.
- Constitution was an unfilled template; replaced with the operator's stated principles before planning.
- Feature directory created as `specs/001-artex-tool-skill-expansion`.
