# 🚀 DOCUMENTAÇÃO COMPLETA: Dev Stack Termux Samsung Galaxy S24 Ultra

**Arquivo único com TUDO: scripts, setup, configurações, troubleshooting**

**Atualização:** Fevereiro 23, 2026 | Termux 2025.01.18+ | Node.js 20+ LTS | One UI 8.0+

---

## 📋 ÍNDICE RÁPIDO

```
1. SETUP INICIAL (10 min)
2. HUB MCP CENTRALIZADO (15 min)
3. DUAL-SHELL TERMUX ↔ UBUNTU (20 min)
4. CLI LLMS UNIFICADO (10 min)
5. DEV WEBAPP NEXT.JS + SUPABASE (15 min)
6. CODE-SERVER (VS CODE WEB) (10 min)
7. ALIASES E WORKFLOW (5 min)
8. AI HUB CENTRALIZADO (20 min)
9. TROUBLESHOOTING & DICAS (referência)

⏱️ TEMPO TOTAL: ~2 horas pra setup completo
```

---

## 1. SETUP INICIAL TERMUX (10 min)

### 1.1 Instalação F-Droid (IMPORTANTE!)

```bash
# NUNCA use Google Play (desatualizado)
# Baixe via F-Droid: https://f-droid.org/en/packages/com.termux/
# Ou GitHub: https://github.com/termux/termux-app/releases

# Após instalar e abrir Termux:
apt-key add <(curl https://termux.org/packages/termux-apt-repo.asc)
apt update
apt upgrade -y
```

### 1.2 Instalar Ferramentas Base

```bash
#!/bin/bash
# Copie e cole isso no Termux

pkg update && pkg upgrade -y

pkg install -y \
    git \
    nodejs-lts \
    npm \
    python3 \
    build-essential \
    curl \
    wget \
    zsh \
    git-credential-manager \
    openssh \
    postgresql \
    redis

# Verificar instalações
echo "✓ Verificando..."
node --version
npm --version
git --version
python3 --version
```

### 1.3 Configurar Git SSH (GitHub)

```bash
#!/bin/bash
# ~/.termux/scripts/setup-git-ssh.sh

echo "=== Configurando Git SSH ==="

# Gerar chave SSH Ed25519
ssh-keygen -t ed25519 -C "seu-email@example.com" -f ~/.ssh/id_ed25519 -N ""

# Copiar chave pública
echo "✓ Copie a chave abaixo e cole em GitHub → Settings → SSH Keys"
cat ~/.ssh/id_ed25519.pub

# Testar conexão
echo ""
echo "Pressione Enter após adicionar a chave no GitHub..."
read

ssh -T git@github.com

# Configurar Git global
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@example.com"

echo "✓ Git SSH configurado!"
```

**Execute:**
```bash
bash ~/.termux/scripts/setup-git-ssh.sh
```

### 1.4 Instalar Zsh + Powerlevel10k

```bash
#!/bin/bash
# ~/.termux/scripts/setup-zsh.sh

echo "=== Setup Zsh + Powerlevel10k ==="

pkg install -y zsh

# Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Plugins úteis
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "✓ Zsh + Powerlevel10k instalado!"
```

**Execute:**
```bash
bash ~/.termux/scripts/setup-zsh.sh
chsh -s zsh
```

### 1.5 Configurar .zshrc (MAIN CONFIG)

