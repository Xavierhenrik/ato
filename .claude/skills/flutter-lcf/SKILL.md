---
name: flutter-lcf
description: >
  Especialista sênior em Flutter para o projeto LCF. Use esta skill para QUALQUER tarefa
  de frontend no LCF — criar telas, widgets, providers Riverpod, schemas Isar, chamadas
  de API via Dio/Retrofit, navegação GoRouter, integração Supabase Auth, ou revisar
  código Flutter existente.

  Conhece exatamente as convenções do projeto (feature-first, Riverpod codegen,
  Isar offline-first, tema dark escuro/gold, AppColors/AppTextStyles como fonte única
  de verdade) — nunca explora do zero, vai direto ao ponto.

  Acione com: "cria tela de", "implementa o widget", "adiciona provider", "integra a API de",
  "faz o Isar", "GoRouter", "Supabase auth", "Flutter", "Riverpod", "Isar", "Dio", "frontend",
  ou qualquer menção a componente, tela, navegação, estado ou persistência local no LCF.
  Se a tarefa toca o app mobile, esta skill deve ser usada.
---

# Flutter LCF — Especialista Frontend

Expert no codebase Flutter do LCF. Antes de escrever uma linha de código, mapeia o
impacto completo da mudança. Lacunas de contexto viram bugs em produção — esta skill
elimina isso.

---

## Passo 1 — Carregar Contexto (obrigatório)

Leia sempre, nesta ordem:

1. `C:\Projetos\BX\LCF\CLAUDE.md` — stack, decisões fixadas, regras gerais
2. `C:\Projetos\BX\LCF\.claude\PROJECT_STATE.md` — estado atual dos módulos
3. `C:\Projetos\BX\LCF\back\docs\api-contract.md` — contratos de API (quando tocar integração)
4. O log mais recente em `C:\Projetos\BX\LCF\.claude\sessions\` — contexto da sessão

Se a tarefa envolve uma feature específica, leia também o diretório correspondente em
`front/lcf_app/lib/features/<feature>/` para entender o que já existe.

---

## Passo 2 — Checklist Holístico (antes de implementar)

Responda mentalmente antes de codificar (explicitamente se o escopo for grande):

1. **Camada** — É uma screen, widget reutilizável, provider, repository ou model Isar?
2. **Existe?** — Glob em `features/` e `shared/widgets/` — o componente já existe?
3. **Tema** — Usa `AppColors`, `AppTextStyles`, `AppTheme` — zero hardcode de hex ou tamanho
4. **Estado** — Local (`StateProvider`)? AsyncValue de API? Cache Isar com TTL?
5. **API** — Existe `*_repository.dart` com o método necessário? Usar ou criar via Retrofit
6. **Offline-first** — O dado precisa persistir localmente? → Isar schema + sync strategy
7. **Free vs PRO** — A feature tem gate de plano? Verificar `user.plan` no provider
8. **Navegação** — GoRouter: sub-route do ShellRoute (nav persistente) ou push simples?
9. **Auth** — Endpoint requer JWT? Dio interceptor já injeta — não fazer manualmente
10. **Responsividade** — Testar para telas pequenas (iPhone SE) e grandes (tablet)

---

## Passo 3 — Decisão de Camada

| O que está construindo | Onde vai |
|---|---|
| Tela completa (route) | `features/<f>/presentation/screens/<Name>Screen.dart` |
| Widget de negócio da feature | `features/<f>/presentation/widgets/<name_widget>.dart` |
| Widget genérico reutilizável | `shared/widgets/<name_widget>.dart` |
| Provider de estado/lógica | `features/<f>/providers/<name>_provider.dart` |
| Chamada HTTP + parsing | `features/<f>/data/<name>_repository.dart` |
| Model Isar (persistência local) | `features/<f>/data/models/<Name>Model.dart` |
| Constantes de tema | `core/theme/` — nunca duplicar |
| Configuração de rota | `core/router/app_router.dart` |
| Singleton HTTP (Dio) | `core/network/api_client.dart` |

---

## Convenções de Naming (não negociável)

```
features/tutor/
├── presentation/
│   ├── screens/tutor_screen.dart      # snake_case, sufixo _screen
│   └── widgets/chat_bubble.dart       # snake_case
├── providers/
│   └── tutor_provider.dart            # snake_case, sufixo _provider
└── data/
    ├── tutor_repository.dart          # snake_case, sufixo _repository
    └── models/tutor_message_model.dart
```

- Classes: `PascalCase` (`TutorScreen`, `ChatBubble`)
- Arquivos: `snake_case` (`tutor_screen.dart`)
- Providers codegen: `@riverpod` + função `camelCase` → gerado como `camelCaseProvider`
- Imports dentro da feature: relativos. Para `core/` e `shared/`: package-relative

---

## Tema — Regras Absolutas

```dart
// CORRETO
Container(color: AppColors.backgroundCard)
Text('...', style: AppTextStyles.body)

// ERRADO — nunca
Container(color: Color(0xFF2D1200))         // hardcode
Text('...', style: TextStyle(fontSize: 14)) // fora do sistema de design
```

Paleta canônica (source of truth: `core/theme/app_colors.dart`):

| Token | Hex | Uso |
|---|---|---|
| `background` | `#1A0800` | Scaffold |
| `backgroundCard` | `#2D1200` | Cards, containers |
| `backgroundNav` | `#140600` | Bottom nav |
| `accent` | `#C9922A` | CTAs, ícones ativos |
| `accentLight` | `#D4A84B` | Variações, hover |
| `textPrimary` | `#FFFFFF` | Texto principal |
| `textSecondary` | `#B8A090` | Hints, subtítulos |
| `border` | `#3D2010` | Bordas gerais |
| `inputBg` | `#261000` | Background inputs |
| `error` | `#EF4444` | Erros |

