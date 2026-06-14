# Sessão 2026-06-12 — Planejamento: Histórico de Conversas do Tutor IA

## O que foi feito
- Diagnóstico do estado atual: persistência só no `DELETE /tutor/session/:id` (fire-and-forget), truncada às últimas 8 msgs (`MAX_HISTORY`), sem `topicId`/`sources`, sem endpoints de leitura, sem UI.
- 4 decisões de produto fechadas: Free 7 dias / PRO ilimitado (gate na leitura) · conversas antigas **read-only** no v1 com CTA "Nova conversa sobre isso" (via agente-invocator — reidratar transcript com tool_use serializado é risco de alucinação; "sem memória entre sessões" segue fixada) · entrada por ícone no `LcfTutorAppBar` (modo padrão) · `mode: simulado` não persiste.
- Spec completa criada: `docs/specs/TUTOR_HISTORY_SPEC.md` (migration, write-through `persistTurn`, contratos dos 3 endpoints `GET/GET/DELETE /tutor/history`, UI Flutter, critérios de aceite, não-objetivos). Referenciada no CLAUDE.md.
- Pacote de delegação noturna criado em `C:\Projetos\BX\LCF\temp-feat-historico\` (FORA do repo): `00_ORCHESTRATOR` (monitor, fases pre-flight → paralelo AG1+AG2 → QA → fix loop máx 2 → finalização + autodestruição do pacote), `01_AGENTE_BACKEND`, `02_AGENTE_FLUTTER`, `03_AGENTE_QA` (auditoria adversarial + contrato cruzado), `04_AGENTE_FIX_TEMPLATE`. Subagentes em Sonnet 4.6 via Task tool. Comando único no README do pacote.

## Arquivos modificados
- docs/specs/TUTOR_HISTORY_SPEC.md — criado (fonte de verdade da feature)
- CLAUDE.md — linha da spec na tabela de documentação
- .claude/PROJECT_STATE.md — decisão 2026-06-12, módulo planejado, log de sessões, frontmatter

## Critérios de aceite cumpridos
- [x] Decisões de produto registradas e não-ambíguas na spec
- [x] Contratos de API definidos antes da implementação paralela (backend ↔ Flutter contra a mesma spec)
- [x] Pacote temp autodestrutível — sem rastros pós-execução em caso de sucesso

## Pendências / Próximos passos
- Rodar o comando único do `temp-feat-historico/README.md` (agendado para madrugada)
- De manhã: revisar branch `feat/tutor-history`, métricas de delegação no session log overnight, mergear e push
- Aplicar `prisma/migrations/tutor_history.sql` em staging + live (manual)

## Decisões tomadas
- Write-through substitui persistToDB; Redis permanece só janela LLM (8 msgs, TTL 4h)
- Experimento de delegação: detalhamento mora na SPEC (doc permanente), prompts de agente finos apontando para ela; QA adversarial com verificação de contrato cruzado; métricas de delegação registradas no log overnight para iterar o método
