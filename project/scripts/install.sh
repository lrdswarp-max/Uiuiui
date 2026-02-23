#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/common.sh"

TARGET_HOME="${TARGET_HOME:-$HOME}"
TERMUX_DIR=""
LLM_DIR=""
STATE_DIR=""
STATE_FILE=""
CURRENT_STEP=""

INCLUDE_SETUP_SCRIPTS=1
INCLUDE_HUB=1
INCLUDE_ALIASES=1
INCLUDE_LLM=1
INTERACTIVE=-1
RESET_STATE=0

STEP_ORDER=(prepare_dirs install_setup_scripts install_hub install_aliases install_llm apply_permissions)
COMPLETED_STEPS=()

usage() {
  cat <<USAGE
Uso: $0 [opções]

Opções:
  --dry-run           Mostra comandos sem executar
  --interactive       Abre menu interativo (padrão em TTY)
  --non-interactive   Sem menu interativo
  --target-home PATH  Define HOME alvo para instalação
  --reset-state       Ignora progresso anterior e reinicia etapas

Instala scripts e configs no layout do Termux em: TARGET_HOME
USAGE
}

init_paths() {
  TERMUX_DIR="$TARGET_HOME/.termux"
  LLM_DIR="$TARGET_HOME/.config/llm"
  STATE_DIR="$TERMUX_DIR/.installer"
  STATE_FILE="$STATE_DIR/state.env"
}

state_write() {
  mkdir -p "$STATE_DIR"
  {
    echo "TARGET_HOME='$TARGET_HOME'"
    echo "INCLUDE_SETUP_SCRIPTS=$INCLUDE_SETUP_SCRIPTS"
    echo "INCLUDE_HUB=$INCLUDE_HUB"
    echo "INCLUDE_ALIASES=$INCLUDE_ALIASES"
    echo "INCLUDE_LLM=$INCLUDE_LLM"
    echo "COMPLETED_STEPS='${COMPLETED_STEPS[*]}'"
  } > "$STATE_FILE"
}

state_load() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
    if [[ -n "${COMPLETED_STEPS:-}" ]]; then
      IFS=' ' read -r -a COMPLETED_STEPS <<< "$COMPLETED_STEPS"
    else
      COMPLETED_STEPS=()
    fi
  fi
}

has_completed_step() {
  local step="$1"
  local s
  for s in "${COMPLETED_STEPS[@]:-}"; do
    [[ "$s" == "$step" ]] && return 0
  done
  return 1
}

mark_completed() {
  local step="$1"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    return 0
  fi
  if ! has_completed_step "$step"; then
    COMPLETED_STEPS+=("$step")
  fi
  state_write
}

manifest_file() {
  local step="$1"
  mkdir -p "$STATE_DIR/manifests" "$STATE_DIR/backups"
  echo "$STATE_DIR/manifests/${step}.log"
}

record_action() {
  local step="$1" action="$2" a="$3" b="${4:-}"
  printf '%s|%s|%s\n' "$action" "$a" "$b" >> "$(manifest_file "$step")"
}

safe_mkdir() {
  local step="$1" dir="$2"
  if [[ ! -d "$dir" ]]; then
    run "mkdir -p '$dir'"
    record_action "$step" remove_dir "$dir"
  fi
}

safe_copy() {
  local step="$1" src="$2" dest="$3"
  local backup
  if [[ -e "$dest" ]]; then
    backup="$STATE_DIR/backups/${step}__$(echo "$dest" | tr '/ ' '__')"
    run "cp -a '$dest' '$backup'"
    record_action "$step" restore "$backup" "$dest"
  else
    record_action "$step" delete "$dest"
  fi
  run "cp '$src' '$dest'"
}

rollback_step() {
  local step="$1"
  local mf
  mf="$(manifest_file "$step")"
  [[ -f "$mf" ]] || return 0

  log "Falha detectada na etapa '$step'. Fazendo rollback apenas desta etapa..."
  while IFS='|' read -r action a b; do
    case "$action" in
      delete)
        [[ -e "$a" ]] && run "rm -f '$a'"
        ;;
      restore)
        [[ -e "$a" ]] && run "cp -a '$a' '$b'"
        ;;
      remove_dir)
        [[ -d "$a" ]] && run "rmdir '$a' 2>/dev/null || true"
        ;;
    esac
  done < <(tac "$mf")
}

run_step() {
  local step="$1" rc=0
  CURRENT_STEP="$step"

  if has_completed_step "$step"; then
    log "Pulando etapa já concluída: $step"
    return 0
  fi

  : > "$(manifest_file "$step")"
  set +e
  ( set -e; "$step" )
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    mark_completed "$step"
    log "Etapa concluída: $step"
    return 0
  fi

  rollback_step "$step"
  err "Etapa falhou: $step. Reexecute para continuar da próxima pendência."
  return 1
}

prepare_dirs() {
  safe_mkdir "$CURRENT_STEP" "$TERMUX_DIR" || return 1
  safe_mkdir "$CURRENT_STEP" "$TERMUX_DIR/scripts" || return 1
  safe_mkdir "$CURRENT_STEP" "$TERMUX_DIR/hub" || return 1
  safe_mkdir "$CURRENT_STEP" "$TERMUX_DIR/hub/sync" || return 1
  safe_mkdir "$CURRENT_STEP" "$LLM_DIR" || return 1
  safe_mkdir "$CURRENT_STEP" "$LLM_DIR/aliases" || return 1
}

