# LEX — Guia de Refatoração

> **Objetivo:** Elevar progressivamente a qualidade do código sem introduzir regressões funcionais.
> Refatoração no LEX é cirúrgica: comportamento externo invariável, estrutura interna melhorada.
>
> **Regra de ouro:** se o `api-contract.md` continua válido e `flutter analyze + tsc --noEmit` continuam zerados, a refatoração está segura.

---

## O que é e o que NÃO é refatoração aqui

| É refatoração | NÃO é refatoração |
|---------------|-------------------|
| Extrair lógica duplicada para função/widget reutilizável | Mudar comportamento de uma feature existente |
| Renomear variável/função para nomenclatura mais clara | Alterar campos de resposta de API |
| Substituir `new Error()` por `Errors.*` factory | Mudar fluxo de navegação |
| Adicionar tipagem explícita onde estava implícita | Alterar schemas Prisma (requer migration) |
| Eliminar dead code | Alterar lógica de rate limiting |
| Otimizar query sem mudar resultado | Mudar TTL de chaves Redis |
| Extrair widget inline para componente reutilizável | Mudar estrutura de resposta de endpoint |

Se a mudança alterar qualquer item da coluna direita, não é refatoração — é feature/bugfix e deve ser tratada como tal (com testes antes e depois).

---

## Protocolo de Execução por Agente

Ao receber uma tarefa de refatoração, o agente **deve**:

1. Ler este arquivo e `back/CLAUDE.md` (backend) ou `front/docs/FRONTEND_BLUEPRINT.md` (frontend).
2. Definir o **escopo isolado** — um módulo ou camada por vez. Nunca refatorar backend e frontend no mesmo commit.
3. Executar auditoria do módulo: listar todos os achados antes de escrever uma linha.
4. Implementar correções em ordem de severidade (crítico → alto → médio).
5. Após cada grupo de mudanças: `tsc --noEmit` (backend) ou `flutter analyze` (frontend) — zero issues obrigatório.
6. Criar entrada em `.claude/sessions/YYYY-MM-DD_refactor_<modulo>.md` com: o que mudou, por quê, o que NÃO foi tocado e por quê.

---

## Backend — Padrões Obrigatórios (de `back/CLAUDE.md`)

Todo o backend segue `routes → controller → service`. Qualquer desvio é candidato a refatoração.

### Checklist por módulo

**Routes (`<nome>.routes.ts`)**
- [ ] `preHandler: [requireAuth]` em toda rota autenticada
- [ ] `preHandler: [requireAuth, requirePro]` em rotas PRO
- [ ] Nenhuma lógica de negócio — apenas registro de rotas e preHandlers

**Controller (`<nome>.controller.ts`)**
- [ ] Extrai `currentUser` via cast padrão
- [ ] Valida todos os inputs com Zod (body, query, params)
- [ ] Delega 100% da lógica ao service
- [ ] Nenhuma query Prisma/Redis no controller
- [ ] Nenhum `try/catch` manual — Fastify + `AppError` tratam automaticamente

**Service (`<nome>.service.ts`)**
- [ ] Erros via `Errors.*` factory — nunca `new Error()`, nunca `throw { statusCode }`
- [ ] Redis keys via `keys.*` — nunca string hardcoded
- [ ] `legal_articles` sempre via `$queryRaw` com `Prisma.sql`
- [ ] Listas retornam array direto — sem wrapper `{ data: [], total: }`
- [ ] Logging via `req.log` — nunca `console.log`

### Anti-padrões a eliminar

```typescript
// ❌ Erro manual
throw new Error('Não encontrado');
// ✅ Factory
throw Errors.notFound('Tópico');

// ❌ Redis string hardcoded
await redis.set(`tutor:session:${id}`, data);
// ✅ Key builder
await redis.set(keys.tutorSession(id), data);

// ❌ Query raw com interpolação
await db.$queryRaw(`SELECT * FROM legal_articles WHERE id = ${id}`);
// ✅ Prisma.sql (previne SQL injection)
await db.$queryRaw(Prisma.sql`SELECT * FROM legal_articles WHERE id = ${id}`);

// ❌ console.log em produção
console.log('webhook recebido', event);
// ✅ Fastify logger
req.log.info({ event: event.type }, 'webhook recebido');

// ❌ Wrapper desnecessário
return { data: annotations, total: annotations.length };
// ✅ Array direto
return annotations;
```

---

## Backend — Otimização de Banco de Dados

### Índices existentes (Sprint 4)

```sql
-- Já aplicados em staging + live
simulado_questions_is_correct_idx
simulado_questions_answered_at_idx
simulado_questions_attempt_id_is_correct_idx
```

### Auditoria de índices — executar no banco

