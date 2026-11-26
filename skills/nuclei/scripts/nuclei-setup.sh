#!/usr/bin/env bash
# Nuclei Setup — install binary, update templates, verify
# Usage: ./nuclei-setup.sh [install|update-templates|verify|all]

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
NUCLEI_BIN="$INSTALL_DIR/nuclei"
TEMPLATE_DIR="$HOME/nuclei-templates"

install_nuclei() {
  echo "[*] Installing Nuclei..."
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  local arch=$(uname -m)
  case "$arch" in
    x86_64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "[!] Unsupported arch: $arch"; exit 1 ;;
  esac

  local url="https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_${os}_${arch}.zip"
  local tmp=$(mktemp -d)
  cd "$tmp"
  echo "[*] Downloading $url..."
  curl -L -f -s -o nuclei.zip "$url"
  unzip -q nuclei.zip
  chmod +x nuclei
  if [[ -w "$INSTALL_DIR" ]]; then
    mv nuclei "$NUCLEI_BIN"
  else
    sudo mv nuclei "$NUCLEI_BIN"
  fi
  cd - >/dev/null
  rm -rf "$tmp"
  echo "[+] Installed: $NUCLEI_BIN"
  nuclei -version
}

update_templates() {
  echo "[*] Updating Nuclei templates..."
  nuclei -update-templates
  echo "[+] Templates updated in: $(nuclei -tl 2>/dev/null | head -1 | awk '{print $NF}' || echo "$TEMPLATE_DIR")"
}

verify_install() {
  echo "[*] Verifying installation..."
  nuclei -version
  echo "[*] Template count:"
  nuclei -tl 2>/dev/null | wc -l || echo "  (run 'nuclei -update-templates' first)"
}

case "${1:-all}" in
  install)
    install_nuclei
    ;;
  update-templates)
    update_templates
    ;;
  verify)
    verify_install
    ;;
  all)
    install_nuclei
    update_templates
    verify_install
    ;;
  *)
    echo "Usage: $0 [install|update-templates|verify|all]"
    exit 1
    ;;
esac