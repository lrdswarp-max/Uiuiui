#!/usr/bin/env bash
set -euo pipefail

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
err() { printf '[ERRO] %s\n' "$*" >&2; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || { err "Comando não encontrado: $1"; exit 1; }; }

run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] $*"
  else
    log "$*"
    eval "$*" || return $?
  fi
}
