#!/bin/bash
# ~/.termux/scripts/setup-llms.sh

echo "=== Setup LLM CLIs ==="

# Claude Code (RECOMENDADO)
if ! command -v claude >/dev/null; then
    npm install -g claude-code
fi

# OpenAI CLI
if ! command -v openai >/dev/null; then
    npm install -g @openai/openai
fi

# Groq CLI
if ! command -v groq >/dev/null; then
    npm install -g @groq/groq-cli
fi

# Verificar instalações
echo ""
echo "=== Verificando instalações ==="
which claude && echo "✓ Claude Code" || echo "✗ Claude Code"
which openai && echo "✓ OpenAI Codex" || echo "✗ OpenAI Codex"
which groq && echo "✓ Groq CLI" || echo "✗ Groq CLI"
