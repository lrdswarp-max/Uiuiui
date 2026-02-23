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
if command -v sqlite3 >/dev/null 2>&1; then
    sqlite3 ~/.termux/hub/database.db < ~/.termux/hub/init-db.sql
    echo "✓ Hub structure criada!"
else
    echo "sqlite3 não encontrado, pulando criação do DB."
fi
