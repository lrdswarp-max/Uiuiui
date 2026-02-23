#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log "=== Setup proot-distro (Ubuntu) ==="

if command -v proot-distro >/dev/null 2>&1; then
  if ! proot-distro list | grep -q "ubuntu.*installed"; then
    log "Instalando Ubuntu..."
    run "proot-distro install ubuntu"
  else
    log "Ubuntu já instalado."
  fi
else
  err "proot-distro não está instalado. Rode setup-base.sh primeiro."
  exit 1
fi

log "✓ proot-distro configurado!"
log "Para entrar no Ubuntu: proot-distro login ubuntu"
