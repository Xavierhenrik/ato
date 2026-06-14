# Spec — Histórico de Conversas do Tutor IA (v1)

> **Fonte de verdade desta feature.** Agentes dev: leiam este documento por inteiro antes de codificar.
> Decisões aqui registradas já passaram por análise de produto — não rediscutir, implementar.
> Criado: 2026-06-12 · Status: aprovado para implementação

---

## 1. Resumo

O usuário passa a ter histórico permanente das conversas com o Tutor IA, separado por origem:

- **Diretas** (`mode: direct`) — usuário abriu o Tutor e perguntou.
- **Do Manual** (`mode: reading`) — usuário abriu o Tutor enquanto lia um resumo (orbe no Manual).

Hoje a conversa morre com o TTL do Redis (4h) e a persistência em DB só acontece no
`DELETE /tutor/session/:id` — e mesmo assim só as **últimas 8 mensagens** (fatia `MAX_HISTORY`).
Esta feature troca esse modelo por **write-through**: cada turno é gravado no PostgreSQL no momento
em que acontece. O Redis permanece **exclusivamente** como janela de contexto do LLM (8 msgs, TTL 4h).

### Decisões fixadas desta feature (não rediscutir)

| Decisão | Valor |
|---------|-------|
| Retenção | Free vê últimos **7 dias**; PRO vê tudo. Gate aplicado **na leitura** (filtro de query) — sem cron de limpeza no v1 |
| Conversas antigas | **Read-only.** Sem retomada de sessão no v1 (reidratar Redis ⇒ v1.1). CTA "Nova conversa sobre isso" |
| `mode: simulado` | **Não é persistido.** Nenhuma escrita em DB para sessões simulado |
| Entrada na UI | Ícone de histórico no `LcfAppBar` do Tutor (somente modo padrão, não no modo contexto) |
| Memória entre sessões | Continua **inexistente** (decisão fixada, roadmap v2.0). Histórico não injeta nada no contexto do LLM |
| Cache offline | **Sem Isar no v1.** Histórico exige rede; offline mostra `LcfErrorState` |
| Título da sessão | Primeira mensagem do usuário truncada em 80 chars — determinístico, **sem LLM** |

---

## 2. Modelo de dados

### 2.1 Alteração no Prisma (`back/prisma/schema.prisma`)

`TutorSession` ganha um campo:

```prisma
model TutorSession {
  // ... campos existentes inalterados ...
  title     String?                     // 1ª mensagem do usuário, truncada em 80 chars
  // ...
  @@index([userId, createdAt(sort: Desc)])
}
```

Observações:
- O índice existente `@@index([userId])` pode ser substituído pelo composto acima.
- **Sem FK** `topicId → topics`: o título do tópico é resolvido por batch lookup
  (`db.topic.findMany({ where: { id: { in: [...] } } })`). Evita risco de constraint em migration.
- `id` do `TutorSession` passa a ser **o mesmo UUID da sessão Redis** (gerado em `POST /tutor/session/new`).
  O `@default(uuid())` permanece, mas o create/upsert sempre fornece o `id` explicitamente.

### 2.2 Migration SQL manual (`back/prisma/migrations/tutor_history.sql`)

Seguir o padrão das migrations manuais anteriores (`sprint1_manual.sql`, `camada2_weak_topics.sql`):

```sql
ALTER TABLE tutor_sessions ADD COLUMN IF NOT EXISTS title text;
CREATE INDEX IF NOT EXISTS tutor_sessions_user_id_created_at_idx
  ON tutor_sessions (user_id, created_at DESC);
```

> A aplicação em staging/live é feita pelo Henrique (decisão externa) — o agente cria o arquivo
> e atualiza a seção "Migrations Prisma Pendentes" do PROJECT_STATE.md.
> Para o ambiente de dev, rodar apenas `npx prisma generate` (sem `migrate dev`).

---

## 3. Backend

### 3.1 Write-through — `session.service.ts`

**Remover** `persistToDB` (e seu único call-site no `deleteSession` do controller).

**Adicionar** `persistTurn`:

