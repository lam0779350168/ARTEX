#!/usr/bin/env bash
# HackTricks Content Search — search local repo for techniques
# Usage: ./ht-search.sh "search term" [path]

set -euo pipefail

HT_DIR="/app/data/hacktricks"
QUERY="${1:-}"
SUBPATH="${2:-src}"

if [[ -z "$QUERY" ]]; then
  echo "Usage: $0 \"search term\" [subpath]"
  echo "  subpath defaults to 'src' (e.g., 'src/pentesting-web', 'src/linux-hardening')"
  exit 1
fi

if [[ ! -d "$HT_DIR" ]]; then
  echo "[*] HackTricks not found at $HT_DIR. Run ./hacktricks-run.sh start first."
  exit 1
fi

cd "$HT_DIR"

echo "[*] Searching for: $QUERY"
echo "[*] In: $SUBPATH"
echo ""

# Search with context
grep -r -i --include="*.md" -n -B2 -A2 "$QUERY" "$SUBPATH" 2>/dev/null | \
  head -200 | \
  sed 's/^/  /'

echo ""
echo "[*] Done. Use ./hacktricks-run.sh start to browse full content at http://localhost:3337"