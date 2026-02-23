# Índice da Documentação Local

Este índice aponta para as seções já incorporadas no arquivo `DOCUMENTACAO_COMPLETA.md`.

## Seções principais

1. Setup inicial Termux
2. Hub MCP centralizado
3. Dual-shell Termux ↔ Ubuntu
4. CLI LLMs unificado
5. Dev WebApp Next.js + Supabase
6. Code-server
7. Aliases e workflow
8. AI Hub centralizado
9. Troubleshooting e dicas

## Navegação rápida por terminal

```bash
# listar títulos principais
rg -n '^## ' DOCUMENTACAO_COMPLETA.md

# abrir um trecho específico (exemplo seção 1)
sed -n '29,286p' DOCUMENTACAO_COMPLETA.md
```

## Observação

Todo o conteúdo originalmente importado já está versionado neste repositório. O fluxo recomendado é usar os scripts de `project/scripts/` e manter `DOCUMENTACAO_COMPLETA.md` como referência-mestre.