```sql
-- Queries lentas (>100ms) sem índice
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE tablename IN ('SimuladoQuestion', 'Annotation', 'TutorMessage', 'UserQuestionAnswered')
ORDER BY n_distinct DESC;

-- Índices não utilizados (candidatos a remoção)
SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Padrões de query a otimizar

```typescript
// ❌ N+1: buscar relation em loop
const topics = await db.topic.findMany();
for (const t of topics) {
  t.reads = await db.topicRead.count({ where: { topicId: t.id } });
}

// ✅ Include ou aggregate direto
const topics = await db.topic.findMany({
  include: { _count: { select: { reads: true } } }
});

// ❌ Select * sem necessidade
const users = await db.user.findMany();

// ✅ Select apenas campos necessários
const users = await db.user.findMany({
  select: { id: true, email: true, plan: true }
});
```

### Relacionamentos — verificar consistência

- `SimuladoQuestion.questionId` → `Question.id`: UUID/TEXT mismatch resolvido no Sprint 4 (`@db.Uuid`)
- `UserQuestionAnswered.questionId` → `Question.id`: verificar se FK explícita existe no schema
- `legal_articles`: fora do Prisma — verificar que nenhum model Prisma tenta criar relation com esta tabela

---

## Frontend Flutter — Padrões Obrigatórios

### Arquitetura feature-first

```
features/<nome>/
├── data/
│   ├── models/<nome>_models.dart        # @JsonSerializable — imutáveis
│   └── <nome>_repository.dart           # Dio + Isar (offline-first)
├── providers/<nome>_provider.dart       # Riverpod @riverpod codegen
└── presentation/
    ├── screens/<nome>_screen.dart
    └── widgets/                         # widgets reutilizáveis do módulo
```

Qualquer arquivo que mistura responsabilidades (ex: repository fazendo lógica de UI, screen fazendo chamada Dio direta) é candidato a refatoração.

### Checklist por feature

**Models**
- [ ] `@JsonSerializable` com `fromJson`/`toJson` gerados
- [ ] Campos nullable explícitos (`String?` não `String` quando pode ser nulo)
- [ ] Nenhuma lógica de negócio no model

**Repository**
- [ ] Dio via `ApiClient.instance` — nunca instanciar `Dio()` diretamente
- [ ] Erro tratado via `try/catch DioException` — nunca catch genérico sem rethrow
- [ ] Isar: `invalidateCache()` chamado após mutations (create/update/delete)
- [ ] Isar: `fallback stale cache` implementado para reads (retorna cache enquanto fetch está em andamento)

**Provider (Riverpod)**
- [ ] `@riverpod` codegen — nunca `StateNotifier` manual
- [ ] Estado expõe `AsyncValue<T>` — nunca gerenciar `isLoading/error` manualmente
- [ ] Provider não contém lógica de UI

**Screen/Widget**
- [ ] `AppColors.*` para todas as cores — nunca `Color(0xFF...)` inline
- [ ] `AppTextStyles.*` para todos os estilos de texto — nunca `TextStyle(...)` inline
- [ ] `super.key` em todos os construtores de widget
- [ ] `ListView.builder` para listas longas (não `Column` com `.map()`)
- [ ] `InkWell` com `splashColor`/`highlightColor` para feedback háptico
- [ ] Sem `print()` — usar `debugPrint()` apenas em development

### Anti-padrões Flutter a eliminar

```dart
// ❌ Cor hardcoded
Container(color: Color(0xFF1A1A2E))
// ✅ Token
Container(color: AppColors.background)

