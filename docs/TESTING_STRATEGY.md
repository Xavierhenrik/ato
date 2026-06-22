# LEX — Estratégia de Testes

> **Objetivo:** Detectar e documentar bugs funcionais que só se manifestam na experiência real do usuário.
> Testes unitários e de integração existem, mas **não substituem** este protocolo — eles não capturam fluxos compostos, estados de borda de UI, inconsistências de contrato ou race conditions de OAuth.

---

## Princípios

1. **Perspectiva do usuário** — cada cenário começa de zero (app limpo, sem cache) e simula ações reais em sequência.
2. **Sem mocks** — todos os testes batem no ambiente de staging com dados reais (DB + Redis + Supabase Auth).
3. **Estado explícito** — antes de cada cenário, o estado inicial é descrito. Após, o estado esperado é verificado.
4. **Falha = bug registrado** — qualquer comportamento divergente do esperado é documentado com: módulo, endpoint chamado, payload enviado, resposta recebida, comportamento esperado.
5. **Regressão antes de merge** — qualquer PR que toque em módulo listado aqui deve rodar os cenários do módulo afetado.

---

## Ambiente de Teste

### Staging

```
API_BASE_URL=https://<railway-staging-url>
SUPABASE_URL=https://<projeto>.supabase.co
```

Usuários de teste (criar no Supabase antes):

| Handle | Plano | Uso |
|--------|-------|-----|
| `test_free@lcf.dev` | free | Cenários Free, limites diários |
| `test_pro@lcf.dev` | pro | Cenários PRO, features exclusivas |
| `test_new@lcf.dev` | free | Sempre sem onboarding completo — recriar após uso |

> **Nota sobre emulador Android:** `localhost` aponta para o próprio emulador, não para a máquina host.
> Use `10.0.2.2:3000` para Railway local ou a URL pública de staging.

---

## Categorias de Bug Conhecidas

Com base no histórico de sessões, os bugs reais seguem padrões previsíveis:

| Categoria | Descrição | Módulos afetados |
|-----------|-----------|-----------------|
| **Contract drift** | Campo retornado pelo backend com nome diferente do esperado pelo Flutter (ex: `isCorrect` vs `correct`) | simulados, tutor |
| **Nullable crash** | Flutter recebe `null` onde esperava valor — `!` explode em runtime | dashboard, simulados, perfil |
| **JWT edge case** | Token expirado, staging JWT rejeitado por produção, 401 loop | auth, qualquer módulo autenticado |
| **OAuth redirect** | Google/Apple OAuth não retorna deep link corretamente (`com.lcf.app://auth-callback`) | auth |
| **Redis state** | Contador diário não resetado, sessão Tutor vazando entre usuários | tutor, simulados |
| **Empty state 204** | Backend retorna 204 sem corpo, Flutter tenta parsear e crasha | simulados (in-progress), notificações |
| **Free gate** | Limite de 15 questões/dia ou bloqueio PRO não aplicado corretamente | simulados, tutor |
| **Onboarding roteamento** | App não redireciona para onboarding após novo cadastro, ou redireciona para usuário antigo | auth, onboarding |
| **Isar cache stale** | Dado offline desatualizado exibido sem indicação, pull-to-refresh não invalida | dashboard, manual, anotações |

---

## Protocolo de Execução por Agente

Ao receber uma tarefa de teste, o agente **deve**:

1. Ler `docs/api-contract.md` para o módulo em escopo.
2. Identificar o usuário de teste correto para o cenário (free/pro/new).
3. Executar cada cenário em sequência, anotando a resposta real de cada chamada.
4. Para cada divergência: criar entrada no formato de **Bug Report** abaixo.
5. Ao final: criar sessão em `.claude/sessions/YYYY-MM-DD_test_<modulo>.md` com todos os bugs encontrados.

### Formato de Bug Report

```markdown
## [BUG] <módulo> — <descrição curta>

**Cenário:** <qual cenário estava sendo executado>
**Endpoint:** <METHOD /rota>
**Payload enviado:** <JSON>
**Resposta recebida:** <JSON ou status HTTP>
**Comportamento esperado:** <o que deveria acontecer>
**Impacto:** crítico | alto | médio | baixo
**Reprodução:** <passos mínimos para reproduzir>
```

---

## Cenários por Módulo

### AUTH — Fluxos de Autenticação

> Arquivo de referência: `src/modules/auth/`

**A1 — Cadastro e-mail novo usuário**
- Estado inicial: usuário `test_new@lcf.dev` não existe no Supabase
- Ações: `POST /auth/signup` → `POST /auth/verify`
- Verificar: `onboarding_done: false` nos metadados Supabase, resposta com `needsOnboarding: true`
- Verificar: tabela `User` criada com `plan: 'free'`