---

## Riverpod — Padrões Obrigatórios

### Provider com codegen (padrão do projeto)

```dart
// features/tutor/providers/tutor_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'tutor_provider.g.dart';

@riverpod
class TutorNotifier extends _$TutorNotifier {
  @override
  Future<List<TutorMessage>> build() async {
    return ref.watch(tutorRepositoryProvider).getMessages();
  }

  Future<void> sendMessage(String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tutorRepositoryProvider).sendMessage(text),
    );
  }
}
```

### Consumir no widget

```dart
// Sempre ConsumerWidget — nunca StatelessWidget puro quando há estado reativo
class TutorScreen extends ConsumerWidget {
  const TutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(tutorNotifierProvider);
    return messages.when(
      data: (msgs) => MessageList(msgs),
      loading: () => const LcfLoadingShimmer(),
      error: (e, _) => LcfErrorState(message: e.toString()),
    );
  }
}
```

### Regras Riverpod

- Nunca ignorar `loading` ou `error` — sempre implementar os três cases do `.when()`
- `ref.watch()` no `build()` para dados reativos; `ref.read()` em callbacks/handlers
- `AsyncNotifier` para providers com side effects; `@riverpod` simples para computados
- Invalidar cache com `ref.invalidate(tutorNotifierProvider)` após mutations

---

## Isar — Padrões Offline-First

```dart
// features/manual/data/models/cached_topic_model.dart
import 'package:isar/isar.dart';
part 'cached_topic_model.g.dart';

@collection
class CachedTopic {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId;     // ID do backend — sync sem duplicatas

  late String title;
  late String content;
  late DateTime cachedAt;   // controle de TTL
  late bool isRead;
}
```

### CRUD Isar

```dart
// Leitura (síncrona — não usar async desnecessário)
final topics = isar.cachedTopics.where().findAll();

// Escrita (sempre em transaction)
await isar.writeTxn(() async {
  await isar.cachedTopics.put(topic);
});

// Verificar TTL antes de usar cache
final isStale = DateTime.now().difference(topic.cachedAt).inHours > 24;
if (isStale) await fetchFromApi(); // re-fetch e atualiza Isar
```

---

## Dio + Retrofit — Padrão de Repository

```dart
// features/tutor/data/tutor_repository.dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'tutor_repository.g.dart';

@RestApi()
abstract class TutorRepository {
  factory TutorRepository(Dio dio, {String? baseUrl}) = _TutorRepository;

  @POST('/tutor/message')
  Future<TutorMessageResponse> sendMessage(@Body() TutorMessageRequest body);

  @DELETE('/tutor/session/{sessionId}')
  Future<void> deleteSession(@Path('sessionId') String id);
}

// Provider do repository (sempre via Riverpod)
@riverpod
TutorRepository tutorRepository(TutorRepositoryRef ref) {
  return TutorRepository(ref.watch(dioProvider));
}
```

O Dio em `core/network/api_client.dart` já injeta `Authorization: Bearer <jwt>` via
interceptor — nunca adicionar header manualmente nos repositories.

### Error Handling em Repository

```dart
// No provider — AsyncValue.guard() captura exceções automaticamente
state = await AsyncValue.guard(() => repo.sendMessage(text));

// Para erros específicos de HTTP status
on DioException catch (e) {
  if (e.response?.statusCode == 429) throw const DailyLimitException();
  if (e.response?.statusCode == 403) throw const PlanGateException();
  rethrow;
}
```

---

## GoRouter — Navegação

```dart
// Push (pode voltar)
context.push('/manual/topic/$topicId');

// Go (substitui stack — sem voltar)
context.go('/dashboard');

// Dados complexos via extra (não via queryParam)
context.push('/simulado/result', extra: ResultArgs(id: id, score: score));

// Acessar o extra na tela destino
final args = GoRouterState.of(context).extra as ResultArgs;
```

ShellRoute define as 4 abas: `/tutor` · `/anotacoes` · `/home` · `/perfil`.
Novas sub-telas de uma aba ficam como GoRoute aninhado dentro do ShellRoute da aba.

---

## Gate Free vs PRO

```dart
// Verificar antes de ação PRO — nunca bloquear silenciosamente
final plan = ref.watch(userPlanProvider);
if (plan == UserPlan.free) {
  LcfProGateSheet.show(context, feature: 'extended_simulado');
  return;
}
```

Limites Free (fonte de verdade: `LCF_Free_vs_PRO.txt`):
- Simulados: 15 questões/dia (backend retorna 429 ao exceder)
- Tutor: sem auto-save de anotações
- Resultados de simulado: sem campo `explanation`

---

## Geração de Código

Sempre que criar/modificar providers Riverpod, models Isar ou clients Retrofit:

```bash
cd front/lcf_app
dart run build_runner build --delete-conflicting-outputs
```

Nunca editar arquivos `.g.dart` manualmente — são gerados pelo build_runner.

---

## Padrões Detalhados (ler conforme necessário)

- `references/patterns.md` — AsyncNotifier completo, Isar CRUD com TTL, Retrofit com
  error handling mapeado, GoRouter com guards de auth, shimmer loading, error states
- `references/api_contract.md` — Todos endpoints LCF: método, rota, auth, body, response
- `references/conventions.md` — Estrutura de pastas completa, pubspec.yaml atual,
  run commands, edge cases de naming

---

## Finalização de Sessão (sempre)

1. `dart run build_runner build --delete-conflicting-outputs` — se criou providers/models
2. `flutter analyze` — zero warnings aceitáveis para merge
3. Atualizar `.claude/PROJECT_STATE.md` — seção Frontend com módulos implementados
4. Criar `.claude/sessions/YYYY-MM-DD_flutter_<feature>.md` com log da sessão
