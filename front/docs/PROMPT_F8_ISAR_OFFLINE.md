# Prompt — Sprint F8 · Isar Offline-First

> Contexto: app Flutter do projeto LCF (`front/lcf_app/`).  
> Objetivo deste sprint: implementar cache offline-first via Isar para Manual (TTL 24h) e Dashboard (TTL 1h).  
> Critérios de aceite fixados no Blueprint: Manual lista funciona offline se já carregado antes · Dashboard funciona offline com dados em cache.

---

## Contexto do projeto

LCF é um EdTech jurídico mobile-first (Flutter + Riverpod + Isar + Dio). O backend está 100% completo. Os sprints F1–F7 estão concluídos com `flutter analyze` zero issues. Este sprint F8 finaliza a parte de offline-first; a UI/UX pass (waves 1–4) já foi feita em sessão anterior.

Leia `CLAUDE.md` e `.claude/PROJECT_STATE.md` antes de qualquer modificação.

---

## O que já existe (não reescrever, apenas estender)

### Estrutura relevante em `lib/`

```
features/dashboard/
  data/
    models/dashboard_models.dart   # DashboardData, RevisionCard, PerformanceData, StreakInfo, DailyProgress — @JsonSerializable
    dashboard_repository.dart      # getHomeData(), getRevisionCards(), getPerformance() — Dio puro, sem cache
  providers/
    dashboard_provider.dart        # @riverpod Future<DashboardData> dashboardData(...)
                                   # @riverpod Future<List<RevisionCard>> revisionCards(...)
                                   # @riverpod Future<PerformanceData> performance(...)

features/manual/
  data/
    models/manual_models.dart      # Topic, TopicDetail, TopicSection, ManualSearchResult — fromJson customizado (sem json_annotation)
    manual_repository.dart         # getTopics(), getTopicDetail(), markAsRead(), searchTopics() — Dio puro, sem cache
  providers/
    manual_provider.dart           # @riverpod Future<List<Topic>> manualTopics({String? lawCode})
                                   # @riverpod Future<TopicDetail> manualTopicDetail(String id)
                                   # @riverpod Future<List<ManualSearchResult>> manualSearch(String q)
                                   # @riverpod class SelectedLawCode + @riverpod Future<List<Topic>> filteredTopics

main.dart                          # Supabase.initialize + ProviderScope — Isar ainda NÃO inicializado
```

### pubspec.yaml — dependências ainda NÃO adicionadas (comentários no arquivo original)
- `isar: ^3.1.0`
- `isar_flutter_libs: ^3.1.0` (apenas para mobile)
- `isar_generator: ^3.1.0` (dev_dependency)

`path_provider: ^2.1.2` já está presente.

---

## Implementação exigida

### 1. pubspec.yaml

Adicionar em `dependencies`:
```yaml
isar: ^3.1.0
isar_flutter_libs: ^3.1.0
```

Adicionar em `dev_dependencies`:
```yaml
isar_generator: ^3.1.0
```

### 2. Schemas Isar

Criar `lib/core/cache/isar_schemas.dart` com dois collections:

**`CachedDashboard`** — armazena o snapshot do dashboard como JSON serializado + timestamp:
```dart
@collection
class CachedDashboard {
  Id id = 1; // singleton — sempre sobrescreve o mesmo registro
  late String homeDataJson;        // DashboardData serializado
  late String revisionCardsJson;   // List<RevisionCard> serializado
  late String performanceJson;     // PerformanceData serializado
  late DateTime cachedAt;
}
```

**`CachedTopicList`** — armazena a lista de tópicos por lawCode:
```dart
@collection
class CachedTopicList {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String cacheKey;  // 'topics_all' | 'topics_CF' | 'topics_CC' etc.
  late String topicsJson;  // List<Topic> serializado
  late DateTime cachedAt;
}
```

### 3. IsarService

Criar `lib/core/cache/isar_service.dart`:

```dart
// Singleton que inicializa Isar e expõe a instância
// Usar path_provider para obter o diretório correto
// Registrar os dois schemas: [CachedDashboardSchema, CachedTopicListSchema]

@riverpod
Future<Isar> isarService(IsarServiceRef ref) async { ... }
```

### 4. Inicialização em main.dart

Isar NÃO deve ser inicializado no `main()` diretamente — ele é inicializado via provider (`isarServiceProvider`) no primeiro acesso. Isso é compatível com o padrão Riverpod do projeto (lazy init).

Não alterar `main.dart`.

### 5. TTLs

- Dashboard: `const Duration(hours: 1)`
- Manual (lista de tópicos): `const Duration(hours: 24)`

Lógica de TTL: `DateTime.now().difference(cachedAt) > ttl` → cache expirado.

### 6. Padrão stale-while-revalidate

Para ambos os módulos, o padrão é:

```
1. Buscar cache no Isar
2a. Se cache válido (dentro do TTL) → retornar dados do cache imediatamente
    + disparar fetch da API em background (unawaited) → atualizar cache + invalidar provider
2b. Se cache expirado ou vazio → fetch da API → salvar no cache → retornar dados
```

