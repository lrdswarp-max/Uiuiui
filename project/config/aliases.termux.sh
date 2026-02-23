#!/usr/bin/env bash
# source ~/.termux/aliases.sh

# ===== PROJETOS =====
alias pj='cd ~/projects'
alias pj-new='cd ~/projects && mkdir'
alias pj-ls='ls ~/projects'

# ===== DESENVOLVIMENTO =====
alias dev='npm run dev'
alias build='npm run build'
alias test='npm test'
alias lint='npm run lint'
alias start='npm start'

# ===== GIT (ESSENCIAL) =====
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gc='git commit -m'
alias ga='git add'
alias gd='git diff'
alias gco='git checkout'
alias glg='git log --graph --oneline --all'

# ===== TERMUX/SISTEMA =====
alias c='clear'
alias h='history'
alias mkdir='mkdir -pv'
alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias du='du -sh'

# ===== DEV TOOLS =====
alias vim='nvim'
alias ls='ls -lah --color=auto'
alias ll='ls -lh'
alias la='ls -la'

# ===== HUB MCP =====
alias hub='$HOME/.termux/hub/hub.sh'
alias hub-ask='hub ask'
alias hub-search='hub search'
alias hub-list='hub list'
alias hub-add='hub add'
