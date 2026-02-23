#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log "=== Setup LLM CLIs ==="

# Claude Code (RECOMENDADO)
run "npm install -g claude-code"

# OpenAI CLI
run "npm install -g @openai/openai"

# Groq CLI
run "npm install -g @groq/groq-cli"

# Verificar instalações
log "=== Verificando instalações ==="
for cmd in claude openai groq; do
  if command -v "$cmd" >/dev/null 2>&1; then
    log "✓ $cmd"
  else
    log "✗ $cmd"
  fi
done
