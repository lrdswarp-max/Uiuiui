#!/usr/bin/env bash
set -euo pipefail

HUB_DB="${HUB_DB:-$HOME/.termux/hub/database.db}"
HUB_DIR="$(dirname "$HUB_DB")"
mkdir -p "$HUB_DIR"

init_db() {
  if [[ ! -f "$HUB_DB" ]]; then
    if ! command -v sqlite3 >/dev/null 2>&1; then
        # Se não tiver sqlite3, fallback para o modo notas (opcional, mas melhor avisar)
        return
    fi
    sqlite3 "$HUB_DB" <<SQL_EOF
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
('git pull', 'git', 'Baixar atualizações', 'git pull origin main', 'git pull [remote] [branch]');
SQL_EOF
  fi
}

hub() {
    local action="${1:-}"
    shift || true

    if ! command -v sqlite3 >/dev/null 2>&1; then
        echo "sqlite3 não encontrado. Por favor, instale com: pkg install sqlite"
        exit 1
    fi

    case "$action" in
        ask)
            local query="${1:-}"
            local q_esc="${query//\'/\'\'}"
            sqlite3 "$HUB_DB" "SELECT description, usage, examples FROM skills WHERE name LIKE '%$q_esc%' LIMIT 1"
            ;;
        search)
            local query="${1:-}"
            local q_esc="${query//\'/\'\'}"
            sqlite3 "$HUB_DB" "SELECT name, description FROM skills WHERE name LIKE '%$q_esc%' OR category LIKE '%$q_esc%' OR description LIKE '%$q_esc%'"
            ;;
        list)
            sqlite3 "$HUB_DB" "SELECT DISTINCT category FROM skills"
            ;;
        add)
            local name="${1:-}"
            local category="${2:-}"
            local description="${3:-}"
            [[ -z "$name" || -z "$category" || -z "$description" ]] && { echo "uso: hub add <name> <cat> <desc>"; exit 1; }
            local n_esc="${name//\'/\'\'}"
            local c_esc="${category//\'/\'\'}"
            local d_esc="${description//\'/\'\'}"
            sqlite3 "$HUB_DB" "INSERT INTO skills (name, category, description) VALUES ('$n_esc', '$c_esc', '$d_esc')"
            echo "✓ Skill '$name' adicionado!"
            ;;
        *)
            echo "Hub MCP - Central Knowledge System"
            echo ""
            echo "Uso:"
            echo "  hub ask <comando>        - Buscar documentação"
            echo "  hub search <palavra>     - Buscar por palavra-chave"
            echo "  hub list                 - Listar categorias"
            echo "  hub add <name> <cat> <desc> - Adicionar skill"
            ;;
    esac
}

init_db
hub "$@"
