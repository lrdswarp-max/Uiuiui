#!/usr/bin/env bash
set -euo pipefail

echo "=== Sincronizando Termux ↔ Ubuntu ==="

TERMUX_HOME="${TERMUX_HOME:-$HOME}"
# Ajuste este caminho conforme o local de instalação do seu proot-distro
UBUNTU_ROOT="$TERMUX_HOME/.proot-distro/ubuntu/root"

if [[ ! -d "$UBUNTU_ROOT" ]]; then
    # Tentar outro caminho comum mencionado na documentação
    UBUNTU_ROOT="/data/data/com.termux/files/home/ubuntu/root"
fi

if [[ ! -d "$UBUNTU_ROOT" ]]; then
    echo "AVISO: Root do Ubuntu não encontrado em $UBUNTU_ROOT. Verifique seu setup do proot-distro."
    # Não vamos sair com erro para permitir que o script de instalação continue se o proot ainda não foi instalado
    exit 0
fi

# Criar symlinks para shared directories
echo "Criando symlinks em $UBUNTU_ROOT..."

mkdir -p "$TERMUX_HOME/projects"
mkdir -p "$UBUNTU_ROOT/root"

# Criar links dentro do ubuntu para pastas do termux
ln -sf "$TERMUX_HOME/projects" "$UBUNTU_ROOT/root/projects" 2>/dev/null || true
ln -sf "$TERMUX_HOME/.config" "$UBUNTU_ROOT/root/.config" 2>/dev/null || true
ln -sf "$TERMUX_HOME/.ssh" "$UBUNTU_ROOT/root/.ssh" 2>/dev/null || true

# Sincronizar Hub MCP
mkdir -p "$UBUNTU_ROOT/root/.termux"
if command -v rsync >/dev/null 2>&1; then
    rsync -av "$TERMUX_HOME/.termux/hub/" "$UBUNTU_ROOT/root/.termux/hub/" \
        --exclude="cache/*" \
        --exclude="*.log" 2>/dev/null || true
else
    cp -r "$TERMUX_HOME/.termux/hub/"* "$UBUNTU_ROOT/root/.termux/hub/" 2>/dev/null || true
fi

echo "✓ Sincronização completa!"
