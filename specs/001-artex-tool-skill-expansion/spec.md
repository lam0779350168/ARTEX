# Feature Specification: ARTEX Tool & Skill Expansion

> **Scope revision (2026-11-26)**: the operator decided to keep ARTEX core (guard, intercept, target gate) unchanged. Only skill-level restrictions were removed. Guard-related items below are superseded and were not implemented.
**Feature Branch**: `001-artex-tool-skill-expansion`

**Created**: 2026-11-26

**Status**: Draft

**Input**: User description: "Rebuild all ARTEX skills and add executable MCP wrappers for every security tool repo, capability-based tool registry, standardized JSON output, per-server timeout and health check; remove existing guard and scope enforcement; no new approval or sandbox controls"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run any catalogued security tool through its own server (Priority: P1)

An operator selects a tool from the expanded catalogue and calls it through that tool's own server. The server starts, advertises at least one callable tool, and executes the tool's simplest documented command (for example `subfinder -d example.com -silent`) and returns a structured result. The same flow works for low-risk CLI scanners and for high-risk tools such as exploitation frameworks, credential access tools and C2 clients, because every catalogued repo gets the same executable treatment.

**Why this priority**: Without a callable server per repo, none of the downstream capability resolution or skill work has anything to call. This is the minimum viable slice.

**Independent Test**: Start one server, ask it to list its tools, then call its basic command and inspect the returned record.

**Acceptance Scenarios**:

1. **Given** a catalogued tool repo, **When** its server starts, **Then** its tool list contains at least one tool.
2. **Given** a started server, **When** the basic command is called with a valid target, **Then** the call completes and returns a structured record.
3. **Given** a catalogued tool whose executable is absent from the environment, **When** its basic command is called, **Then** the record reports an explicit absent-executable status instead of a fabricated result.

---

### User Story 2 - Receive one stable output shape from every tool (Priority: P1)

An operator or downstream agent never parses raw tool text. Every tool call returns the same structured shape containing the target, a status, a list of findings and a reference to the raw output. Every tool is also labelled with one capability from the agreed set and one risk class, so callers can decide what to do with the result without knowing the tool's name.

**Why this priority**: The current mix of raw text and tool-specific formats prevents any automated consumer from working reliably.

**Independent Test**: Call two different tools and compare their result shapes field by field.

**Acceptance Scenarios**:

1. **Given** any successful tool call, **When** the result is returned, **Then** it contains `target`, `status`, `findings[]` and `raw_ref`.
2. **Given** any tool call, **When** its capability is read, **Then** the value is one of `recon.passive`, `recon.active`, `scan.vuln`, `exploit`, `osint`, `cloud`, `code-audit`.
3. **Given** any tool call, **When** its risk class is read, **Then** the value is one of `read-only`, `active-scan`, `exploit`.

---

### User Story 3 - Discover tools by capability and detect dead servers (Priority: P2)

A planner asks the registry for every tool that satisfies a capability, for example `code-audit`, and receives a list without having to know any server name. Each server also answers a lightweight health inquiry quickly; a server that stops answering is removed from the registry automatically so the planner never dispatches work to it.

**Why this priority**: Capability discovery is what makes the skill layer independent of concrete tool names; health removal prevents silent failures.

**Independent Test**: Query a capability, stop one server, wait for the health interval, then query again and confirm the stopped server is absent.

**Acceptance Scenarios**:

1. **Given** several registered servers, **When** a planner requests one capability, **Then** all and only tools with that capability are returned.
2. **Given** a healthy server, **When** its health inquiry is made, **Then** it answers in under five seconds.
3. **Given** a server that no longer answers, **When** the next health pass runs, **Then** that server is absent from subsequent capability queries.
4. **Given** a heavy scanning tool, **When** its per-server timeout is read, **Then** it is at least 300 seconds and is independent of the global default.

---

### User Story 4 - Rebuild every skill against capabilities instead of server names (Priority: P1)

An operator opens any skill in the skill library and finds a valid declaration containing its name, description, required capabilities and required tools, plus an explicit "when to use" section and at least one end-to-end test case. No skill names a concrete server; resolution happens at call time. Existing skill content authored by the operator is preserved rather than discarded.

**Why this priority**: The operator asked for a full skill rebuild; partial rebuild leaves inconsistent declarations across the library.

**Independent Test**: Parse the declaration of every skill in the library and check the required fields, then search the library for hardcoded server names.

**Acceptance Scenarios**:

1. **Given** any skill in the library, **When** its declaration is parsed, **Then** it contains `name`, `description`, `capabilities[]` and `tools_required[]`.
2. **Given** any skill, **When** its body is read, **Then** it states when to use it and includes at least one end-to-end test case.
3. **Given** the whole skill library, **When** searched for concrete server names, **Then** no skill declares a server by name.
4. **Given** a skill directory with operator-authored content, **When** the rebuild runs, **Then** that content remains available as reference material.

---

### User Story 5 - Remove the built-in guard and scope enforcement (Priority: P1)

An operator who will implement their own approval and scope layer wants the built-in interception guard and scope/target gates removed from this build, so they do not interfere with their own implementation. After removal the product still builds and its remaining test suite passes.

