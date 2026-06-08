# Sessão 2026-05-02 — Redesign M1 Onboarding

## O que foi feito
- Análise do novo design de onboarding (tela única vs 4 steps)
- Decisão: seguir tela única com simplificação adicional das perguntas
- Reescrita completa da seção Sprint 1 · M1 no ROADMAP
- Atualização do PROJECT_STATE com novos critérios de aceite e migrations

## Decisões tomadas

### Onboarding simplificado para 2 perguntas
Removido: studyGoal, selectedSubjects
Mantido: academicPhase, dailyStudyMins
Motivo: autoavaliação é ruído. O Quiz Diagnóstico e o comportamento do usuário
entregam dados reais de personalização. Reduz fricção no momento de menor tolerância do usuário.

### Quiz Diagnóstico universal
Antes: só para oab_prep
Agora: todos os perfis, dois caminhos (oab / graduation)
Motivo: graduandos também precisam de nivelamento. Quiz de graduação usa questões
em múltiplos níveis para calibrar o nível atual na grade acadêmica.

### Dismiss consciente (não skip)
POST /onboarding/diagnostic/dismiss substitui /diagnostic/skip
Motivo: dismiss requer confirmação explícita no frontend. Distingue "não quero agora"
(skip) de "não quero nunca" (dismiss). nivelamentoConcluido: false em ambos os casos
para analytics — sabemos que a personalização é limitada.

### graduation_end adicionado (4ª fase)
"graduation_start" | "graduation_mid" | "graduation_end" | "oab_prep"
durationDays: 90 (igual a oab_prep — estudante em fim de curso está próximo da OAB)

## Schema Prisma — migrations necessárias (Sprint 1 · M1)
- Profile: + nivelamentoConcluido Boolean @default(false)
- Profile: + nivelamentoPath String? ("oab" | "graduation")

## Arquivos modificados
- back/docs/ROADMAP.md — seção Sprint 1 · M1 completamente reescrita
- .claude/PROJECT_STATE.md — critérios M1 atualizados, migrations adicionadas, decisões registradas

## Pendências / Próximos passos
- Banco de questões para o quiz de graduação: Henrique vai cuidar pessoalmente
- Implementação do M1 pode começar — ROADMAP está atualizado e é fonte de verdade
- Comunicar mudança para a designer (mensagem enviada nesta sessão)
