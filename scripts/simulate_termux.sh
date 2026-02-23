#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIM_HOME="${SIM_HOME:-/tmp/termux-home-sim}"

rm -rf "$SIM_HOME"
mkdir -p "$SIM_HOME"

echo "[sim] HOME=$SIM_HOME"
TARGET_HOME="$SIM_HOME" "$REPO_DIR/project/scripts/install.sh" --non-interactive --dry-run
TARGET_HOME="$SIM_HOME" "$REPO_DIR/project/scripts/install.sh" --non-interactive

echo "[sim] Rodando novamente para validar retomada (deve pular etapas concluídas)"
TARGET_HOME="$SIM_HOME" "$REPO_DIR/project/scripts/install.sh" --non-interactive

# Isolar HOME para que o hub use o diretório simulado
export HOME="$SIM_HOME"
source "$SIM_HOME/.termux/aliases.sh"
"$SIM_HOME/.termux/hub/hub.sh" add "simulacao" "teste" "Teste de simulação termux"
"$SIM_HOME/.termux/hub/hub.sh" search "simulacao"

echo "[sim] Estrutura criada:"
find "$SIM_HOME/.termux" -maxdepth 4 -type f | sort