```ts
async persistTurn(params: {
  sessionId: string;
  userId: string;
  mode: 'reading' | 'simulado' | 'direct';
  topicId?: string;
  userMessage: string;
  assistantMessage: string;   // texto FINAL parseado (parsed.message / kbResult.message) — nunca res.content cru
  sources?: unknown[];        // CitationSchema[] do parse; [] no caminho KB
}): Promise<void>
```

Comportamento:
1. `if (params.mode === 'simulado') return;` — simulado nunca persiste.
2. Upsert do `TutorSession` com `id = sessionId`:
   - `create`: `{ id, userId, mode, topicId: topicId ?? null, title: userMessage.slice(0, 80), msgCount: 2 }`
   - `update`: `{ msgCount: { increment: 2 } }`
3. `createMany` de 2 `TutorMessage`: `{ sessionId, role: 'user', content: userMessage }` e
   `{ sessionId, role: 'assistant', content: assistantMessage, sources: sources ?? undefined }`.
4. **Todo o corpo em try/catch** — falha de persistência loga `tutor:persist_failed` (com sessionId)
   e **não** propaga. O chat nunca quebra por causa do histórico.

### 3.2 Pontos de chamada — `tutor.service.ts`

Existem **dois** caminhos de resposta no `chat()`; ambos chamam `persistTurn` logo após o
`sessionSvc.append` correspondente:

1. **Caminho KB-hit** (modo direct, `kbResult.hit`): `assistantMessage = kbResult.message`, `sources: []`.
2. **Caminho loop agêntico** (final do método): `assistantMessage = parsed.message`,
   `sources: parsed.sources`. Chamar **após** `citationSvc.parse` (o parsed é necessário).

`topicId` vem de `req.context?.topic_id` — hoje o tipo `TutorRequest` já carrega `context`; conferir
e propagar. O conteúdo persistido do assistant é o texto limpo — **nunca** blocos tool_use serializados.

### 3.3 `deleteSession` — controller

`DELETE /tutor/session/:id` deixa de persistir (write-through já garantiu). Novo corpo:

1. `validateOwnership` (inalterado).
2. Se `mode !== 'simulado'`: `db.tutorSession.updateMany({ where: { id, userId: user.id }, data: { endedAt: new Date() } })` — `updateMany` para não lançar quando a sessão não tem nenhum turno persistido.
3. `sessionSvc.clear(id)` (inalterado). Resposta `204` (inalterada).

### 3.4 Helper de plano — `services/plan.service.ts` (novo)

Extrair o `_getIsPro` privado do `TutorController` para função exportada `getIsPro(userId): Promise<boolean>`
(mesma lógica: cache Redis `keys.subPro`, TTL 300s, fallback DB). `TutorController` e o novo
`HistoryController` passam a usá-la. Zero mudança de comportamento.

### 3.5 Novos endpoints — `controllers/history.controller.ts` + `services/history.service.ts`

Registrar em `tutor.routes.ts` (todas com `preHandler: [requireAuth]`):

#### `GET /tutor/history?mode=&cursor=&limit=`

Query (Zod): `mode: z.enum(['direct','reading'])` (obrigatório), `cursor: z.string().uuid().optional()`,
`limit: z.coerce.number().int().min(1).max(50).default(20)`.

Regras:
- Filtro base: `{ userId, mode, msgCount: { gt: 0 } }`. Simulado nunca aparece (nem existe em DB).
- **Gate Free**: se `!await getIsPro(userId)` ⇒ adicionar `createdAt: { gte: subDays(now, 7) }`.
- Ordenação: `createdAt DESC`. Paginação keyset: `cursor` = id da última sessão da página anterior;
  o service busca o `createdAt` dessa sessão e aplica `createdAt < cursorCreatedAt`.
  Cursor inexistente/da outra pessoa ⇒ `400 VALIDATION`.
- `topicTitle`: batch lookup em `topics` pelos `topicId` não-nulos da página.

Response `200`:

```json
{
  "sessions": [
    {
      "id": "uuid",
      "mode": "reading",
      "title": "O que é usucapião extraordinária?",
      "topicId": "uuid-ou-null",
      "topicTitle": "Usucapião — ou null",
      "createdAt": "2026-06-12T03:21:00.000Z",
      "msgCount": 6
    }
  ],
  "nextCursor": "uuid-ou-null",
  "retention": "7d"
}
```

