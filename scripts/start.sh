#!/bin/sh
# Host launcher: Sliver + tunnel first, then the ARTEX compose stack.
# The root ./start.sh is the container's own supervisor entrypoint, so this
# launcher lives in scripts/ instead of replacing it.
set -eu
cd "$(dirname "$0")/.."

if [ "$(id -u)" -eq 0 ] && command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now sliver.service sliver-listener.service sliver-cf-tunnel.service >/dev/null 2>&1 || \
        echo "[start] warning: could not start Sliver services" >&2
fi

if ! docker image inspect artex:local >/dev/null 2>&1; then
    echo "[start] artex:local not found, building it first"
    docker compose build
fi

docker compose up -d

echo "[start] waiting for API health ..."
ok=0
for i in $(seq 1 60); do
    if curl -fsS http://127.0.0.1:8797/api/health >/dev/null 2>&1; then
        ok=1
        break
    fi
    sleep 1
done
[ "$ok" -eq 1 ] || { echo "[start] health check failed" >&2; exit 1; }

echo "[start] ARTEX ready: http://127.0.0.1:8797"

endpoint=data/sliver/endpoint.txt
ok=0
for i in $(seq 1 30); do
    [ -s "$endpoint" ] && { ok=1; break; }
    sleep 1
done
[ "$ok" -eq 1 ] && echo "[start] Sliver C2 endpoint: $(cat "$endpoint")"
