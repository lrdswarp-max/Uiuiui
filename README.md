# Uiuiui - Termux DevStack (estruturado)

Este repositório está organizado como projeto real para Termux, com scripts inteligentes e instalação com retomada por etapa.

## Estrutura

- `DOCUMENTACAO_COMPLETA.md` → material original importado.
- `project/scripts/` → setup base, git/ssh e instalador inteligente.
- `project/hub/` → utilitário hub e sincronização.
- `project/config/` → aliases e configuração de LLM.
- `scripts/simulate_termux.sh` → simulação local do fluxo no estilo Termux.

## Instalador inteligente (interativo + retomada)

```bash
bash project/scripts/install.sh
```

Recursos:
- menu interativo com personalização por componente (aliases, hub, LLM, setup scripts);
- progresso salvo em `~/.termux/.installer/state.env`;
- se uma etapa falhar, faz rollback da etapa atual;
- ao rodar novamente, continua das etapas pendentes (não precisa recomeçar tudo).

## Modo não interativo

```bash
bash project/scripts/install.sh --non-interactive
```

Com reset de progresso:

```bash
bash project/scripts/install.sh --non-interactive --reset-state
```

## Comandos principais pós-instalação

```bash
source ~/.termux/aliases.sh
~/.termux/scripts/setup-base.sh
~/.termux/scripts/setup-git-ssh.sh seu-email@exemplo.com
hub add "minha anotação"
hub search anotação
```

## Download via curl (Google Drive)

```bash
./scripts/fetch_from_drive.sh 1uXh9Z4Y2-qkRn0cpq0auwsLjjNuAYLgE DOCUMENTACAO_COMPLETA.md
```

## Simulação local (como se fosse Termux)

```bash
bash scripts/simulate_termux.sh
```