```bash
#!/bin/bash
# Crie este arquivo: ~/.zshrc

cat > ~/.zshrc << 'ZSHRC_EOF'
# ========== OH-MY-ZSH ==========
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    command-not-found
    colored-man-pages
    extract
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ========== LLM CONFIG (Centralizado) ==========
export LLM_CONFIG_DIR="$HOME/.config/llm"

# Carregar variáveis de ambiente
if [ -f "$LLM_CONFIG_DIR/.env" ]; then
    set -a
    source "$LLM_CONFIG_DIR/.env"
    set +a
fi

# Carregar aliases LLM
if [ -f "$LLM_CONFIG_DIR/aliases/llm-aliases.sh" ]; then
    source "$LLM_CONFIG_DIR/aliases/llm-aliases.sh"
fi

# ========== HUB MCP (Central Knowledge) ==========
export HUB_DIR="$HOME/.termux/hub"
if [ -f "$HUB_DIR/aliases.sh" ]; then
    source "$HUB_DIR/aliases.sh"
fi

# ========== ALIASES ESSENCIAIS ==========
alias ls='ls -lah --color=auto'
alias ll='ls -lh'
alias pj='cd ~/projects'
alias dev='npm run dev'
alias build='npm run build'
alias test='npm test'
alias start='npm start'

# Git
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gc='git commit -m'
alias ga='git add'
alias gd='git diff'
alias gco='git checkout'

# Utilidades
alias c='clear'
alias h='history'
alias mkdir='mkdir -pv'

# Dev
alias startx11='termux-x11 :0 -xstartup "dbus-launch --exit-with-session xfce4-session"'
alias ubuntu='proot-distro login ubuntu'

# ========== FUNÇÕES CUSTOM ==========

# Criar projeto Next.js rápido
next-project() {
    local name="${1:-my-app}"
    npx create-next-app@latest "$name" \
        --typescript \
        --tailwind \
        --app \
        --eslint \
        --import-alias "@/*" \
        --skip-install=false
    cd "$name"
    npm install @supabase/supabase-js @supabase/auth-helpers-nextjs
}

# Sincronizar config LLM
sync-llm() {
    echo "Sincronizando config LLM..."
    bash ~/.termux/hub/sync/termux-sync.sh
    echo "✓ Sincronizado!"
}

# Ver status de tudo
dev-status() {
    echo "=== DEV ENVIRONMENT STATUS ==="
    echo "Node.js: $(node --version)"
    echo "npm: $(npm --version)"
    echo "Git: $(git --version)"
    echo ""
    echo "=== LLM PROVIDERS ==="
    which claude && echo "Claude Code: ✅" || echo "Claude Code: ❌"
    which codex && echo "OpenAI Codex: ✅" || echo "OpenAI Codex: ❌"
    echo ""
    echo "=== HUB MCP ==="
    [ -d "$HUB_DIR" ] && echo "Hub MCP: ✅" || echo "Hub MCP: ❌"
    echo ""
    echo "=== STORAGE ==="
    echo "Home: $(du -sh ~ | cut -f1)"
    echo "Projects: $(du -sh ~/projects 2>/dev/null | cut -f1)"
}

# ========== PATH ==========
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# ========== FINAL ==========
# Welcome message
echo "🚀 Termux Dev Environment Ready!"
ZSHRC_EOF

# Aplicar
source ~/.zshrc
```

**Execute:**
```bash
bash ~/.termux/scripts/create-zshrc.sh
source ~/.zshrc
```

## 2. HUB MCP CENTRALIZADO (15 min)

### 2.1 Criar Estrutura do Hub

```bash
#!/bin/bash
# ~/.termux/scripts/setup-hub.sh

echo "=== Setup Hub MCP Centralizado ==="

# Criar diretórios
mkdir -p ~/.termux/hub/{wrappers,sync,cache,docs}

# Criar database.db (SQLite)
cat > ~/.termux/hub/init-db.sql << 'SQL_EOF'
CREATE TABLE IF NOT EXISTS skills (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE,
    category TEXT,
    description TEXT,
    examples TEXT,
    usage TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO skills (name, category, description, examples, usage) VALUES
('git clone', 'git', 'Clone um repositório', 'git clone https://github.com/user/repo', 'git clone <url>'),
('npm install', 'npm', 'Instalar dependências', 'npm install / npm i', 'npm install [package]'),
('npm run dev', 'npm', 'Iniciar dev server', 'npm run dev', 'npm run dev'),
('git push', 'git', 'Enviar commits', 'git push origin main', 'git push [remote] [branch]'),
('git pull', 'git', 'Baixar atualizações', 'git pull origin main', 'git pull [remote] [branch]'),
('docker run', 'docker', 'Executar container', 'docker run -it ubuntu bash', 'docker run [options] image'),
('find', 'system', 'Procurar arquivos', 'find . -name "*.js"', 'find [path] -name [pattern]'),
('grep', 'system', 'Buscar em arquivos', 'grep -r "pattern" .', 'grep [options] pattern [files]'),
('curl', 'network', 'Fazer requisições HTTP', 'curl -X POST http://api.example.com', 'curl [url]');

CREATE TABLE IF NOT EXISTS aliases (
    id INTEGER PRIMARY KEY,
    alias TEXT UNIQUE,
    command TEXT,
    description TEXT
);

INSERT INTO aliases (alias, command, description) VALUES
('pj', 'cd ~/projects', 'Ir para pasta de projetos'),
('dev', 'npm run dev', 'Iniciar dev server'),
('gs', 'git status', 'Ver status do git'),
('gp', 'git push', 'Enviar commits'),
('gl', 'git pull', 'Receber updates'),
('gc', 'git commit -m', 'Fazer commit'),
('startx11', 'termux-x11 :0 -xstartup "dbus-launch --exit-with-session xfce4-session"', 'Iniciar desktop X11');
SQL_EOF

# Criar database
sqlite3 ~/.termux/hub/database.db < ~/.termux/hub/init-db.sql

echo "✓ Hub structure criada!"
```

