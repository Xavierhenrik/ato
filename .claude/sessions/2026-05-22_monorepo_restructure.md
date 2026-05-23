# Sessão 2026-05-22 20:00

## O que foi feito

- Reestruturado o repositório github.com/Xavierhenrik/LCF para monorepo real
- Movidos todos os arquivos Node.js da raiz para `back/` usando `git mv` (renomes preservados no histórico)
- Adicionados docs compartilhados: `docs/ROADMAP.md`, `docs/api-contract.md`
- Adicionados docs do frontend: `front/docs/{SCREENS,FRONTEND_BLUEPRINT,DESIGN_TOKENS}.md`
- Adicionado vault `.claude/` (sessions, PROJECT_STATE.md, skills, hooks)
- Adicionado `CLAUDE.md` principal na raiz do repo
- Atualizado `.gitignore` com glob `**/node_modules/` para cobrir raiz e subdiretórios
- Atualizado `CLAUDE.md` principal: todos os caminhos `back/docs/` → `docs/`, `back/lcf-backend/` → `back/`
- WIP stash restaurado — git aplicou automaticamente nas novas paths (`back/src/...`)

## Arquivos modificados

- `.gitignore` — substituído por versão monorepo com `**/node_modules/`
- `CLAUDE.md` (raiz) — criado: CLAUDE.md principal do projeto
- `back/CLAUDE.md` — renomeado de `CLAUDE.md` (backend-specific, sem mudança de conteúdo)
- `back/src/**` — renomeado de `src/**` (55 arquivos)
- `back/prisma/**` — renomeado de `prisma/**`
- `back/package.json`, `back/package-lock.json`, `back/tsconfig.json` — renomeados
- `back/.env.example`, `back/.eslintrc.js` — renomeados
- `docs/ROADMAP.md`, `docs/api-contract.md` — novos
- `front/docs/SCREENS.md`, `front/docs/FRONTEND_BLUEPRINT.md`, `front/docs/DESIGN_TOKENS.md` — novos
- `.claude/**` — novos (vault completo)

## Commits

- `2c2df2f` — chore: restructure to monorepo (back/ + front/docs + shared docs)
- `d3360fc` — docs: add root CLAUDE.md (principal project context)

## Pendências / Próximos passos

- [ ] **Railway** — atualizar Root Directory de `/` para `back` em Settings → Source
- [ ] Remover manualmente `C:\Projetos\BX\LCF\CLAUDE.md`, `C:\Projetos\BX\LCF\.claude\`, `C:\Projetos\BX\LCF\front\docs\`, `C:\Projetos\BX\LCF\back\docs\` após confirmar repo correto no GitHub
- [ ] Aplicar o WIP stash (5 arquivos modificados em subscriptions + tutor-ia) — fazer commit desses changes

## Decisões tomadas

- `.gitignore` usa `**/node_modules/` em vez de `back/node_modules/` para evitar staging acidental da raiz
- `back/CLAUDE.md` permanece como convenções técnicas do backend; `CLAUDE.md` raiz é o contexto geral do projeto
