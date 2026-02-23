#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../../project/config/zshrc"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
    # Se rodando a partir de ~/.termux/scripts/
    TEMPLATE_PATH="$HOME/.zshrc.template"
fi

if [[ -f "$TEMPLATE_PATH" ]]; then
    cp "$TEMPLATE_PATH" "$HOME/.zshrc"
    echo "✓ .zshrc criado com sucesso a partir do template!"
else
    echo "ERRO: Template .zshrc não encontrado."
    exit 1
fi
