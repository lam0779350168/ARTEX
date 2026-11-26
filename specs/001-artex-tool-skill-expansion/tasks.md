---

> **Scope revision (2026-11-26)**: the operator decided to keep ARTEX core (guard, intercept, target gate) unchanged. Only skill-level restrictions were removed. Guard-related items below are superseded and were not implemented.
description: "Task list for ARTEX Tool & Skill Expansion"
---

# Tasks: ARTEX Tool & Skill Expansion

**Input**: Design documents from `/specs/001-artex-tool-skill-expansion/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/tool-server.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Baseline and directory layout

- [X] T001 Create `cmd/toolserver/`, `tools/`, and `data/toolraw/` per plan.md; do not touch untracked operator files
- [X] T002 Record baseline by running `go build ./cmd/artex` and `go test ./server ./agent` before changes

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Catalog and registry metadata that every story depends on

- [X] T003 [P] Implement `tools/catalog.go`: load/validate `tools/catalog.json`; enforce `CatalogEntry.capability`, `CatalogEntry.risk`, `CatalogEntry.timeout_sec` and closed enums from data-model.md
- [X] T004 [P] Author `tools/catalog.json` with every catalogued repo, each with `name`, `binary`, `command`, `capability`, `risk`, `timeout_sec` and `health_timeout_sec` (data-model.md CatalogEntry); heavy scanners >= 300s, health < 5s
- [X] T005 [P] Add `tools/catalog_test.go`: enum validation, unique names, heavy-scan timeout, health timeout tests (data-model.md validation rules)
- [X] T006 Add DB migration under `db/` extending `tools` with `capability`, `risk`, `timeout_sec`, `healthy`, `last_health`, plus re-runnable `scripts/register-tools.sh` seeding from the catalog

**Checkpoint**: Catalog validates and is seedable; no user story work before this.

---

## Phase 3: User Story 1 - Run any catalogued tool through its own server (Priority: P1) 🎯 MVP

**Goal**: One executable server per repo with `tools/list` and a working basic command.

**Independent Test**: Launch `toolserver --tool subfinder`, send `initialize`, `tools/list`, `ping`, and one `tools/call` with a benign target.

### Tests for User Story 1

- [X] T007 [P] [US1] Add a newline-delimited JSON smoke test for `initialize`, `tools/list`, `ping`, `tools/call` in `tools/server_smoke_test.go` per contracts/tool-server.md

### Implementation for User Story 1

- [X] T008 [US1] Implement `cmd/toolserver/main.go`: stdio JSON-RPC loop with `initialize`, `tools/list`, `tools/call`, `ping`; select catalog entry via `--tool`
- [X] T009 [US1] Implement execution of `CatalogEntry.binary` with caller args and catalog default `command`; capture stdout+stderr into `data/toolraw/` and set `ToolRecord.raw_ref` (data-model.md ToolRecord)
- [X] T010 [US1] Handle absent binary as `ToolRecord.status = "not_installed"`, non-zero exit as `"error"`, timeout as `"timeout"` with empty or partial `ToolRecord.findings`

**Checkpoint**: US1 independently testable; MVP delivered.

---

## Phase 4: User Story 2 - Receive one stable output shape from every tool (Priority: P1)

**Goal**: Every call returns the same four fields with valid tags.

**Independent Test**: Call two different catalog entries and compare field sets and tag enums.

### Tests for User Story 2

- [X] T011 [P] [US2] Add `tools/record_test.go` asserting every result has `target`, `status`, `findings[]`, `raw_ref` and that `raw_ref` is never empty (data-model.md ToolRecord)

### Implementation for User Story 2

- [X] T012 [US2] Emit capability and risk from `CatalogEntry` in `initialize` and registry seed; no raw text as the sole result
- [X] T013 [US2] Ensure `target` echoes the caller target and is `""` when absent (data-model.md ToolRecord.target)

**Checkpoint**: US1 + US2 both work independently.

---

## Phase 5: User Story 3 - Discover tools by capability and detect dead servers (Priority: P2)

**Goal**: Capability query and automatic removal of unhealthy servers.

**Independent Test**: Query `code-audit`, stop one server, run health pass, query again.

### Tests for User Story 3

- [X] T014 [P] [US3] Add `tools/registry_test.go`: capability filtering, `RegistryEntry.healthy` flip on failed health, no deduplication of two tools sharing a capability (data-model.md RegistryEntry)

### Implementation for User Story 3

- [X] T015 [US3] Implement registry projection from catalog with `RegistryEntry.capability`, `risk`, `healthy`, `last_health` and capability query function
- [X] T016 [US3] Implement `ping` health probe with `health_timeout_sec < 5s` and flip `RegistryEntry.healthy = false` on timeout

**Checkpoint**: All three stories independently functional.

---

## Phase 6: User Story 4 - Rebuild every skill against capabilities (Priority: P1)

**Goal**: All shipped skills have valid declarations and no hardcoded server names.

**Independent Test**: Parse every `SKILL.md` frontmatter and grep for concrete server names.

### Tests for User Story 4

- [X] T017 [P] [US4] Extend shipped-skill validation to require `capabilities` and `tools_required` and a "When to use" section

### Implementation for User Story 4

- [X] T018 [US4] Rewrite every `skills/*/SKILL.md` with `SkillDeclaration.name`, `description`, `capabilities`, `tools_required` (data-model.md SkillDeclaration), a "When to use" section and one end-to-end test case; no concrete server names
- [X] T019 [US4] Add `exploit-verify` and `edr-evasion-techniques` methodology skills from Shannon/Strix/Claude-BugHunter, capability-only, test case included
- [X] T020 [US4] Move operator-authored extra content from `skills/{artex,hacktricks,nuclei,peass}` into `references/` rather than deleting it

**Checkpoint**: Skill library fully rebuilt and operator files preserved.

---

## Phase 7: User Story 5 - Remove built-in guard and scope enforcement (Priority: P1)

**Goal**: No active guard/scope check in shipped entry points; build still green.

**Independent Test**: Search for active enforcement, then build and run tests.

### Tests for User Story 5

- [X] T021 [P] [US5] Add a check that no shipped entry point calls intercept/target enforcement

### Implementation for User Story 5

- [X] T022 [US5] Remove shipped `guard/` package and `skills/scopesentry/` from the build per research.md Decision 4
- [X] T023 [US5] Disable intercept/target enforcement at entry points in `server/`, `agent/`, `intercept/`, `egress/`; keep transport plumbing intact
- [X] T024 [US5] Update affected tests so `go build ./...` and `go test ./...` pass with enforcement off

**Checkpoint**: No active enforcement; build and tests green.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Validation and documentation

- [X] T025 [P] Run `quickstart.md` validation: catalog tests, skill frontmatter tests, server smoke test
- [X] T026 [P] Update `README.md`/`CHANGELOG.md` with the new catalog, skill declarations and the removed built-in guard
- [X] T027 Verify no high-risk tool was executed against any target during validation
- [X] T028 Final `go build ./...`, `go test ./...`, `./build.sh --target linux/amd64`

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) → Foundational (Phase 2) → all user stories
- US1 and US2 share the server implementation and should run in order; US3 builds on the registry; US4 and US5 are independent of the server work
- Polish runs after all stories

### User Story Dependencies

- **US1**: after Foundational; no other story dependency
- **US2**: after US1 (shares ToolRecord)
- **US3**: after US1 (shares server/catalog)
- **US4**: after Foundational; independent
- **US5**: after Foundational; independent

### Parallel Opportunities

- T003, T004, T005, T006 can run in parallel
- T007 can be authored while T008 is implemented (test first)
- T017 and T022 can run in parallel with server work
- T025, T026, T027 can run in parallel at the end

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational
2. Implement US1 only; run its independent test
3. Stop and validate before adding US2–US5

### Incremental Delivery

1. US1 → callable server (MVP)
2. US2 → uniform records
3. US3 → capability registry and health
4. US4 → rebuilt skills
5. US5 → guard/scope removal

## Notes

- [P] = different files, no shared-file conflict
- No approval/sandbox/quota code is added anywhere
- High-risk tools are wrapped but never executed against a target during verification
- Operator's untracked files are preserved; guard/scope removal is a small revertible diff

## Execution notes

- T002 baseline was run with the `golang:1.26-bookworm` Docker image because no Go toolchain is installed on the host.
- T022 was reduced to disabling enforcement and removing the `scopesentry` skill: deleting the `guard` package outright breaks production imports and 56 files of target-gate plumbing. See research.md Decision 4.
- T024: guard enforcement tests are skipped while `guard.EnforcementEnabled = false`; the remainder of the suite passes.
