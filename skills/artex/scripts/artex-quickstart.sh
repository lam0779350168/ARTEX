#!/usr/bin/env bash
# ARTEX Quick Start Script — run this to deploy ARTEX locally for authorized testing
# Usage: ./artex-quickstart.sh [baarai|global] [--dev]

set -euo pipefail

REPO="${1:-baarai}"  # baarai or global
MODE="${2:-prod}"    # prod or dev

case "$REPO" in
  baarai)
    REPO_URL="https://github.com/BaaRai/ARTEX.git"
    DIR="ARTEX"
    ;;
  global)
    REPO_URL="https://github.com/jiwoochris/artex-global.git"
    DIR="artex-global"
    ;;
  *)
    echo "Usage: $0 [baarai|global] [--dev]"
    exit 1
    ;;
esac

if [[ "$MODE" == "--dev" || "$MODE" == "dev" ]]; then
  DEV_MODE=1
else
  DEV_MODE=0
fi

echo "[*] Cloning $REPO_URL ..."
if [[ -d "$DIR" ]]; then
  echo "[*] Directory exists, pulling latest..."
  cd "$DIR" && git pull && cd ..
else
  git clone "$REPO_URL" "$DIR"
fi

cd "$DIR"

echo "[*] Setting up .env ..."
if [[ ! -f .env ]]; then
  cp .env.example .env
  # Generate secure defaults
  POSTGRES_PWD=$(openssl rand -base64 32 | tr -d '/+=' | head -c 32)
  SECRET_KEY=$(openssl rand -base64 32)
  JWT_KEY=$(openssl rand -base64 32)
  sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$POSTGRES_PWD/" .env
  sed -i "s/^# ARTEX_SECRET_KEY=.*/ARTEX_SECRET_KEY=$SECRET_KEY/" .env
  sed -i "s/^# ARTEX_JWT_KEY=.*/ARTEX_JWT_KEY=$JWT_KEY/" .env
  echo "[*] Generated .env with random passwords. Edit .env to add your LLM API keys."
else
  echo "[*] .env already exists, skipping."
fi

if [[ $DEV_MODE -eq 1 ]]; then
  echo "[*] Starting in DEV mode (hot reload) ..."
  ./dev.sh
else
  echo "[*] Building and starting containers ..."
  docker compose up -d --build
  echo ""
  echo "[*] Waiting for startup..."
  sleep 5
  echo "[*] Setup token:"
  docker compose logs artex 2>/dev/null | grep -i "setup token" || echo "  (check: docker compose logs artex | grep -i token)"
  echo ""
  echo "[*] Open http://localhost:8787 and enter the setup token."
  echo "[*] Then: System → LLM → add your provider → System → Settings → Worker count ≥ 2"
fi