// ❌ TextStyle inline repetido
Text('Título', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
// ✅ Estilo definido
Text('Título', style: AppTextStyles.heading2)

// ❌ Catch genérico que engole o erro
try { ... } catch (e) { setState(() => isLoading = false); }
// ✅ Catch tipado com log
try { ... } on DioException catch (e) { debugPrint('Erro API: $e'); rethrow; }

// ❌ Column com map para lista longa
Column(children: items.map((i) => ItemWidget(i)).toList())
// ✅ ListView.builder (lazy rendering)
ListView.builder(itemCount: items.length, itemBuilder: (_, i) => ItemWidget(items[i]))

// ❌ TextStyle recriado a cada rebuild
Text('x', style: TextStyle(fontSize: 14))
// ✅ Static const fora do build
static const _labelStyle = TextStyle(fontSize: 14);
```

---

## Validação de Contratos (Contract Drift)

O maior risco de regressão é a deriva de contrato entre backend e Flutter.

### Auditoria de contrato

Para cada endpoint em `docs/api-contract.md`:

1. Verificar que o service retorna **exatamente** os campos documentados (nem mais, nem menos)
2. Verificar que o model Flutter (`@JsonSerializable`) mapeia **exatamente** os mesmos nomes de campo
3. Verificar que campos opcionais são `nullable` no Flutter model

### Campos históricos de deriva (manter atenção)

| Endpoint | Campo problemático | Causa histórica |
|----------|-------------------|-----------------|
| `POST /simulados/start` | `enunciado`, `opcoes` | Backend retornava nome diferente |
| `GET /simulados/results` | `total`, `correct`, `wrong` | Renomeado sem atualizar Flutter |
| `GET /simulados/history` | Estrutura de resposta | Backend retornava wrapper `{attempts:[]}` |
| `POST /simulados/:id/submitAnswer` | `isCorrect` → `correct` | Field name mismatch |
| `GET /simulados/in-progress` | 204 sem corpo | Flutter tentava parsear null |
| `GET /users/profile` | `email`, `plan` ausentes | Backend não retornava os campos |

### Como detectar novos drifts

```bash
# Backend: verificar que todos os campos dos controllers batem com api-contract.md
# Comparar manualmente ou via script:
cd back && npx ts-node scripts/validate-contract.ts  # criar se não existir

# Flutter: verificar fromJson com campos esperados
grep -r "fromJson" front/lcf_app/lib/features/ | grep -v ".g.dart"
```

---

## Qualidade Geral — Métricas de Referência

| Métrica | Alvo | Como medir |
|---------|------|-----------|
| `tsc --noEmit` | 0 erros | `cd back && npm run typecheck` |
| `flutter analyze` | 0 issues | `cd front/lcf_app && flutter analyze` |
| Cobertura de Zod | 100% dos endpoints | Grep por handlers sem `.parse(` |
| Erros via factory | 100% | Grep por `new Error(` no src/ |
| Redis keys via builder | 100% | Grep por `redis.set\(`` ` em src/ |
| `console.log` em src/ | 0 | Grep por `console.log` em src/ |

### Script de auditoria rápida (backend)

```bash
cd lcf/back

echo "=== Erros manuais (deve ser 0) ==="
grep -r "new Error(" src/ --include="*.ts" | grep -v ".test."

echo "=== console.log em produção (deve ser 0) ==="
grep -r "console.log" src/ --include="*.ts"

echo "=== Redis hardcoded (deve ser 0) ==="
grep -r "redis\.(set|get|del)\(['\`]" src/ --include="*.ts"

echo "=== SQL raw sem Prisma.sql (deve ser 0) ==="
grep -r 'queryRaw(`' src/ --include="*.ts"
```

### Script de auditoria rápida (frontend)

```bash
cd lcf/front/lcf_app

echo "=== Cores hardcoded (candidatos) ==="
grep -r "Color(0x" lib/ --include="*.dart" | grep -v "_colors.dart"

echo "=== print() em produção (deve ser 0) ==="
grep -r "  print(" lib/ --include="*.dart"

echo "=== TextStyle inline (candidatos) ==="
grep -r "TextStyle(" lib/ --include="*.dart" | grep -v "_text_styles.dart" | grep -v ".g.dart"
```

---

## Prioridade de Refatoração

Executar nesta ordem ao auditar um módulo pela primeira vez:

1. **Crítico** — Viola padrões de segurança ou causa crash potencial
   - SQL injection (raw query sem `Prisma.sql`)
   - Catch genérico que engole DioException sem rethrow
   - JWT/Auth sem `requireAuth` em rota que deveria ser protegida

2. **Alto** — Viola convenções obrigatórias do projeto
   - `new Error()` em vez de `Errors.*`
   - `console.log` em produção
   - Redis key hardcoded
   - Cor/estilo inline no Flutter

3. **Médio** — Reduz manutenibilidade
   - Lógica de negócio no controller
   - N+1 queries não otimizadas
   - Widget inline que poderia ser componente reutilizável

4. **Baixo** — Melhora legibilidade sem impacto funcional
   - Nomenclatura inconsistente
   - Comentários desatualizados
   - Imports não utilizados

---

## Após Cada Sessão de Refatoração

Criar `.claude/sessions/YYYY-MM-DD_refactor_<modulo>.md` com:

```markdown
# Refatoração <Módulo> — YYYY-MM-DD

## Escopo
Módulo: <nome>
Camada: backend | frontend | ambos

## Achados (auditoria antes das mudanças)
- [ ] Crítico: ...
- [ ] Alto: ...
- [ ] Médio: ...

## O que foi feito
- path/to/file.ts — descrição precisa da mudança

## O que NÃO foi tocado (e por quê)
- Lógica X em file.ts — comportamento externo depende de Y, risco de regressão

## Verificações
- [ ] tsc --noEmit: 0 erros
- [ ] flutter analyze: 0 issues
- [ ] api-contract.md ainda válido (nenhuma response alterada)
- [ ] Cenários de teste relevantes executados em staging
```
