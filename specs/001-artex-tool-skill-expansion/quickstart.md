# Quickstart: ARTEX Tool & Skill Expansion

> **Scope revision (2026-11-26)**: the operator decided to keep ARTEX core (guard, intercept, target gate) unchanged. Only skill-level restrictions were removed. Guard-related items below are superseded and were not implemented.
## Prerequisites

- Go 1.26 toolchain (`go version`).
- Repository checked out at `/root/artex-global` with `tools/catalog.json` present.
- The binaries named in the catalog are optional at verification time; absent binaries are reported, not installed.

## Build

```bash
cd /root/artex-global
go build ./cmd/toolserver
./build.sh --target linux/amd64
```

## Server smoke test (benign target only)

```bash
printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
  '{"jsonrpc":"2.0","id":3,"method":"ping","params":{}}' \
  | ./toolserver --tool subfinder
```

Expected: one tool in `tools/list`, `ping` returns `{"status":"ok"}` promptly, no error frames.

## Registry and catalog checks

```bash
go test ./tools/...          # catalog enum + timeout validation
go test ./server/...         # shipped skill frontmatter validation
```

Expected: every catalog entry has a valid capability and risk, heavy scanners have `timeout_sec >= 300`, and every shipped skill parses with `capabilities` and `tools_required`.

## Skill rebuild check

```bash
grep -R 'sliver-cmd\|msf-run\|artex-run\|toolserver ' skills/*/SKILL.md
```

Expected: no hits — skills name capabilities only.

## Guard/scope removal check

```bash
go build ./... && go test ./...
```

Expected: build and remaining tests pass with no active intercept/target enforcement in the shipped entry points.

## Note

No high-risk tool is executed against any target during this quickstart. Only `initialize`, `tools/list`, `ping`, catalog validation and skill validation run.
