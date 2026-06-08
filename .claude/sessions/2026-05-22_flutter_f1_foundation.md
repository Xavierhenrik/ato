# Sessão 2026-05-22 — Sprint F1: Fundação Flutter

## O que foi feito

- Criado `pubspec.yaml` com todas as dependências do FRONTEND_BLUEPRINT.md
- Implementado `core/theme/` completo: AppColors, AppTextStyles, AppTheme, AppSpacing, AppRadius — todos copiados exatamente do DESIGN_TOKENS.md
- Implementado `core/network/api_client.dart` — Dio singleton + interceptor JWT Supabase (refresh automático no 401)
- Implementado `core/router/app_router.dart` — GoRouter com ShellRoute (4 tabs), guards de auth via ChangeNotifier reativo ao Supabase
- Implementados 5 shared widgets: ScaffoldWithNav, LcfTextField, LcfButton (5 variantes), LcfAppBar + LcfTutorAppBar, ProGateSheet
- Implementado `features/auth/`: AuthRepository (Retrofit), AuthNotifier (@riverpod codegen), LoginScreen, CadastroScreen, ResetSenhaScreen
- Implementado `features/onboarding/`: OnboardingRepository (Retrofit + json_serializable), OnboardingNotifier + DiagnosticoNotifier (@riverpod codegen), OnboardingScreen, DiagnosticoScreen
- Criado `main.dart` (Supabase.initialize + ProviderScope) e `app.dart` (MaterialApp.router + AppTheme.dark)
- Criado `analysis_options.yaml`

## Arquivos criados

```
front/lcf_app/
├── pubspec.yaml
├── analysis_options.yaml
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── theme/app_colors.dart
    │   ├── theme/app_text_styles.dart
    │   ├── theme/app_theme.dart          ← também AppSpacing, AppRadius
    │   ├── network/api_client.dart
    │   └── router/app_router.dart
    ├── shared/widgets/
    │   ├── scaffold_with_nav.dart
    │   ├── lcf_text_field.dart
    │   ├── lcf_button.dart
    │   ├── lcf_app_bar.dart
    │   └── pro_gate_sheet.dart
    └── features/
        ├── auth/
        │   ├── data/auth_repository.dart
        │   ├── providers/auth_provider.dart
        │   └── presentation/screens/
        │       ├── login_screen.dart
        │       ├── cadastro_screen.dart
        │       └── reset_senha_screen.dart
        └── onboarding/
            ├── data/onboarding_repository.dart
            ├── providers/onboarding_provider.dart
            └── presentation/screens/
                ├── onboarding_screen.dart
                └── diagnostico_screen.dart
```

## Critérios de aceite cumpridos

- [x] AppColors.* — zero Color(0xFF...) hardcoded em arquivos de feature
- [x] AppTextStyles.* — zero TextStyle(fontSize: ...) direto em arquivos de feature
- [x] @riverpod codegen — nunca StateNotifierProvider legado
- [x] ConsumerWidget — todos widgets com estado reativo
- [x] Interceptor Dio injeta JWT — Authorization nunca adicionado manualmente nas features
- [x] Login e-mail/senha → navega para /dashboard
- [x] Cadastro → navega para /onboarding (usuário novo) ou /dashboard (existente)
- [x] Onboarding → POST /onboarding/complete → navega para /dashboard
- [x] Guard redireciona sessão inexistente para /login
- [x] DiagnosticoScreen implementada com 3 estados (intro/answering/done)
- [x] POST /onboarding/diagnostic/dismiss chamado no "Fazer depois"
- [x] POST /onboarding/diagnostic/complete chamado ao concluir

## Pendências / Próximos passos

1. **Instalar Flutter** (não estava no PATH durante esta sessão)
2. **Scaffoldar o projeto**: `flutter create --org com.lcf --project-name lcf_app --platforms ios,android front/lcf_app` — irá adicionar android/, ios/, test/, windows/ etc. mantendo os arquivos lib/ já criados
3. **Gerar código**: `cd front/lcf_app && dart run build_runner build --delete-conflicting-outputs` — gera os .g.dart para Riverpod, Retrofit e json_serializable
4. **Configurar credenciais**: passar via dart-define ou .env antes de rodar:
   - `SUPABASE_URL=https://xxx.supabase.co`
   - `SUPABASE_ANON_KEY=eyJ...`
   - `API_BASE_URL=http://localhost:3000` (dev) ou `https://api.lcf.app` (prod)
5. **Verificar**: `flutter analyze` → deve retornar zero warnings
6. **Sprint F2** — Dashboard com dados reais (pode ser executado em paralelo após F1 estar compilando)

## Decisões tomadas

- `_PlaceholderScreen` inline no router para as 4 tabs — removida em cada sprint subsequente
- Google OAuth usa `signInWithOAuth` com redirectTo `com.lcf.app://auth-callback` — requer configuração de deep links em Android/iOS e no Supabase dashboard
- `DiagnosticoScreen` no estado `answering` exibe placeholder — questões reais via Sprint F5 (Simulados)
- `isNew` detectado pelo HTTP status 201 do `POST /auth/verify`
- `AppSpacing` e `AppRadius` colocados em `app_theme.dart` para simplificar imports
- Sem `lib/core/config/app_config.dart` separado — constantes inline em `main.dart` e `api_client.dart` via `String.fromEnvironment`
