#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIM_HOME="${SIM_HOME:-/tmp/termux-home-sim}"
MOCKS_DIR="$SIM_HOME/mocks"

rm -rf "$SIM_HOME"
mkdir -p "$SIM_HOME"
mkdir -p "$MOCKS_DIR"

# Criar mocks para evitar instalações reais
cat > "$MOCKS_DIR/pkg" <<'MOCK'
#!/bin/bash
echo "[mock pkg] $*"
MOCK
cat > "$MOCKS_DIR/apt" <<'MOCK'
#!/bin/bash
echo "[mock apt] $*"
MOCK
cat > "$MOCKS_DIR/npm" <<'MOCK'
#!/bin/bash
echo "[mock npm] $*"
if [[ "$1" == "install" && "$2" == "-g" ]]; then
    mkdir -p "$HOME/.node_modules_mock/bin"
    touch "$HOME/.node_modules_mock/bin/$3"
fi
MOCK
cat > "$MOCKS_DIR/proot-distro" <<'MOCK'
#!/bin/bash
echo "[mock proot-distro] $*"
if [[ "$1" == "list" ]]; then
    echo "ubuntu installed"
fi
MOCK
cat > "$MOCKS_DIR/curl" <<'MOCK'
#!/bin/bash
echo "[mock curl] $*"
if [[ "$*" == *"ohmyzsh"* ]]; then
    echo "echo 'mock ohmyzsh install'"
fi
MOCK
cat > "$MOCKS_DIR/ssh-keygen" <<'MOCK'
#!/bin/bash
echo "[mock ssh-keygen] $*"
# Extrair o path do arquivo se houver -f
while [[ $# -gt 0 ]]; do
    if [[ "$1" == "-f" ]]; then
        # Garantir que o diretório pai existe
        mkdir -p "$(dirname "$2")"
        touch "$2"
        touch "$2.pub"
        break
    fi
    shift
done
MOCK
touch "$MOCKS_DIR/zsh"
touch "$MOCKS_DIR/nvim"
chmod +x "$MOCKS_DIR/"*

# Adicionar mocks ao PATH e exportar HOME
export PATH="$MOCKS_DIR:$PATH"
export HOME="$SIM_HOME"

echo "[sim] Iniciando simulação em $SIM_HOME"

# 1. Instalação
echo "[sim] 1. Executando install.sh --non-interactive"
TARGET_HOME="$SIM_HOME" bash "$REPO_DIR/project/scripts/install.sh" --non-interactive

# 2. Setup Base
echo "[sim] 2. Executando setup-base.sh"
PKG_BIN=pkg APT_BIN=apt bash "$SIM_HOME/.termux/scripts/setup-base.sh"

# 3. Setup Git/SSH
echo "[sim] 3. Executando setup-git-ssh.sh"
bash "$SIM_HOME/.termux/scripts/setup-git-ssh.sh" test@example.com

# 4. Outros Setups (Zsh, Proot, Code-Server)
echo "[sim] 4. Executando outros setups"
bash "$SIM_HOME/.termux/scripts/setup-zsh.sh"
bash "$SIM_HOME/.termux/scripts/setup-proot.sh"
bash "$SIM_HOME/.termux/scripts/setup-code-server.sh"

# 5. Validar Hub
echo "[sim] 5. Validando Hub"
HUB_SCRIPT="$SIM_HOME/.termux/hub/hub.sh"
"$HUB_SCRIPT" add "teste-sim" "simulacao" "Teste de simulação"
"$HUB_SCRIPT" search teste-sim

echo "[sim] 6. Verificação de arquivos essenciais"
ERRORS=0
check_file() {
    if [[ ! -f "$1" ]]; then
        echo "[erro] Arquivo não encontrado: $1"
        ERRORS=$((ERRORS + 1))
    else
        echo "[ok] $1"
    fi
}

check_file "$SIM_HOME/.termux/aliases.sh"
check_file "$SIM_HOME/.termux/hub/hub.sh"
check_file "$SIM_HOME/.termux/scripts/setup-base.sh"
check_file "$SIM_HOME/.config/llm/config.json"
check_file "$SIM_HOME/.zshrc.template"
check_file "$SIM_HOME/.ssh/id_ed25519"
check_file "$SIM_HOME/.config/code-server/config.yaml"

if [[ $ERRORS -eq 0 ]]; then
    echo "[sim] SUCESSO! Todos os arquivos foram criados corretamente."
else
    echo "[sim] FALHA! $ERRORS erros encontrados."
    exit 1
fi
