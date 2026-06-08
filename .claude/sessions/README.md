# Logs de Sessão — LCF

Um arquivo por sessão de trabalho, nomeado `YYYY-MM-DD_HH.md`.

## Por que estes logs existem

Permitem que o Claude Code retome o contexto de onde parou, sem precisar reler todos os arquivos do projeto. O log da última sessão é a primeira coisa lida ao iniciar trabalho.

## Template

```markdown
# Sessão YYYY-MM-DD HH:MM

## O que foi feito
-

## Arquivos modificados
- path/to/file.ts — descrição da mudança

## Critérios de aceite cumpridos
- [ ] descrição do critério

## Pendências / Próximos passos
-

## Decisões tomadas
-
```

## Integração com Obsidian

Abra `C:\Projetos\BX\LCF\.claude\` como vault no Obsidian, ou adicione essa pasta como pasta raiz de um vault maior apontando para `C:\Projetos\BX\LCF\`.

Os arquivos desta pasta + `PROJECT_STATE.md` ficam disponíveis como notas navegáveis. Use o plugin Templates do Obsidian com o template acima para criar logs com um clique.

Para criar o log de hoje no Obsidian: `Ctrl+N` → nome `YYYY-MM-DD_HH` → colar template.