**A2 — Login e-mail existente**
- Estado inicial: `test_free@lcf.dev` com onboarding completo
- Ações: `POST /auth/login` → `POST /auth/verify`
- Verificar: token válido retornado, `needsOnboarding: false`, roteamento para Dashboard

**A3 — Token expirado**
- Estado inicial: usuário logado, forçar expiração do token (alterar TTL no Supabase ou usar token inválido)
- Ações: `GET /dashboard` com token expirado
- Verificar: resposta `401`, não entra em loop de retry

**A4 — Google OAuth (crítico)**
- Estado inicial: app limpo, nenhuma sessão ativa
- Ações: iniciar `signInWithGoogle` → aguardar redirect → deep link `com.lcf.app://auth-callback` retornado → `POST /auth/verify` automático
- Verificar: `_pendingGoogleVerify` flag setada antes do redirect, `verify()` chamado após `onAuthStateChange.signedIn`
- Verificar: primeiro acesso → onboarding; acesso recorrente → dashboard
- **Ponto de falha histórico:** `signInWithOAuth` retorna imediatamente; sessão só existe após o deep link voltar. Verificar que o app não chama `/auth/verify` antes do callback.

**A5 — Delete account**
- Estado inicial: `test_free@lcf.dev` logado
- Ações: `DELETE /auth/me`
- Verificar: `supabaseAdmin.auth.admin.deleteUser` chamado **antes** de `db.user.delete`
- Verificar: JWT do usuário deletado retorna 401 em qualquer rota protegida (não recria conta via auto-provisioning)

---

### ONBOARDING — M1

**O1 — Onboarding graduation_start**
- `POST /onboarding/complete` com `{ academicPhase: "graduation_start", dailyStudyMins: 60 }`
- Verificar: `flow: "graduation"`, `nivelamentoPendente: true`

**O2 — Onboarding oab_prep**
- `POST /onboarding/complete` com `{ academicPhase: "oab_prep", dailyStudyMins: 90 }`
- Verificar: `flow: "oab"`, `nivelamentoPendente: true`

**O3 — Quiz Diagnóstico completo**
- `GET /onboarding/diagnostic/questions` → responder questões → `POST /onboarding/diagnostic/complete`
- Verificar: `nivelamentoPendente: false`, `nivelamentoConcluido: true`

**O4 — Dismiss Quiz**
- `POST /onboarding/diagnostic/dismiss`
- Verificar: `nivelamentoPendente: false`, `nivelamentoConcluido` permanece `false`

**O5 — Idempotência dismiss após complete**
- Complete → dismiss
- Verificar: `nivelamentoConcluido` não sobrescrito para `false`

---

### DASHBOARD — M2

**D1 — Dashboard completo**
- `GET /dashboard` com `test_free@lcf.dev` pós-onboarding
- Verificar: todos os campos presentes (`name`, `plan`, `oabMode`, `nivelamentoPendente`, `streak`, `dailyProgress`)
- Verificar: `oabMode: false` para graduation_start

**D2 — Dashboard oabMode**
- `GET /dashboard` com usuário `oab_prep`
- Verificar: `oabMode: true`

**D3 — Revision cards vazio**
- `GET /dashboard/revision-cards` sem histórico de respostas
- Verificar: array vazio `[]`, sem crash

**D4 — Performance**
- `GET /dashboard/performance` após responder questões de 2+ matérias
- Verificar: `bySubject` contém entries para as matérias respondidas

---

### MANUAL — M3

**MN1 — Listar tópicos com progresso**
- `GET /manual/topics`
- Verificar: `progress.readCount` correto (0 sem histórico)

**MN2 — Marcar como lido (idempotência)**
- `POST /manual/topics/:id/read` chamado 2x
- Verificar: `readCount` não incrementa na segunda chamada

**MN3 — Busca fulltext**
- `GET /manual/search?q=contrato`
- Verificar: resultados de ambas as fontes, campo `source` presente em cada resultado

**MN4 — Tópico individual**
- `POST /manual/topics/:id/read` → `GET /manual/topics/:id`
- Verificar: `isRead: true`

---

### SIMULADOS — M5

**S1 — Limite Free (questões/dia)**
- `test_free@lcf.dev`, responder 15 questões em um simulado
- Verificar: 16ª resposta retorna `429` com motivo `free`

**S2 — totalQ acima do máximo**
- `POST /simulados/start` com `totalQ: 90` (max é 80)
- Verificar: `400` retornado

**S3 — Simulado em progresso**
- Iniciar simulado → `POST /simulados/start` novamente
- Verificar: `409 SIMULADO_IN_PROGRESS` com `inProgressId`

