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
git config --global core.editor "nvim"

echo "✓ Git SSH configurado!"