install_setup_scripts() {
  [[ "$INCLUDE_SETUP_SCRIPTS" == "1" ]] || { log "Setup scripts desativados pelo usuário"; return 0; }
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/scripts/setup-base.sh" "$TERMUX_DIR/scripts/setup-base.sh" || return 1
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/scripts/setup-git-ssh.sh" "$TERMUX_DIR/scripts/setup-git-ssh.sh" || return 1
}

install_hub() {
  [[ "$INCLUDE_HUB" == "1" ]] || { log "Hub desativado pelo usuário"; return 0; }
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/hub/hub.sh" "$TERMUX_DIR/hub/hub.sh" || return 1
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/hub/sync/termux-sync.sh" "$TERMUX_DIR/hub/sync/termux-sync.sh" || return 1
}

install_aliases() {
  [[ "$INCLUDE_ALIASES" == "1" ]] || { log "Aliases desativados pelo usuário"; return 0; }
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/config/aliases.termux.sh" "$TERMUX_DIR/aliases.sh" || return 1
}

install_llm() {
  [[ "$INCLUDE_LLM" == "1" ]] || { log "Config LLM desativada pelo usuário"; return 0; }
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/config/llm/config.json" "$LLM_DIR/config.json" || return 1
  safe_copy "$CURRENT_STEP" "$ROOT_DIR/config/llm/aliases/llm-aliases.sh" "$LLM_DIR/aliases/llm-aliases.sh" || return 1
}

apply_permissions() {
  run "chmod +x '$TERMUX_DIR/scripts/'*.sh '$TERMUX_DIR/hub/hub.sh' '$TERMUX_DIR/hub/sync/termux-sync.sh' 2>/dev/null || true" || return 1
}

restart_progress() {
  run "rm -rf '$STATE_DIR'"
  COMPLETED_STEPS=()
  state_write
  log "Progresso reiniciado."
}

menu() {
  while true; do
    cat <<MENU

=== Instalador Inteligente Termux ===
Alvo: $TARGET_HOME
Concluídas: ${COMPLETED_STEPS[*]:-(nenhuma)}

[L] Alterar local de instalação (TARGET_HOME)
[Z] Toggle aliases (atual: $INCLUDE_ALIASES)
[S] Toggle setup scripts (atual: $INCLUDE_SETUP_SCRIPTS)
[H] Toggle hub (atual: $INCLUDE_HUB)
[G] Toggle config LLM (atual: $INCLUDE_LLM)
[R] Reiniciar progresso salvo
[I] Iniciar/continuar instalação
[Q] Sair
MENU
    read -r -p "Escolha: " opt
    opt="${opt^^}"

    case "$opt" in
      L)
        read -r -p "Novo TARGET_HOME: " new_home
        [[ -n "$new_home" ]] || { err "valor vazio"; continue; }
        TARGET_HOME="$new_home"
        init_paths
        state_load
        ;;
      Z) INCLUDE_ALIASES=$((1 - INCLUDE_ALIASES)); state_write ;;
      S) INCLUDE_SETUP_SCRIPTS=$((1 - INCLUDE_SETUP_SCRIPTS)); state_write ;;
      H) INCLUDE_HUB=$((1 - INCLUDE_HUB)); state_write ;;
      G) INCLUDE_LLM=$((1 - INCLUDE_LLM)); state_write ;;
      R) restart_progress ;;
      I) return 0 ;;
      Q) exit 0 ;;
      *) err "Opção inválida" ;;
    esac
  done
}

run_install() {
  local step
  for step in "${STEP_ORDER[@]}"; do
    run_step "$step" || return 1
  done

  log "Instalação concluída com sucesso."
  log "Próximos passos:"
  log "  source $TERMUX_DIR/aliases.sh"
  log "  $TERMUX_DIR/scripts/setup-base.sh"
  log "  $TERMUX_DIR/scripts/setup-git-ssh.sh seu@email.com"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) export DRY_RUN=1 ;;
    --interactive) INTERACTIVE=1 ;;
    --non-interactive) INTERACTIVE=0 ;;
    --target-home)
      shift
      TARGET_HOME="${1:-}"
      [[ -n "$TARGET_HOME" ]] || { err "--target-home requer valor"; exit 1; }
      ;;
    --reset-state) RESET_STATE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) err "Opção inválida: $1"; usage; exit 1 ;;
  esac
  shift
done

init_paths
mkdir -p "$STATE_DIR"
state_load

if [[ "$RESET_STATE" == "1" ]]; then
  restart_progress
fi

if [[ "$INTERACTIVE" == "-1" ]]; then
  if [[ -t 0 && -t 1 ]]; then
    INTERACTIVE=1
  else
    INTERACTIVE=0
  fi
fi

if [[ "$INTERACTIVE" == "1" ]]; then
  log "Modo interativo ativado: menu de personalização"
  menu
fi

if [[ "${DRY_RUN:-0}" != "1" ]]; then
  state_write
fi
run_install
