#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log "=== Setup Zsh + Powerlevel10k ==="

# Oh-My-Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Instalando Oh-My-Zsh..."
  run 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
else
  log "Oh-My-Zsh já instalado."
fi

# Powerlevel10k
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  log "Instalando Powerlevel10k..."
  run "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '$ZSH_CUSTOM/themes/powerlevel10k'"
fi

# Plugins
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  log "Instalando zsh-autosuggestions..."
  run "git clone https://github.com/zsh-users/zsh-autosuggestions '$ZSH_CUSTOM/plugins/zsh-autosuggestions'"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  log "Instalando zsh-syntax-highlighting..."
  run "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git '$ZSH_CUSTOM/plugins/zsh-syntax-highlighting'"
fi

log "✓ Zsh + Powerlevel10k configurado!"
