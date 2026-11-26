#!/usr/bin/env bash
# Check every catalogued tool inside the running ARTEX container: binary presence
# and the wrapper's ping response. With ARTEX_TOOL_SMOKE=1, also send a real
# tools/call with `--help` to each wrapper (no target is scanned).
#   ARTEX_CONTAINER=artex-global-artex-1 ./scripts/check-tools.sh
#   ARTEX_TOOL_SMOKE=1 ARTEX_CONTAINER=artex-global-artex-1 ./scripts/check-tools.sh
set -euo pipefail

cd "$(dirname "$0")/.."
CONTAINER="${ARTEX_CONTAINER:-artex-global-artex-1}"
OUT="${ARTEX_TOOL_HEALTH:-data/tool-health.json}"
mkdir -p "$(dirname "$OUT")"

docker exec "$CONTAINER" test -x /usr/local/bin/toolserver || {
  echo "toolserver not installed in $CONTAINER" >&2
  exit 1
}

python3 - "$CONTAINER" "$OUT" "${ARTEX_TOOL_SMOKE:-0}" <<'PY'
import json, os, shlex, subprocess, sys
container, out, smoke = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
catalog = json.load(open("tools/catalog.json"))["tools"]
ping = '{"jsonrpc":"2.0","id":1,"method":"ping","params":{}}\n'
results = []
for t in catalog:
    name, binary = t["name"], t["binary"]
    found = subprocess.run(
        ["docker", "exec", container, "sh", "-c", f'command -v "{binary}"'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    healthy, call = False, None
    if found:
        p = subprocess.run(
            ["docker", "exec", container, "sh", "-c",
             f'printf %s {json.dumps(ping)} | timeout 3 /usr/local/bin/toolserver --tool "{name}"'],
            capture_output=True, text=True)
        healthy = '"status":"ok"' in p.stdout
        if smoke:
            req = {"jsonrpc": "2.0", "id": 2, "method": "tools/call",
                   "params": {"name": name, "arguments": {"target": "", "args": "--help"}}}
            # Give a slow-but-working tool its own catalog timeout plus slack.
            budget = max(t["timeout_sec"] + 15, 25)
            p = subprocess.run(
                ["docker", "exec", container, "sh", "-c",
                 f'printf %s {shlex.quote(json.dumps(req))} | timeout {budget} /usr/local/bin/toolserver --tool {shlex.quote(name)}'],
                capture_output=True, text=True)
            try:
                call = json.loads(p.stdout.strip().splitlines()[0])["result"]["status"]
            except (IndexError, KeyError, ValueError):
                call = "timeout" if p.returncode == 124 else "no_response"
    results.append({"name": name, "capability": t["capability"], "binary": binary,
                    "installed": found, "ping": healthy, "call": call})
with open(out, "w") as f:
    json.dump({"tools": results}, f, indent=2)
print(f"checked {len(results)} tools: "
      f"{sum(r['installed'] for r in results)} binaries present, "
      f"{sum(r['ping'] for r in results)} wrappers healthy")
print("missing binaries: " + ", ".join(r["name"] for r in results if not r["installed"]))
print("unhealthy wrappers: " + ", ".join(r["name"] for r in results if r["installed"] and not r["ping"]))
if smoke:
    print("calls: " + ", ".join(f"{s}={sum(r['call'] == s for r in results)}"
                                for s in sorted({r["call"] for r in results if r["call"]})))
    print("not called: " + ", ".join(r["name"] for r in results if r["call"] in (None, "no_response")))
PY
