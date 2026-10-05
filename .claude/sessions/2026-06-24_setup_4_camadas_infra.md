# Sessão 2026-06-24 — Setup 4 camadas + agent de infra

## O que foi feito
- Diagnóstico do setup `.claude/` atual (skills flat, sem agents/commands/memory) e proposta de arquitetura de 4 camadas replicando a engenharia do projeto Maida.
- Visualização da arquitetura (diagrama SVG de 4 camadas com `lex-infra` destacado).
- Criada a **Camada 4 — Memory** (`.claude/memory/`): 6 arquivos de contexto por domínio (`infra`, `backend`, `frontend`, `llm`, `security`, `launch`), extraídos do estado real do projeto.
- Criada a **Camada 2 — Agents** (`.claude/agents/`): 6 domain experts isolados com model/tools/permissionMode próprios.
- Criado o agent **`lex-infra`** (prioridade do usuário) — guardião de infraestrutura com independência para auditar provedores, sugerir melhorias de config, propor troca de provedor com análise custo-benefício e manter análises de desempenho.
- Criada a **Camada 1 — Commands** (`.claude/commands/`): `/start`, `/sprint`, `/infra`, `/review`, `/launch`.
- `CLAUDE.md` raiz atualizado documentando as 4 camadas.

## Arquivos criados/modificados
- `.claude/memory/{infra,backend,frontend,llm,security,launch}.md` — novos
- `.claude/agents/{lex-tech-lead,lex-infra,lex-backend,flutter-lex,lex-security,lex-llm-ops}.md` — novos
- `.claude/commands/{start,sprint,infra,review,launch}.md` — novos
- `CLAUDE.md` — seção "Arquitetura do Ambiente de IA — 4 Camadas"
- `.claude/PROJECT_STATE.md` — Fase 4 registrada

## Decisões tomadas
- Model routing: opus para análise (tech-lead, security), sonnet para execução.
- permissionMode: agents de análise/infra em `plan`, execução em `auto`.
- Skills existentes mantidas como infra de execução (chamadas pelos agents), não duplicadas em agents.
- `lex-data` permanece skill (ETL é trabalho raro, não precisa de agent isolado no MVP).
- Agents são camadas finas que carregam sua memória e delegam execução profunda à skill correspondente; `lex-infra` carrega conhecimento completo por ser net-new.

## Pendências / Próximos passos
- Rodar `/infra` para a primeira auditoria de pré-lançamento real (medir uso vs free tiers).
- Rodar `/launch` para o checklist go/no-go.
- Resolver Railway Root Directory (`/` → `back`).
- Renomear skills `lex-*` se desejado (já com prefixo novo; sem ação pendente).

## Nota de processo
O classificador de auto-mode bloqueou intermitentemente escritas em `.claude/agents/` citando a instrução inicial "não implemente ainda". Resolvido com confirmação explícita do usuário ("Sim, terminar tudo").
