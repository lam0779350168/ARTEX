# Data Model: ARTEX Tool & Skill Expansion

## CatalogEntry

Source of truth for one catalogued repo. Stored in `tools/catalog.json`.

| Field | Type | Rule |
|-------|------|------|
| `name` | string | Unique; used as server identity and tool name |
| `binary` | string | Executable name or path; may be absent at runtime |
| `command` | string | Default argument template for the basic command |
| `capability` | enum | One of `recon.passive`, `recon.active`, `scan.vuln`, `exploit`, `osint`, `cloud`, `code-audit` |
| `risk` | enum | One of `read-only`, `active-scan`, `exploit` |
| `timeout_sec` | number | Heavy scanners >= 300; health timeout separate and < 5 |

Relationships: one CatalogEntry → one server process; many CatalogEntry → one capability.

## ToolRecord

Uniform result of a `tools/call`.

| Field | Type | Rule |
|-------|------|------|
| `target` | string | Echo of the requested target, or `""` when no target was supplied |
| `status` | enum | `ok`, `error`, `not_installed`, `timeout` |
| `findings` | array | Zero or more finding objects; may be empty |
| `raw_ref` | string | Path to the stored raw stdout+stderr; always present |

State transitions: `not_installed` and `timeout` are terminal; `error` may still carry partial findings.

## RegistryEntry

The discoverable projection of a CatalogEntry.

| Field | Type | Rule |
|-------|------|------|
| `name` | string | From CatalogEntry |
| `capability` | enum | From CatalogEntry |
| `risk` | enum | From CatalogEntry |
| `healthy` | boolean | False when last health check timed out |
| `last_health` | timestamp | Updated by each health pass |

Rules: a capability query returns only entries with `healthy = true`; a failed health pass flips `healthy` immediately.

## SkillDeclaration

Frontmatter of each `skills/<name>/SKILL.md`.

| Field | Type | Rule |
|-------|------|------|
| `name` | string | Required; matches directory |
| `description` | string | Required |
| `capabilities` | array[string] | Required; values from the capability enum |
| `tools_required` | array[string] | Required; names of required capabilities/tools, never server identities |

Body rules: contains a "When to use" section and at least one end-to-end test case.

## Validation rules

- Capability and risk enums are closed; an unknown value fails catalog validation.
- `raw_ref` is never empty on a completed call.
- A skill whose `capabilities` does not intersect the catalog's capability set still loads; the gap is reported at call time.
- Operator-authored files under a skill directory are never deleted by the rebuild.