`retention`: `"7d"` para Free, `"all"` para PRO — o Flutter usa para exibir o banner de gate.
`nextCursor` = id do último item quando a página veio cheia (`length === limit`); senão `null`.

#### `GET /tutor/history/:id`

- Busca por `{ id, userId }`. Não encontrado **ou** de outro usuário ⇒ `404 NOT_FOUND` (sem vazar existência).
- **Gate Free**: sessão com `createdAt` > 7 dias ⇒ `404` (consistente com a lista).
- Mensagens ordenadas por `createdAt ASC`.

Response `200`:

```json
{
  "session": { "...mesmo shape do item da lista..." },
  "messages": [
    { "id": "uuid", "role": "user", "content": "...", "sources": null, "createdAt": "ISO" },
    { "id": "uuid", "role": "assistant", "content": "...", "sources": [ { "law": "...", "article": "..." } ], "createdAt": "ISO" }
  ]
}
```

#### `DELETE /tutor/history/:id`

- Mesma regra de ownership (`404` se não for do usuário). Free pode deletar sessão antiga (> 7d)? **Sim** —
  ownership basta; o gate de 7d é só de leitura.
- `db.tutorSession.delete` — cascade já remove as mensagens (`onDelete: Cascade` existente).
- Response `204`.

### 3.6 Contrato

Atualizar `docs/api-contract.md` com os 3 endpoints acima e a mudança de semântica do
`DELETE /tutor/session/:id` (agora apenas encerra: `endedAt` + limpeza Redis).

---

## 4. Flutter

### 4.1 Arquivos novos (feature-first, padrão do projeto)

```
features/tutor/
├── data/models/tutor_history_models.dart      # HistorySession, HistoryListResponse, HistoryMessage, HistoryDetailResponse
├── data/tutor_repository.dart                 # +getHistory, +getHistoryDetail, +deleteHistory  (ALTERAR)
├── providers/tutor_history_provider.dart      # TutorHistoryNotifier (filtro, lista, paginação, delete)
├── presentation/screens/tutor_history_screen.dart
├── presentation/screens/tutor_history_detail_screen.dart
└── presentation/widgets/history_session_card.dart
```

Models seguem o padrão **existente em `tutor_models.dart`** (mesma técnica de serialização do arquivo —
observar antes de escrever). Campos tolerantes a backend antigo onde fizer sentido
(`retention` com default `"all"`).

### 4.2 Entrada — ícone no app bar do Tutor

Em `shared/widgets/lcf_app_bar.dart`, o `LcfTutorAppBar` em **modo padrão** (não-contexto,
`showBack == false`) ganha `IconButton` com `Icons.history_rounded` à direita →
`context.push('/tutor/history')`. No modo contexto (gaveta do Manual) o ícone **não aparece**.

### 4.3 Tela de lista — `/tutor/history`

- Rota nova no `app_router.dart`, fora do `ShellRoute` ou dentro com BottomNav — seguir o padrão de
  `/tutor/context` (tela pushed com `ScaffoldWithNav` se trivial; caso contrário tela cheia simples).
- Filtro no topo: 2 segmentos — **"Diretas"** e **"Do Manual"** (default: Diretas). Troca de segmento
  refaz a query com `mode` correspondente.
- Card (`history_session_card.dart`): `title` (1 linha, ellipsis), data relativa ("há 2 dias"),
  `msgCount` ("6 mensagens"); sessões `reading` mostram `CategoryTag`/badge com `topicTitle`.
  Estilo: `AppColors`/`AppTextStyles`/`AppRadius` — nada hardcoded.
- Scroll infinito: ao chegar ao fim, busca próxima página com `nextCursor`.
- Long-press no card → dialog de confirmação → `DELETE /tutor/history/:id` → remove da lista.
- **Banner Free**: se `retention == "7d"`, footer fixo discreto "Mostrando os últimos 7 dias · PRO guarda tudo"
  → tap abre `ProGateSheet`.