**S4 — Resultados Free vs PRO**
- Free: `GET /simulados/:id/results` — verificar ausência de `explanation`
- PRO: mesmo endpoint — verificar presença de `explanation` em cada questão

**S5 — Abandon**
- `POST /simulados/:id/abandon`
- Verificar: `status: 'abandoned'`, sem `completedAt`, `GET /simulados/in-progress` retorna 204

**S6 — Histórico**
- `GET /simulados/history`
- Verificar: array direto (não `{ attempts: [] }`), sem wrapper

---

### TUTOR IA — M4

**T1 — Mensagem básica (modo direct)**
- `POST /tutor/message` com `{ message: "O que é controle de constitucionalidade?", mode: "direct" }`
- Verificar: resposta com `message`, `sources`, `confidence`, `disclaimer`, `chips` (4 valores)
- Verificar: `Sabiázinho-4` usado para query curta (<200 chars, sem verbos analíticos)

**T2 — Tool use (lookup_article)**
- `POST /tutor/message` com query que referencia artigo específico ("art. 5º da CF")
- Verificar: `sources` não vazio, artigo retornado da `legal_articles`

**T3 — Rate limit Free**
- Usuário Free, enviar >20 mensagens em 24h
- Verificar: `429` após o limite

**T4 — Auto-save anotação (PRO)**
- `test_pro@lcf.dev`, `POST /tutor/message` com `confidence: "high"`
- Verificar: `autoSavedAnnotationId` retornado e anotação existe em `GET /annotations`

**T5 — Session isolation**
- Criar sessão com user A → tentar acessar sessão com user B (mesmo sessionId)
- Verificar: `403 FORBIDDEN` — não vazar sessão alheia

**T6 — KB estática (modo direct)**
- Query que deve bater nos 1.883 tópicos enriquecidos
- Verificar: resposta instantânea sem chamada LLM (latência <200ms)

---

### ANOTAÇÕES — M6

**AN1 — Criar com todos os campos**
- `POST /annotations` com `title`, `content`, `tags`, `subject`
- Verificar: todos os campos persistidos

**AN2 — Filtros**
- `GET /annotations?subject=Constitucional` — filtra por subject
- `GET /annotations?tag=prova` — filtra por tag no JSON array
- `GET /annotations?q=personalidade` — busca em title e content

**AN3 — Atualizar sem perder campos**
- `PUT /annotations/:id` com novo `tags`
- Verificar: `subject` não perdido após update

---

### PERFIL + ASSINATURA — F7

**P1 — Perfil completo**
- `GET /users/profile`
- Verificar: `email`, `plan`, `nivelamentoPendente` todos presentes

**P2 — Atualizar dailyStudyMins**
- `PUT /users/profile` com `dailyStudyMins: 45`
- Verificar: campo atualizado no banco (não ignorado silenciosamente)

**P3 — Webhook RevenueCat — EXPIRATION**
- Simular evento `EXPIRATION`
- Verificar: `plan: 'free'` no banco

**P4 — Webhook CANCELLATION**
- Simular evento `CANCELLATION`
- Verificar: `plan: 'pro'` mantido, apenas `status` alterado

---

## Cenários Cross-módulo (Fluxos Compostos)

### FC1 — Jornada completa novo usuário

```
Cadastro → Verify → Onboarding (graduation_start) → Dashboard → Manual (ler 1 tópico) →
Simulado (10 questões) → Tutor (1 pergunta) → Anotação criada → Perfil visualizado
```

Verificar em cada etapa que o estado é consistente com o passo anterior.

### FC2 — Upgrade Free → PRO

```
Login como Free → Tentar feature PRO (simulado >15q) → Ver ProGateSheet →
Webhook INITIAL_PURCHASE → Verificar plan: 'pro' → Feature PRO desbloqueada
```

### FC3 — Fluxo offline (Isar)

```
Abrir app com dados em cache → Desligar rede → Dashboard ainda exibe (stale cache) →
Reconectar → Pull-to-refresh → Cache invalidado → Dados novos carregados
```

---

## Checklist de Pré-Merge

Antes de qualquer PR ser aprovado, verificar:

- [ ] `tsc --noEmit` zero erros
- [ ] `flutter analyze` zero issues
- [ ] Cenários dos módulos afetados executados em staging
- [ ] Nenhum `console.log` em produção (somente `req.log.*`)
- [ ] Nenhum campo novo no response sem atualização do `docs/api-contract.md`
- [ ] Redis keys usam `keys.*` (não string hardcoded)
- [ ] Erros via `Errors.*` factory (não `new Error()`)
