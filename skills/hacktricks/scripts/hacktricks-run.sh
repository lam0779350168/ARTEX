#!/usr/bin/env bash
# HackTricks Local Runner — spin up local instance for offline reference
# Usage: ./hacktricks-run.sh [start|stop|restart|update|lang <code>]

set -euo pipefail

HT_DIR="/app/data/hacktricks"
COMPOSE_FILE="$HT_DIR/docker-compose.yml"
LANG_FILE="$HT_DIR/.ht_lang"

# Default language
DEFAULT_LANG="master"  # English

get_lang() {
  if [[ -f "$LANG_FILE" ]]; then
    cat "$LANG_FILE"
  else
    echo "$DEFAULT_LANG"
  fi
}

set_lang() {
  echo "$1" > "$LANG_FILE"
}

case "${1:-start}" in
  start)
    if [[ ! -d "$HT_DIR" ]]; then
      echo "[*] Cloning HackTricks..."
      git clone https://github.com/HackTricks-wiki/hacktricks "$HT_DIR"
    fi
    cd "$HT_DIR"
    LANG="$(get_lang)"
    echo "[*] Starting HackTricks (lang: $LANG) on http://localhost:3337 ..."
    export HT_LANG="$LANG"
    docker compose up -d
    echo "[*] Ready at http://localhost:3337 (build takes ~2-5 min on first run)"
    ;;
  stop)
    cd "$HT_DIR" 2>/dev/null && docker compose down
    echo "[*] Stopped"
    ;;
  restart)
    cd "$HT_DIR" && docker compose restart
    echo "[*] Restarted"
    ;;
  update)
    if [[ ! -d "$HT_DIR" ]]; then
      echo "[*] Not cloned yet. Run 'start' first."
      exit 1
    fi
    cd "$HT_DIR"
    echo "[*] Pulling latest..."
    git pull
    docker compose build
    docker compose up -d
    echo "[*] Updated"
    ;;
  lang)
    if [[ -z "${2:-}" ]]; then
      echo "Current language: $(get_lang)"
      echo "Available: master (en), es, fr, de, ja, ko, zh, pt, it, tr, vi, ru, af, el, hi, pl, sr, sw, uk"
      exit 0
    fi
    set_lang "$2"
    echo "[*] Language set to: $2"
    echo "[*] Run 'restart' to apply"
    ;;
  status)
    cd "$HT_DIR" 2>/dev/null && docker compose ps
    ;;
  logs)
    cd "$HT_DIR" 2>/dev/null && docker compose logs -f
    ;;
  *)
    echo "Usage: $0 [start|stop|restart|update|lang <code>|status|logs]"
    echo "  lang codes: master (en), es, fr, de, ja, ko, zh, pt, it, tr, vi, ru, af, el, hi, pl, sr, sw, uk"
    exit 1
    ;;
esac