- Estados: loading shimmer (`LcfLoadingShimmer`), vazio (`LcfEmptyState` com copy por segmento),
  erro (`LcfErrorState` com retry).

### 4.4 Tela read-only — `/tutor/history/:id`

- `ListView` de `ChatBubble` (reuso direto — markdown via `LcfMarkdownBody` já embutido).
  **Sem `ChatInputBar`**, sem chips, sem typing indicator.
- Rodapé: `LcfButton` **"Nova conversa sobre isso"**:
  - `mode == 'reading' && topicId != null`: busca `getTopicDetail(topicId)` no `ManualRepository`
    → `context.push('/tutor/context', extra: TutorScreenArgs(topicContext: TutorTopicContext(topicTitle: ..., topicContent: ...)))` — reuso integral do fluxo do orbe.
  - `mode == 'direct'` (ou `topicId == null`): `ref.read(tutorNotifierProvider.notifier).endSession()`
    e `context.go('/tutor')` (sessão limpa).
- AppBar com voltar; título = `title` da sessão.

### 4.5 O que NÃO muda no Flutter

`TutorNotifier`, fluxo de envio de mensagem, fake streaming, orbe do Manual, `LcfGlassSheet` — intocados.
O `endSession` continua chamando `DELETE /tutor/session/:id` fire-and-forget (semântica nova é só backend).

---

## 5. Critérios de aceite

### Backend (AG1)

- [ ] `POST /tutor/message` (mode direct, 2 turnos) cria 1 `TutorSession` (`id` = session_id do Redis, `title` = 1ª msg ≤ 80 chars, `msgCount: 4`) e 4 `TutorMessage` com `sources` no assistant
- [ ] Caminho KB-hit também persiste o turno (sources `[]`)
- [ ] `mode: simulado` não cria nenhuma linha em `tutor_sessions`/`tutor_messages`
- [ ] `mode: reading` com `topic_id` persiste `topicId` na sessão
- [ ] Falha de DB durante `persistTurn` não quebra a resposta do chat (testável comentando a chamada interna — verificar try/catch e log)
- [ ] `GET /tutor/history?mode=direct` pagina por keyset (cursor) e nunca retorna sessões de outro usuário nem `mode` diferente do filtro
- [ ] Usuário Free não recebe sessões com `createdAt` > 7 dias; PRO recebe; `retention` reflete o plano
- [ ] `GET /tutor/history/:id` de outro usuário ⇒ `404`; Free com sessão > 7d ⇒ `404`
- [ ] `DELETE /tutor/history/:id` ⇒ `204` e remove mensagens em cascade
- [ ] `DELETE /tutor/session/:id` seta `endedAt` sem duplicar sessão; `persistToDB` removido do código
- [ ] `npx tsc --noEmit` zero erros · `docs/api-contract.md` atualizado · migration `tutor_history.sql` criada

### Flutter (AG2)

- [ ] Ícone histórico visível no Tutor (modo padrão) e ausente no modo contexto (gaveta Manual)
- [ ] Lista com 2 segmentos funcionais, scroll infinito, long-press delete com confirmação
- [ ] Card reading mostra badge do tópico; direct não
- [ ] Banner 7 dias aparece somente quando `retention == "7d"` e abre `ProGateSheet`
- [ ] Detail read-only renderiza markdown via `ChatBubble`, sem input
- [ ] CTA reading reabre `/tutor/context` com o tópico real; CTA direct abre `/tutor` com sessão limpa
- [ ] Estados loading/vazio/erro nos dois ecrãs
- [ ] `dart run build_runner build --delete-conflicting-outputs` ok · `flutter analyze` zero issues

---

## 6. Não-objetivos (v1)

Retomar conversas (reidratar Redis) · memória entre sessões · persistir simulado · cron de limpeza ·
cache Isar do histórico · busca no histórico · export. Nada disso deve ser "aproveitado de carona".

---

## 7. Validação

```bash
cd back && npx tsc --noEmit
cd front/lcf_app && dart run build_runner build --delete-conflicting-outputs && flutter analyze
```

Ambos com **zero erros/issues** são pré-condição de aceite. QA cruza o código implementado com as
seções 3 e 4 desta spec e marca cada critério da seção 5.
