#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

EMAIL="${1:-}"
if [[ -z "$EMAIL" ]]; then
  err "Uso: $0 <email-github>"
  exit 1
fi

need_cmd git
need_cmd ssh-keygen

mkdir -p "$HOME/.ssh"
KEY_PATH="$HOME/.ssh/id_ed25519"

if [[ ! -f "$KEY_PATH" ]]; then
  run "ssh-keygen -t ed25519 -C '$EMAIL' -f '$KEY_PATH' -N ''"
else
  log "Chave já existe: $KEY_PATH"
fi

run "git config --global user.email '$EMAIL'"
run "git config --global user.name 'Termux Dev'"
run "git config --global init.defaultBranch main"
run "git config --global pull.rebase false"

log "Chave pública (adicione no GitHub):"
cat "$KEY_PATH.pub"
