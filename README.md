# Uiuiui - Termux DevStack (estruturado)

Este repositório é uma **DevStack modular e automatizada** para Termux, projetada para transformar seu Android em um ambiente de desenvolvimento profissional.

## Principais Recursos

- **Instalador Inteligente**: Instalação por etapas com capacidade de retomada (checkpoint).
- **Hub MCP Centralizado**: Sistema de gerenciamento de conhecimento e skills via SQLite.
- **Dual-Shell**: Integração perfeita entre Termux nativo e Ubuntu (proot-distro).
- **CLI LLMs Unificado**: Acesso centralizado a Claude, OpenAI, Groq e Gemini.
- **Dev Stack Web**: Pronto para Next.js, Supabase e Code-Server (VS Code Web).

## Estrutura do Repositório

- `DOCUMENTACAO_COMPLETA.md` → Guia detalhado de todo o ecossistema.
- `project/scripts/` → Scripts de setup automatizados.
- `project/hub/` → Utilitário Hub e sincronização Termux ↔ Ubuntu.
- `project/config/` → Configurações de shell (Zsh) e LLMs.
- `scripts/simulate_termux.sh` → Simulador de ambiente para testes.

## Instalação

Para iniciar o instalador interativo:

```bash
bash project/scripts/install.sh
```

### Modo não interativo (Automático)

```bash
bash project/scripts/install.sh --non-interactive
```

## Comandos Principais Pós-Instalação

```bash
# Carregar aliases
source ~/.termux/aliases.sh

# Setup base (pacotes do sistema)
~/.termux/scripts/setup-base.sh

# Setup de chaves SSH
~/.termux/scripts/setup-git-ssh.sh seu-email@exemplo.com

# Usar o Hub
hub add "minha nota"
hub search nota
```

## Documentação Detalhada

Consulte o arquivo [DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md) para o guia completo de configuração e uso de cada componente.

## Testes e Simulação

Para validar o ambiente de forma segura em uma pasta temporária:

```bash
bash scripts/simulate_termux.sh
```
