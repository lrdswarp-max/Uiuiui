#!/usr/bin/env bash
set -euo pipefail

HUB_HOME="${HUB_HOME:-$HOME/.termux/hub}"
NOTES="$HUB_HOME/notes.md"
mkdir -p "$HUB_HOME"
touch "$NOTES"

cmd="${1:-help}"
shift || true

case "$cmd" in
  ask)
    q="${*:-}"
    [[ -n "$q" ]] || { echo "uso: hub ask <pergunta>"; exit 1; }
    printf '## %s\n- %s\n\n' "$(date '+%F %T')" "$q" >> "$NOTES"
    echo "Pergunta registrada em $NOTES"
    ;;
  list)
    ls -la "$HUB_HOME"
    ;;
  search)
    term="${1:-}"
    [[ -n "$term" ]] || { echo "uso: hub search <texto>"; exit 1; }
    grep -n "$term" "$NOTES" || true
    ;;
  add)
    note="${*:-}"
    [[ -n "$note" ]] || { echo "uso: hub add <nota>"; exit 1; }
    echo "- $(date '+%F %T') $note" >> "$NOTES"
    echo "Nota adicionada"
    ;;
  help|*)
    cat <<USAGE
hub ask <texto>     Registra uma pergunta
hub add <texto>     Adiciona nota rápida
hub search <texto>  Busca nas notas
hub list            Lista arquivos do hub
USAGE
    ;;
esac