**Why this priority**: The operator explicitly requires this before applying their own guard layer; leaving the built-ins in place would double-enforce and conflict.

**Independent Test**: Search the build for guard and scope enforcement entry points, then compile and run the remaining tests.

**Acceptance Scenarios**:

1. **Given** a rebuilt tree, **When** guard and scope enforcement entry points are searched for, **Then** no active enforcement path remains.
2. **Given** the rebuilt tree, **When** it is built, **Then** the build completes.
3. **Given** the rebuilt tree, **When** the remaining tests run, **Then** they pass.
4. **Given** high-risk tool wrappers, **When** they are called, **Then** no approval or sandbox check is inserted by this feature.

### Edge Cases

- A catalogued tool has no executable in the runtime image: the call returns an explicit absent-executable status rather than hanging or returning empty findings.
- A tool produces output larger than the result envelope: raw output is referenced externally and the structured record stays small.
- A tool exits non-zero or emits malformed output: the record reports failure, keeps whatever findings were parsed and still includes a raw reference.
- Two tools share the same capability tag: the registry returns both and does not deduplicate by name.
- A health inquiry times out exactly at the threshold: the server is treated as unhealthy and removed on that pass.
- A skill references a capability for which no server is currently registered: the skill loads, and the missing capability is reported at call time rather than at load time.
- An operator-authored skill directory contains extra files and references: the rebuild keeps them as reference material rather than overwriting them.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The product MUST expose one independently startable server per catalogued tool repo.
- **FR-002**: Each server MUST advertise at least one callable tool through its tool list.
- **FR-003**: Each server MUST execute its basic documented command when called.
- **FR-004**: Every tool call MUST return a structured record with `target`, `status`, `findings[]` and `raw_ref`.
- **FR-005**: Every tool MUST be labelled with exactly one capability from the agreed capability set.
- **FR-006**: Every tool MUST be labelled with exactly one risk class from the agreed risk set.
- **FR-007**: Heavy scanning tools MUST have a per-server timeout of at least 300 seconds, independent of the global default.
- **FR-008**: The registry MUST answer capability queries without requiring the caller to know a server name.
- **FR-009**: Every server MUST answer a health inquiry in under five seconds.
- **FR-010**: A server that fails its health inquiry MUST be removed from capability query results automatically.
- **FR-011**: Every skill in the library MUST declare `name`, `description`, `capabilities[]` and `tools_required[]` in its frontmatter.
- **FR-012**: Every skill MUST state when to use it and include at least one end-to-end test case.
- **FR-013**: Skills MUST declare capabilities only and MUST NOT name a concrete server.
- **FR-014**: Operator-authored skill content MUST be preserved as reference material during the rebuild.
- **FR-015**: The built-in interception guard and scope/target gate enforcement MUST be removed from the build.
- **FR-016**: High-risk tools MUST be executable through their wrappers without an approval or sandbox check added by this feature.
- **FR-017**: The product MUST still build and pass its remaining test suite after the removal in FR-015.
- **FR-018**: A tool whose executable is missing MUST report that condition explicitly in the structured record.

### Key Entities *(include if feature involves data)*

- **Tool Server**: One catalogued repo's executable entry point; has a name, a tool list, a capability tag, a risk class, a timeout, a health state and a raw-output reference.
- **Tool Record**: The uniform result of a call; has target, status, findings and a raw reference.
- **Capability**: A discoverable classification used by planners and skills; one of the seven agreed values.
- **Skill Declaration**: Frontmatter of a skill; has name, description, required capabilities, required tools, a "when to use" section and at least one end-to-end test case.
- **Registry Entry**: The discoverable view of a tool server; includes health state and is filtered by capability.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every catalogued repo has a server that lists at least one tool and executes its basic command successfully on a benign test target.
- **SC-002**: 100% of tool calls return all four required structured fields, with no raw text as the sole result.
- **SC-003**: 100% of tools carry a valid capability tag and a valid risk class.
- **SC-004**: Capability queries return the expected tool set for each of the seven capabilities without server names in the request.
- **SC-005**: Health inquiries complete in under five seconds for every live server; a stopped server disappears from queries within one health interval.
- **SC-006**: 100% of skills pass frontmatter validation and contain a "when to use" section and one end-to-end test case; zero skills name a concrete server.
- **SC-007**: No active guard or scope enforcement path remains, and the build plus remaining test suite pass.
- **SC-008**: Heavy scan tools expose a timeout of at least 300 seconds in their per-server configuration.

## Assumptions

- The operator will supply their own approval, scope and sandbox layer after this build; this feature deliberately adds none.
- Tool binaries that the operator wants callable are present in the runtime image; absent binaries are reported rather than installed by this feature.
- The agreed capability and risk vocabularies are fixed and provided in the operator's brief.
- "Basic command" means the smallest documented invocation with a benign target such as `example.com`, as given in the brief.
- Operator-authored skill directories under the existing skill library are to be preserved, not discarded.
- High-risk tools are wrapped for executability but are not executed against any target as part of this feature's verification.
