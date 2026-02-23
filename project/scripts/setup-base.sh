#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PKG_BIN="${PKG_BIN:-pkg}"
APT_BIN="${APT_BIN:-apt}"

log "Instalando base de desenvolvimento no Termux"
run "$PKG_BIN update"
run "$PKG_BIN upgrade -y"
run "$PKG_BIN install -y git nodejs-lts npm python3 curl wget vim nano zsh openssh"

log "Validação de binários"
for cmd in git node npm python3 curl zsh; do
  if command -v "$cmd" >/dev/null 2>&1; then
    log "ok: $cmd -> $(command -v "$cmd")"
  else
    err "faltando: $cmd"
  fi
done
