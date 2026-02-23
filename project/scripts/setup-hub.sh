#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUB_SCRIPT="$SCRIPT_DIR/../hub/hub.sh"

echo "=== Configurando Hub MCP Centralizado ==="
mkdir -p "$HOME/.termux/hub"

if [[ -f "$HUB_SCRIPT" ]]; then
    bash "$HUB_SCRIPT" list > /dev/null
    echo "✓ Hub structure inicializada!"
else
    echo "ERRO: Script hub.sh não encontrado em $HUB_SCRIPT"
    exit 1
fi
