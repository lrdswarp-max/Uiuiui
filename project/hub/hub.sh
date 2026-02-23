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
            echo ""
            echo "Exemplos:"
            echo "  hub ask git clone"
            echo "  hub search npm"
            echo "  hub list-category git"
            ;;
    esac
}

# Se chamado como script direto
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && hub "$@"
