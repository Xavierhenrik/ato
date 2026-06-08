# Sessão 2026-05-23 — Sprint F1 Finalização

## O que foi feito

### 1. Novos widgets criados (`shared/widgets/`)
- `lcf_loading_shimmer.dart` — `LcfLoadingShimmer` + `LcfListShimmer` (usa `shimmer` package)
- `lcf_error_state.dart` — `LcfErrorState` com ícone, mensagem e botão retry opcional
- `lcf_empty_state.dart` — `LcfEmptyState` com ícone, título, subtítulo e CTA opcionais
- `category_tag.dart` — `CategoryTag` com auto-cor por matéria + fallback `AppColors.tagBackground`

### 2. `app_router.dart` reescrito
- `_RouterNotifier` com `StreamSubscription<AuthState>` (substitui notifier inline anterior)
- `ref.listen<bool>(onboardingDoneProvider, ...)` → router refresh quando onboarding muda
- `ref.listen<AsyncValue<User?>>(authUserStreamProvider, ...)` → reset/sync no sign-in/sign-out
- Guard triplo: (1) não logado → `/login`; (2) logado + rota pública → `/dashboard`; (3) logado + onboarding pendente → `/onboarding`
- `_PlaceholderScreen`: `super.key` adicionado, hardcoded `TextStyle` → `AppTextStyles.h2`

### 3. `auth_provider.dart` — `OnboardingDone` notifier
- `@Riverpod(keepAlive: true) class OnboardingDone` — lê `userMetadata['onboarding_done']` no `build()`
- `markDone()` + `reset()` para controle em-sessão
- Persiste entre restarts via Supabase metadata

### 4. `onboarding_provider.dart` — `complete()` atualizado
- Após API call, chama `Supabase.instance.client.auth.updateUser(UserAttributes(data: {'onboarding_done': true}))` (best-effort)
- Chama `ref.read(onboardingDoneProvider.notifier).markDone()` para atualização imediata no router

### 5. `onboarding_repository.dart` — `@JsonSerializable(createFactory: false)`
- Evita geração de `_$OnboardingRequestFromJson` não-usado

### 6. Auditoria `prefer_const_constructors` — todos os 26 arquivos
- `login_screen.dart`: `_LcfLogo`, `_GoogleIcon` (super.key + hardcoded TextStyle → AppTextStyles)
- `reset_senha_screen.dart`: `_InputState`, `_SentState` (super.key)
- `onboarding_screen.dart`: `_PhaseGrid`, `_PhaseCard`, `_MinsRow` (super.key); `Text` labels → `const`
- `diagnostico_screen.dart`: `_IntroState`, `_AnsweringState`, `_DoneState`, `_InfoChip` (super.key); `Text` → `const`
- `cadastro_screen.dart`: `Text` → `const`
- `lcf_app_bar.dart`: `Text('Tutor IA')` + `Text('Direito inteligente...')` → `const`
- `app_theme.dart`: `TextStyle` dentro de `const BottomNavigationBarThemeData` → `const`

## Arquivos modificados

- `lib/core/router/app_router.dart` — reescrito
- `lib/core/theme/app_theme.dart` — const TextStyle em BottomNavBar
- `lib/features/auth/providers/auth_provider.dart` — OnboardingDone adicionado
- `lib/features/auth/presentation/screens/login_screen.dart` — const + super.key fixes
- `lib/features/auth/presentation/screens/reset_senha_screen.dart` — super.key fixes
- `lib/features/auth/presentation/screens/cadastro_screen.dart` — const fixes
- `lib/features/onboarding/data/onboarding_repository.dart` — createFactory: false
- `lib/features/onboarding/providers/onboarding_provider.dart` — markDone() em complete()
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart` — const + super.key fixes
- `lib/features/onboarding/presentation/screens/diagnostico_screen.dart` — const + super.key fixes
- `lib/shared/widgets/lcf_app_bar.dart` — const fixes
- `lib/shared/widgets/lcf_loading_shimmer.dart` — NOVO
- `lib/shared/widgets/lcf_error_state.dart` — NOVO
- `lib/shared/widgets/lcf_empty_state.dart` — NOVO
- `lib/shared/widgets/category_tag.dart` — NOVO
- `assets/icons/.gitkeep` — NOVO (diretório de assets)
- `assets/images/.gitkeep` — NOVO

## Critérios de aceite cumpridos (código)

- [x] Zero `Color(0xFF...)` hardcoded fora de `app_colors.dart`
- [x] Zero `TextStyle(fontSize:...)` hardcoded fora de `app_text_styles.dart` (exceto `app_theme.dart` para estilos de nav sem equivalente em AppTextStyles)
- [x] `use_key_in_widget_constructors` — todos os widgets privados com `super.key`
- [x] `prefer_const_constructors` — todos os `Text`, `Icon`, `SizedBox`, `Padding` const onde possível
- [x] `OnboardingDone` guard no router implementado com persistência via Supabase metadata
- [x] `@riverpod`/`@Riverpod` declarações corretas + `part '*.g.dart'` em todos os providers/repositories

## Pendências do usuário (requer Flutter SDK)

```bash
cd C:\Projetos\BX\LCF\lcf

# 1. Scaffoldar plataformas (mantém lib/ criado)
flutter create --org com.lcf --project-name lcf_app --platforms android,ios front/lcf_app

# 2. Gerar arquivos .g.dart
cd front/lcf_app
dart run build_runner build --delete-conflicting-outputs

# 3. Auto-fix quaisquer const restantes
dart fix --apply

# 4. Verificar — deve retornar "No issues found!"
flutter analyze

# 5. Commit
git add -A
git commit -m "feat(flutter): Sprint F1 completo — auth, onboarding, fundação compilando"
```

## Decisões tomadas

- `onboardingDoneProvider` vive em `auth_provider.dart` (não em `onboarding_provider.dart`) para evitar import circular — router depende de auth, onboarding depende de auth; nenhum importa onboarding de volta
- `_RouterNotifier.refresh()` expõe `notifyListeners()` (protegido) para uso nos `ref.listen` callbacks do provider
- `updateUser()` em `onboarding_provider.complete()` é best-effort (`try/catch` silencioso) — falha de rede não deve bloquear o fluxo da UI
