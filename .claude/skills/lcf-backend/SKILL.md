---
name: lcf-backend
description: |
  Especialista sênior em backend para o projeto LCF. Use esta skill para QUALQUER tarefa de backend no LCF — criar/editar módulos, rotas Fastify, controllers, services, schemas Prisma, validação Zod, middlewares de auth, queries Redis, busca BM25 via $queryRaw, ou revisar código backend existente.

  Conhece exatamente as convenções do projeto (módulo routes→controller→service, factory Errors, Zod obrigatório em todo input, requireAuth/requirePro, namespaces Redis, $queryRaw para legal_articles) — nunca explora do zero.

  Acione com: "endpoint", "rota", "controller", "service", "módulo backend", "Prisma", "schema", "migration", "Zod", "Fastify", "Redis", "requireAuth", "requirePro", "$queryRaw", "BM25", "backend", "API", ou qualquer menção a lógica de servidor, banco ou contrato de API no LCF. Substitui qualquer skill genérica de backend.
---

# LCF Backend

Você é o engenheiro backend sênior do LCF: Node.js 20 + TypeScript strict, Fastify 4, Prisma 5, PostgreSQL (Supabase), Redis (Upstash). Antes de escrever qualquer linha, entenda a superfície de impacto — gaps de produção vêm de gaps de contexto.

---

## Passo 1 — Carregar Contexto (obrigatório)

> Caminhos relativos à raiz do repositório (`lcf/`).

1. `CLAUDE.md` — stack, decisões fixadas, protocolo
2. `back/CLAUDE.md` — **convenções obrigatórias do backend** (fonte da verdade: padrão de módulo, Errors, Zod, auth, Redis)
3. `.claude/PROJECT_STATE.md` — status dos módulos
4. `docs/ROADMAP.md` — seção do módulo alvo (contratos de API, regras de negócio, critérios de aceite)
5. `docs/api-contract.md` — contratos vigentes

---

## Passo 2 — Checklist Holístico Pré-Implementação

Antes de codar, responda mentalmente:

1. **Módulo** — segue `routes.ts → controller.ts → service.ts`? Já existe módulo parecido?
2. **Camada certa** — lógica de negócio só no service; controller só faz parse (Zod) + chamada + retorno. Query nunca no controller.
3. **Erros** — usando a factory `Errors` (`Errors.notFound`, `Errors.proRequired`…)? Nunca `new Error()` nem `throw {statusCode}`.
4. **Validação** — todo input (body, query, params) tem schema Zod? Campos de texto com `max`?
5. **Auth** — rota protegida com `requireAuth` / `requirePro` no preHandler? `currentUser` extraído no padrão?
6. **Redis** — usando os namespaces corretos (`tutor:session:*`, `tutor:rate:*`, `tutor:tokens:*`)? TTL definido?
7. **Dados** — `legal_articles` é fora do Prisma → `$queryRaw` com parâmetros **bindados** (nunca interpolar string). BM25 via `to_tsquery('portuguese_unaccent', ...)`.
8. **Decisões fixadas** — Tool Use obrigatório no tutor; sem pgvector; roteamento de LLM respeitado.
9. **Migration** — mudou schema Prisma? Precisa de `db:migrate` (e variante staging)?

---

## Passo 3 — Implementar ou Gerar Prompt

- **Se você é o executor** (Claude Code): implemente seguindo as convenções; ao final, valide (Passo 4) e siga o fechamento (`lcf-versioning`).
- **Se é para delegar**: monte o material e **delegue a forja a `/lcf-forge`** (padrão único em `_shared/handoff-prompt.md`). Não invente formato.

---

## Passo 4 — Validar antes de declarar pronto

```
cd back
npx tsc --noEmit        # type-check estrito
npm run lint            # eslint
```
Se mexeu em schema: `npm run db:generate` (e `db:migrate:staging` quando aplicável).
Cole a saída como evidência. Sem type-check limpo, não está pronto. (Ver `lcf-verify` para o portão completo.)

---

## Convenções rápidas (detalhe completo em `back/CLAUDE.md`)

```typescript
// usuário autenticado
const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };

// erros
throw Errors.notFound('Tópico');     throw Errors.proRequired();

// zod
const body = MySchema.parse(req.body);
const { id } = z.object({ id: z.string().uuid() }).parse(req.params);

// rotas
app.get('/rota', { preHandler: [requireAuth] }, handler);

// busca legal (parâmetro bindado, nunca interpolado)
await prisma.$queryRaw`SELECT ... WHERE content_tsv @@ to_tsquery('portuguese_unaccent', ${token})`;
```

---

## Regra de ouro

O backend é monolito modular para 2 devs — complexidade tem custo real. Siga o padrão de módulo, valide todo input, nunca interpole SQL, respeite as decisões fixadas. Baseie tudo no código real, não em suposição.
