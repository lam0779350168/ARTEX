#!/usr/bin/env bash
# PEASS-ng Downloader — fetch latest release with verification
# Usage: ./peass-download.sh [linpeas|linpeas-bin|winpeas|winpeas-ps1|winpeas-bat|macpeas|all]

set -euo pipefail

BASE_URL="https://github.com/carlospolop/PEASS-ng/releases/latest/download"
OUT_DIR="${PEASS_DIR:-/app/data/peass}"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

declare -A FILES=(
  ["linpeas"]="linpeas.sh"
  ["linpeas-bin"]="linpeas_linux_amd64"
  ["winpeas"]="winPEASx64.exe"
  ["winpeas-ps1"]="winPEAS.ps1"
  ["winpeas-bat"]="winPEAS.bat"
  ["macpeas"]="macpeas.sh"
)

download() {
  local key="$1"
  local filename="${FILES[$key]}"
  local url="$BASE_URL/$filename"
  local outfile="$OUT_DIR/$filename"

  echo "[*] Downloading $filename..."
  if curl -L -f -s -o "$outfile" "$url"; then
    chmod +x "$outfile" 2>/dev/null || true
    local sha256=$(sha256sum "$outfile" | awk '{print $1}')
    echo "[+] Saved: $outfile (SHA256: $sha256)"
    echo "$sha256  $filename" >> "$OUT_DIR/SHA256SUMS.txt"
  else
    echo "[!] Failed to download $filename"
    return 1
  fi
}

case "${1:-all}" in
  all)
    for key in "${!FILES[@]}"; do
      download "$key"
    done
    echo ""
    echo "[*] All downloads complete. Checksums in $OUT_DIR/SHA256SUMS.txt"
    echo "[*] Verify against: https://github.com/carlospolop/PEASS-ng/releases/latest"
    ;;
  linpeas|linpeas-bin|winpeas|winpeas-ps1|winpeas-bat|macpeas)
    download "$1"
    ;;
  *)
    echo "Usage: $0 [linpeas|linpeas-bin|winpeas|winpeas-ps1|winpeas-bat|macpeas|all]"
    exit 1
    ;;
esac