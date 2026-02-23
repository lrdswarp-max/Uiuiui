#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log "=== Setup Code-Server ==="

if ! command -v npm >/dev/null 2>&1; then
  err "npm não encontrado. Rode setup-base.sh primeiro."
  exit 1
fi

run "npm install -g code-server"

log "Configurando code-server..."
mkdir -p "$HOME/.config/code-server"

CONFIG_FILE="$HOME/.config/code-server/config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" <<YAML_EOF
bind-addr: 127.0.0.1:8080
auth: password
password: termuxdev
cert: false
YAML_EOF
  log "Arquivo de configuração criado em $CONFIG_FILE (senha padrão: termuxdev)"
else
  log "Arquivo de configuração já existe."
fi

log "✓ Code-Server instalado!"
log "Inicie com: code-server"
