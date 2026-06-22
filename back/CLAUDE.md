# LEX Backend — Convenções Obrigatórias

> Este arquivo complementa o `CLAUDE.md` raiz. Leia os dois antes de codificar.
> Para specs de cada módulo (contratos de API, regras de negócio, critérios de aceite), leia `../docs/ROADMAP.md`.

---

## Padrão de Módulo

Cada módulo segue estritamente: `routes.ts → controller.ts → service.ts`

```
src/modules/<nome>/
├── <nome>.routes.ts       # Registro de rotas Fastify + preHandlers
├── <nome>.controller.ts   # Parse de input (Zod) + chamada ao service + retorno HTTP
└── <nome>.service.ts      # Lógica de negócio + queries Prisma/Redis
```

Nunca colocar lógica de negócio no controller. Nunca fazer queries no controller.

---

## Convenções Críticas

### 1. Extraindo o usuário autenticado

```typescript
const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
```

### 2. Erros — sempre via factory `Errors`

```typescript
import { Errors } from '../../shared/errors';

throw Errors.notFound('Tópico');        // 404
throw Errors.unauthorized();             // 401
throw Errors.forbidden();                // 403
throw Errors.conflict('Já respondida');  // 409
throw Errors.rateLimited('free');        // 429
throw Errors.proRequired();              // 403 PRO_REQUIRED
```

Nunca `new Error()`, nunca `throw { statusCode, message }`.

### 3. Validação Zod — obrigatória em todo input

```typescript
// Body
const body = MySchema.parse(req.body);

// Query params
const { q, limit } = z.object({
  q: z.string().min(2),
  limit: z.coerce.number().default(10)
}).parse(req.query);

// Path params
const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
```

Endpoint sem Zod = risco de crash em produção. Sem exceções.

### 4. Proteção de rotas

```typescript
// Qualquer usuário autenticado
app.get('/rota', { preHandler: [requireAuth] }, handler);

// Apenas usuários PRO ativos
app.post('/rota-pro', { preHandler: [requireAuth, requirePro] }, handler);
```

`requirePro` lança `Errors.proRequired()` automaticamente.

### 5. `legal_articles` — sempre `$queryRaw`

A tabela `legal_articles` está fora do Prisma (ETL externo). Acessar exclusivamente via:

```typescript
import { Prisma } from '@prisma/client';

const rows = await db.$queryRaw<Row[]>(
  Prisma.sql`SELECT * FROM legal_articles WHERE law_code = ${lawCode} LIMIT 10`
);
```

Nunca interpolação de string em queries raw.

### 6. Redis — chaves e TTLs

```typescript
// src/shared/redis.ts — objeto keys
keys.tutorSession(sessionId)    // TTL: 4h   — histórico de chat
keys.tutorRateLimit(userId)     // TTL: 24h  — contador msg/dia (Free: 20, PRO: 200)
keys.tutorTokenBudget(sessionId) // TTL: 4h  — budget de tokens (20k/sessão)
keys.simuladoDaily(userId)      // TTL: 24h  — contador questões/dia Free (max: 15)
```

Sempre usar `keys.*` — nunca hardcodar strings de chave Redis.

### 7. Padrão de retorno de listas

Arrays diretos, sem wrapper `{ data: [], total: }`, sem paginação no MVP:

```typescript
// ✅ Correto
return annotations;

// ❌ Errado
return { data: annotations, total: annotations.length };
```

### 8. Logging

Usar o logger do Fastify (`req.log` ou `app.log`), nunca `console.log`:

```typescript
req.log.info({ userId, event: 'subscription_activated' }, 'RevenueCat webhook');
req.log.error({ err, userId }, 'Falha ao processar webhook');
```

---

## Redis — Namespaces Atuais

| Chave | TTL | Módulo |
|-------|-----|--------|
| `tutor:session:{uuid}` | 4h | tutor-ia |
| `tutor:rate:{userId}` | 24h | tutor-ia |
| `tutor:tokens:{uuid}` | 4h | tutor-ia |
| `simulado:daily:{userId}` | 24h | simulados (Sprint 2) |

---

## Módulos — Status e Sprint

| Módulo | Pasta | Status | Sprint |
|--------|-------|--------|--------|
| Auth | `modules/auth/` | ✅ Completo | — |
| Tutor IA | `modules/tutor-ia/` | ✅ Completo | — |
| Subscriptions | `modules/subscriptions/` | ⚠️ Gaps (Sprint 3) | 3 |
| Onboarding (M1) | `modules/onboarding/` | 🔄 Esqueleto | 1 |
| Dashboard (M2) | `modules/dashboard/` | 🔄 Esqueleto | 1 |
| Manual (M3) | `modules/manual/` | 🔄 Esqueleto | 1 |
| Anotações (M6) | `modules/anotacoes/` | 🔄 Esqueleto | 1 |
| Users | `modules/users/` | 🔄 Esqueleto | 1 |
| Simulados (M5) | `modules/simulados/` | 🔄 Esqueleto | 2 |

**Regra de dependência entre módulos** (ver ROADMAP seção 1):
`Auth → Onboarding → Dashboard → Users`
`Manual → Dashboard`; `Simulados → Dashboard`
`M6 Anotações → Tutor (Sprint 3)`

---

## Migrations Prisma

Sempre rodar após alterações no schema:

```bash
npx prisma migrate dev --name <descricao-curta>
npx prisma generate
```

Models pendentes de criação (Sprint 1):
- `TopicRead` — rastreamento de leitura do Manual (M3)
- Campos em `Annotation`: `title`, `tags` (Json), `subject`

---

## Variáveis de Ambiente

Referência: `.env.example`. Produção: Railway environment variables.

Variáveis críticas sem valor no MVP ainda:
- `ONESIGNAL_APP_ID` / `ONESIGNAL_API_KEY` — aguardando setup
- RevenueCat webhook secret — aguardando pricing decision

---

## Fluxo Tutor IA (referência rápida)

```
POST /tutor/message
  → requireAuth → rate limit Redis
  → llm.router: Sabiá-4 (75%) | Claude Sonnet (25%)
  → contextService.build() — system prompt + contexto modo
  → sessionService.getHistory() — últimas 8 msgs Redis
  → adapter.complete(system, messages, [lookup_article, search_legislation])
  → LOOP se stop_reason === "tool_use":
      citationService.handle(toolCall) → consulta legal_articles BM25
      append tool_result → adapter.complete()
  → sessionService.append() — persiste histórico Redis
  → retorna { message, sources, confidence, disclaimer, mode }
```