Em Flutter/Riverpod: usar `ref.invalidateSelf()` após atualizar o cache no background NÃO é necessário — o provider já retornou os dados do cache. O revalide só aciona novo build se o dado for consumido novamente (e.g., usuário sai e volta para a tela). Simplificação aceitável no MVP: background refresh apenas atualiza o cache; o usuário vê dado fresco na próxima abertura da tela.

### 7. Serialização para Isar

Os modelos existentes NÃO usam Isar diretamente (Isar não suporta objetos aninhados complexos sem embedded objects). A abordagem correta é serializar para JSON string antes de persistir:

- `DashboardData`: adicionar `toJson()` em `dashboard_models.dart` (atualmente `@JsonSerializable(createToJson: false)` — alterar para `@JsonSerializable()`)
- `RevisionCard`, `PerformanceData`, `StreakInfo`, `DailyProgress`: idem
- `Topic`: adicionar método `toJson()` manual (já tem `fromJson` manual)

Para serializar listas: `jsonEncode(list.map((e) => e.toJson()).toList())`

### 8. Modificações nos repositórios

**`DashboardRepository`** — adicionar dependência de `Isar` via constructor injection:

```dart
class DashboardRepository {
  const DashboardRepository(this._dio, this._isar);
  final Dio _dio;
  final Isar _isar;

  Future<DashboardData> getHomeData() async {
    // 1. tenta cache
    final cached = _isar.cachedDashboards.getSync(1);
    if (cached != null && !_isCacheExpired(cached.cachedAt, _dashboardTtl)) {
      _refreshDashboardInBackground(); // unawaited
      return DashboardData.fromJson(jsonDecode(cached.homeDataJson));
    }
    // 2. fetch fresh + salva cache
    final data = await _fetchHomeData();
    await _saveDashboardCache(homeData: data, ...);
    return data;
  }
  // ... mesma lógica para getRevisionCards() e getPerformance()
}
```

Provider do repositório precisa aguardar `isarServiceProvider`:
```dart
@riverpod
Future<DashboardRepository> dashboardRepository(DashboardRepositoryRef ref) async {
  final isar = await ref.watch(isarServiceProvider.future);
  return DashboardRepository(ref.watch(dioProvider), isar);
}
```

**Atenção:** como `dashboardRepositoryProvider` passa a ser `Future<DashboardRepository>`, os providers que o consomem devem usar `ref.watch(dashboardRepositoryProvider.future)`.

**`ManualRepository`** — mesma lógica, mas apenas para `getTopics()`. `getTopicDetail()`, `markAsRead()` e `searchTopics()` continuam sem cache (TTL 24h seria contraproducente para detalhes e search).

Chave de cache: `'topics_${lawCode ?? 'all'}'`

### 9. Providers atualizados

Os providers `dashboardData`, `revisionCards`, `performance`, `manualTopics` e `filteredTopics` devem ser atualizados para `async` onde necessário (para aguardar o repositório assíncrono).

### 10. build_runner

Após implementar tudo:

```bash
cd front/lcf_app
dart run build_runner build --delete-conflicting-outputs
```

Arquivos gerados esperados:
- `lib/core/cache/isar_schemas.g.dart` (Isar collections)
- `lib/core/cache/isar_service.g.dart` (Riverpod codegen)
- `lib/features/dashboard/data/models/dashboard_models.g.dart` (atualizado com toJson)
- `lib/features/dashboard/data/dashboard_repository.g.dart` (atualizado)
- `lib/features/manual/data/manual_repository.g.dart` (atualizado)

### 11. Verificação final

```bash
flutter analyze
```

Resultado exigido: zero issues.

---

## Critérios de aceite (do FRONTEND_BLUEPRINT.md)

- [ ] Manual lista funciona offline se já carregado antes (Isar cache TTL 24h)
- [ ] Dashboard funciona offline com dados em cache (Isar cache TTL 1h)
- [ ] `flutter analyze` retorna zero issues

---

## Ao finalizar

1. Atualizar `.claude/PROJECT_STATE.md`:
   - Marcar F8 como ✅ Completo (remover "offline-first pendente")
   - Atualizar `sprint:` para `"Sprint F8 completo — App production-ready"`
2. Criar `.claude/sessions/YYYY-MM-DD_sprint_f8_isar.md` com o log da sessão seguindo o template em `CLAUDE.md`.

---

## Restrições

- NÃO adicionar cache a `getTopicDetail()`, `markAsRead()`, `searchTopics()`
- NÃO usar `embedded objects` do Isar para modelos aninhados — serializar como JSON string
- NÃO criar novos arquivos de tela ou widget — apenas repositórios, providers e infraestrutura de cache
- NÃO alterar `main.dart`
- Manter as convenções do projeto: feature-first, Riverpod codegen (`@riverpod`), `AppColors`/`AppTextStyles` como fonte única de verdade
