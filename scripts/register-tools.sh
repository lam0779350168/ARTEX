#!/usr/bin/env bash
# Seed the tools table from tools/catalog.json, bind each tool only to agents
# whose role needs its capability, and defer its schema until it is called.
# Safe to re-run. Override ARTEX_PSQL_CMD to point at another psql, e.g.
#   ARTEX_PSQL_CMD="docker exec -i artex-global-postgres-1 psql -U artex -d artex"
set -euo pipefail

cd "$(dirname "$0")/.."
read -r -a PSQL <<< "${ARTEX_PSQL_CMD:-psql}"
export PGPASSWORD="${PGPASSWORD:-}"

python3 - tools/catalog.json <<'PY' | "${PSQL[@]}" -At -q
import json, sys
catalog = json.load(open(sys.argv[1]))
# Capability → agents whose role needs it. Planner/goals/mainagent stay read-side;
# reporter/auto use their own built-ins. Worker/pentest execute.
cap_agents = {
    "recon.passive": ["worker", "pentest", "planner", "goals", "mainagent"],
    "recon.active":  ["worker", "pentest"],
    "scan.vuln":     ["worker", "pentest", "retester"],
    "exploit":       ["worker", "pentest"],
    "osint":         ["worker", "pentest", "planner", "goals", "mainagent"],
    "cloud":         ["worker", "pentest"],
    "code-audit":    ["worker", "pentest"],
}
caps = {t["capability"] for t in catalog["tools"]}
assert caps == set(cap_agents), f"unmapped capability: {caps - set(cap_agents)}"
names = [t["name"].replace("'", "''") for t in catalog["tools"]]
print("BEGIN;")
# Drop catalog tools removed from a newer catalog, but never user-created tools.
print(f"DELETE FROM tools WHERE capability <> '' AND key NOT IN ({','.join(repr(n) for n in names)});")
for t in catalog["tools"]:
    name = t["name"].replace("'", "''")
    desc = f'{t["name"]} — {t["capability"]} / {t["risk"]}'.replace("'", "''")
    schema = json.dumps({"type": "object", "properties": {
        "target": {"type": "string"}, "args": {"type": "string"}}})
    schema = schema.replace("'", "''")
    agents = json.dumps(cap_agents[t["capability"]]).replace("'", "''")
    # toolserver reads JSON-RPC from stdin; build the request in Python so target
    # and free-form args are JSON-escaped, then pipe it into the per-tool server.
    py = ('import json,sys; print(json.dumps({"jsonrpc":"2.0","id":1,"method":"tools/call",'
          '"params":{"name":sys.argv[1],"arguments":{"target":sys.argv[2],"args":sys.argv[3]}}}))')
    command = (f"python3 -c '{py}' {t['name']} {{target}} {{args}} "
               f"| toolserver --tool {t['name']} --catalog /app/tools/catalog.json")
    command_json = json.dumps(command)[1:-1].replace("'", "''")
    print(f"""
INSERT INTO tools (key, system, description, schema, agents, enabled, kind, exec,
                   capability, risk, timeout_sec, healthy, deferred)
VALUES ('{name}', false, '{desc}', '{schema}'::jsonb, '{agents}'::jsonb, true, 'command',
        '{{"command":"{command_json}"}}'::jsonb, '{t["capability"]}', '{t["risk"]}',
        {t["timeout_sec"]}, true, true)
ON CONFLICT (key) DO UPDATE SET
  description=EXCLUDED.description, schema=EXCLUDED.schema, kind=EXCLUDED.kind,
  exec=EXCLUDED.exec, enabled=true, agents=EXCLUDED.agents, deferred=true,
  capability=EXCLUDED.capability, risk=EXCLUDED.risk, timeout_sec=EXCLUDED.timeout_sec;
""")
print("COMMIT;")
PY

echo "Registered $(python3 -c 'import json;print(len(json.load(open("tools/catalog.json"))["tools"]))') tools with capability-scoped bindings; schemas deferred until called."