**Execute:**
```bash
bash ~/.termux/scripts/setup-hub.sh
```

### 2.2 Hub Main Script

```bash
#!/bin/bash
# ~/.termux/hub/hub.sh

HUB_DB="$HOME/.termux/hub/database.db"

hub() {
    local action="$1"
    local query="$2"

    case "$action" in
        ask)
            # Buscar no SQLite
            sqlite3 "$HUB_DB" \
                "SELECT description, usage, examples FROM skills WHERE name LIKE '%$query%' LIMIT 1"
            ;;
        search)
            # Buscar por categoria
            sqlite3 "$HUB_DB" \
                "SELECT name, description FROM skills WHERE category='$query' OR description LIKE '%$query%'"
            ;;
        list)
            # Listar tudo
            sqlite3 "$HUB_DB" "SELECT DISTINCT category FROM skills"
            ;;
        list-category)
            # Listar por categoria
            sqlite3 "$HUB_DB" \
                "SELECT name FROM skills WHERE category='$query'"
            ;;
        add)
            # Adicionar skill
            local name="$2"
            local category="$3"
            local description="$4"
            sqlite3 "$HUB_DB" \
                "INSERT INTO skills (name, category, description) VALUES ('$name', '$category', '$description')"
            echo "✓ Skill '$name' adicionado!"
            ;;
        *)
            echo "Hub MCP - Central Knowledge System"
            echo ""
            echo "Uso:"
            echo "  hub ask <comando>        - Buscar documentação"
            echo "  hub search <palavra>     - Buscar por palavra-chave"
            echo "  hub list                 - Listar categorias"
            echo "  hub list-category <cat>  - Listar skills de categoria"
            echo "  hub add <name> <cat> <desc> - Adicionar skill"
            ;;
    esac
}

# Se chamado como script direto
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && hub "$@"
```

### 2.3 Hub Aliases

```bash
#!/bin/bash
# ~/.termux/hub/aliases.sh

# Hub functions
alias hub='~/.termux/hub/hub.sh'
alias hub-ask='hub ask'
alias hub-search='hub search'
alias hub-list='hub list'
alias hub-add='hub add'

# Git examples
hub-git-clone() {
    echo "git clone https://github.com/user/repo"
    echo "git clone https://github.com/user/repo my-custom-name"
}

# NPM examples
hub-npm() {
    echo "npm install              # Instalar dependências"
    echo "npm install package-name # Instalar pacote específico"
    echo "npm run dev              # Rodar dev server"
    echo "npm run build            # Build produção"
    echo "npm test                 # Rodar testes"
}

# Docker examples
hub-docker() {
    echo "docker ps                # Listar containers"
    echo "docker run -it ubuntu    # Rodar container interativo"
    echo "docker build -t name .   # Build image"
}
```

## 3. DUAL-SHELL TERMUX ↔ UBUNTU (20 min)

### 3.1 Instalar proot-distro

```bash
#!/bin/bash
# ~/.termux/scripts/setup-proot.sh

echo "=== Setup proot-distro ==="

# Instalar proot-distro
pkg install -y proot-distro

# Instalar Ubuntu
proot-distro install ubuntu

# Configurar para usar home compartilhada
proot-distro login ubuntu
```

### 3.2 Script de Sincronização

