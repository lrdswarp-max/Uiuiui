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
