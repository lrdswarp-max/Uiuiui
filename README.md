# Uiuiui - Termux DevStack (repo auto-suficiente)

Este repositório está **100% autocontido**: toda a documentação e scripts estão versionados aqui no GitHub, sem depender de download externo.

## Conteúdo local do repositório

- `DOCUMENTACAO_COMPLETA.md` → documento-mestre completo.
- `docs/INDICE_DOCUMENTACAO.md` → índice navegável por seções.
- `project/scripts/` → scripts de instalação e setup.
- `project/hub/` → utilitário hub e sincronização.
- `project/config/` → aliases e configuração de LLM.
- `scripts/simulate_termux.sh` → simulação local do fluxo no estilo Termux.

## Instalação inteligente (interativa + retomada)

```bash
bash project/scripts/install.sh
```

Recursos:
- menu interativo com personalização por componente (aliases, hub, LLM, setup scripts);
- progresso salvo em `~/.termux/.installer/state.env`;
- rollback da etapa atual em caso de falha;
- retomada automática das etapas pendentes na próxima execução.

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
~/.termux/scripts/setup-git-ssh.sh seu-email@dominio.com
hub add "minha anotação"
hub search anotação
```

## Validação local (simulando Termux)

```bash
bash scripts/simulate_termux.sh
```
