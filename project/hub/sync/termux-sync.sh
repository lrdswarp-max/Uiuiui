#!/bin/bash
# ~/.termux/hub/sync/termux-sync.sh

echo "=== Sincronizando Termux ↔ Ubuntu ==="

TERMUX_HOME="$HOME"
# Ajustar conforme seu setup - padrão proot-distro
UBUNTU_HOME="/data/data/com.termux/files/home/.proot-distro/installed-rootfs/ubuntu/home/root"
if [[ ! -d "$UBUNTU_HOME" ]]; then
    # Fallback para outro caminho comum
    UBUNTU_HOME="/data/data/com.termux/files/home/ubuntu/root"
fi
if [[ ! -d "$UBUNTU_HOME" ]]; then
    # Fallback para o caminho relativo ao HOME atual se proot estiver em .proot-distro
    UBUNTU_HOME="$HOME/../usr/var/lib/proot-distro/installed-rootfs/ubuntu/root"
fi

echo "Destino Ubuntu: $UBUNTU_HOME"

if [[ ! -d "$UBUNTU_HOME" ]]; then
    echo "Diretório do Ubuntu não encontrado. Certifique-se de que o Ubuntu está instalado."
    # Tentar criar se for apenas simulado
    # mkdir -p "$UBUNTU_HOME"
else
    # Criar symlinks para shared directories
    echo "Criando symlinks..."

    # Projects
    ln -sf "$TERMUX_HOME/projects" "$UBUNTU_HOME/projects" 2>/dev/null
    ln -sf "$TERMUX_HOME/.config" "$UBUNTU_HOME/.config" 2>/dev/null
    ln -sf "$TERMUX_HOME/.ssh" "$UBUNTU_HOME/.ssh" 2>/dev/null

    # Sincronizar .env files
    if [ -f "$TERMUX_HOME/.config/llm/.env" ]; then
        mkdir -p "$UBUNTU_HOME/.config/llm"
        cp "$TERMUX_HOME/.config/llm/.env" "$UBUNTU_HOME/.config/llm/.env"
        chmod 600 "$UBUNTU_HOME/.config/llm/.env"
    fi

    # Sincronizar Hub MCP
    if command -v rsync >/dev/null 2>&1; then
        rsync -av "$TERMUX_HOME/.termux/hub/" "$UBUNTU_HOME/.termux/hub/" \
            --exclude="cache/*" \
            --exclude="*.log" 2>/dev/null
    else
        echo "rsync não encontrado, usando cp..."
        mkdir -p "$UBUNTU_HOME/.termux/hub"
        cp -r "$TERMUX_HOME/.termux/hub/"* "$UBUNTU_HOME/.termux/hub/" 2>/dev/null
    fi

    echo "✓ Sincronização completa!"
fi
