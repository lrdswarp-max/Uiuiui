#!/bin/bash
# ~/.termux/scripts/setup-proot.sh

echo "=== Setup proot-distro ==="

# Instalar proot-distro
pkg install -y proot-distro

# Instalar Ubuntu
proot-distro install ubuntu

# Configurar para usar home compartilhada
# proot-distro login ubuntu

echo "Para entrar no Ubuntu: proot-distro login ubuntu"
