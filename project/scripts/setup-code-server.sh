#!/bin/bash
# ~/.termux/scripts/setup-code-server.sh

echo "=== Setup Code-Server ==="

if ! command -v code-server >/dev/null; then
    npm install -g code-server
fi

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