```bash
#!/bin/bash
# ~/.termux/hub/sync/termux-sync.sh

echo "=== Sincronizando Termux ↔ Ubuntu ==="

TERMUX_HOME="$HOME"
UBUNTU_HOME="/data/data/com.termux/files/home/ubuntu/root"  # Ajustar conforme seu setup

# Criar symlinks para shared directories
echo "Criando symlinks..."

# Projects
ln -sf "$TERMUX_HOME/projects" "$UBUNTU_HOME/projects" 2>/dev/null
ln -sf "$TERMUX_HOME/.config" "$UBUNTU_HOME/.config" 2>/dev/null
ln -sf "$TERMUX_HOME/.ssh" "$UBUNTU_HOME/.ssh" 2>/dev/null

# Sincronizar .env files
if [ -f "$TERMUX_HOME/.config/llm/.env" ]; then
    cp "$TERMUX_HOME/.config/llm/.env" "$UBUNTU_HOME/.config/llm/.env"
    chmod 600 "$UBUNTU_HOME/.config/llm/.env"
fi

# Sincronizar Hub MCP
rsync -av "$TERMUX_HOME/.termux/hub/" "$UBUNTU_HOME/.termux/hub/" \
    --exclude="cache/*" \
    --exclude="*.log" 2>/dev/null

echo "✓ Sincronização completa!"
```

## 4. CLI LLMS UNIFICADO (10 min)

### 4.1 Instalar CLIs Oficiais

```bash
#!/bin/bash
# ~/.termux/scripts/setup-llms.sh

echo "=== Setup LLM CLIs ==="

# Claude Code (RECOMENDADO)
npm install -g claude-code

# OpenAI CLI
npm install -g @openai/openai

# Groq CLI
npm install -g @groq/groq-cli

# Verificar instalações
echo ""
echo "=== Verificando instalações ==="
which claude && echo "✓ Claude Code" || echo "✗ Claude Code"
which codex && echo "✓ OpenAI Codex" || echo "✗ OpenAI Codex"
which groq && echo "✓ Groq CLI" || echo "✗ Groq CLI"
```

### 4.2 Criar Config Centralizada LLM

```bash
#!/bin/bash
# ~/.config/llm/config.json

mkdir -p ~/.config/llm

cat > ~/.config/llm/config.json << 'JSON_EOF'
{
  "llm_providers": {
    "claude": {
      "cli": "claude",
      "enabled": true,
      "default": true,
      "model": "claude-opus-4.5"
    },
    "openai": {
      "cli": "openai",
      "enabled": true,
      "model": "gpt-5.1"
    },
    "groq": {
      "cli": "groq",
      "enabled": true,
      "model": "llama-3.3-70b"
    },
    "gemini": {
      "method": "curl",
      "enabled": true,
      "model": "gemini-2.5-flash"
    }
  },
  "aliases": {
    "cld": "claude",
    "cod": "openai",
    "grq": "groq",
    "gem": "gemini"
  }
}
JSON_EOF
```

### 4.4 LLM Aliases Unificados

```bash
#!/bin/bash
# ~/.config/llm/aliases/llm-aliases.sh

# ===== CLAUDE CODE =====
alias cld='claude'
alias cld-code='claude --code'
alias cld-chat='claude -p'

# ===== OPENAI =====
alias cod='openai'
alias cod-fix='openai --suggest'

# ===== GROQ =====
alias grq='groq'
alias grq-fast='groq --model llama-3.3-70b'

# ===== GEMINI (via curl) =====
gemini-ask() {
    local query="$@"
    curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" \
        -H "Content-Type: application/json" \
        -H "x-goog-api-key: $GOOGLE_API_KEY" \
        -d "{\"contents\": [{\"parts\": [{\"text\": \"$query\"}]}]}" | jq -r '.contents[0].parts[0].text' 2>/dev/null || echo "Erro ao chamar Gemini"
}
alias gem='gemini-ask'

# ===== UNIVERSAL COMMAND =====
ask() {
    local provider="${DEFAULT_LLM_PROVIDER:-claude}"
    local query="$@"

    case "$provider" in
        claude)
            echo "$query" | claude -
            ;;
        groq)
            grq "$query"
            ;;
        openai)
            cod "$query"
            ;;
        gemini)
            gem "$query"
            ;;
        *)
            echo "Provider desconhecido: $provider"
            ;;
    esac
}
```

## 6. CODE-SERVER

### 6.1 Instalar Code-Server

```bash
#!/bin/bash
# ~/.termux/scripts/setup-code-server.sh

echo "=== Setup Code-Server ==="

npm install -g code-server

# Criar config
mkdir -p ~/.config/code-server

cat > ~/.config/code-server/config.yaml << 'YAML_EOF'
bind-addr: 127.0.0.1:8080
auth: password
password: termuxdev
cert: false
YAML_EOF

echo "✓ Code-Server instalado!"
echo "Inicie com: code-server"
echo "Acesse: http://127.0.0.1:8080"
```
