# Flutter ATO — Convenções e Estrutura Completa

## Estrutura de Pastas

```
front/ato_app/
├── lib/
│   ├── main.dart                          # Entry point — ProviderScope + runApp
│   ├── app.dart                           # MaterialApp.router + AppTheme + appRouter
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart            # Paleta — única fonte de verdade de cores
│   │   │   ├── app_text_styles.dart       # TextStyle constants
│   │   │   └── app_theme.dart             # ThemeData dark
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter + guards de auth
│   │   ├── network/
│   │   │   ├── api_client.dart            # Dio singleton com interceptor JWT
│   │   │   └── api_endpoints.dart         # Constantes de rota (opcional)
│   │   └── providers/
│   │       ├── isar_provider.dart         # Isar singleton keepAlive
│   │       └── supabase_provider.dart     # Supabase auth state provider
│   ├── features/
│   │   ├── auth/
│   │   │   ├── presentation/screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── onboarding_screen.dart
│   │   │   ├── providers/auth_provider.dart
│   │   │   └── data/auth_repository.dart
│   │   ├── tutor/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/tutor_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── welcome_card.dart
│   │   │   │       ├── suggestions_section.dart
│   │   │   │       ├── suggestion_chip_card.dart
│   │   │   │       ├── chat_bubble.dart
│   │   │   │       ├── tutor_empty_state.dart
│   │   │   │       └── chat_input_bar.dart
│   │   │   ├── providers/tutor_provider.dart
│   │   │   └── data/
│   │   │       ├── tutor_repository.dart
│   │   │       └── models/
│   │   │           ├── tutor_message_model.dart
│   │   │           └── tutor_session_model.dart
│   │   ├── dashboard/
│   │   │   ├── presentation/screens/dashboard_screen.dart
│   │   │   ├── providers/dashboard_provider.dart
│   │   │   └── data/dashboard_repository.dart
│   │   ├── manual/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── manual_screen.dart
│   │   │   │   │   └── topic_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── providers/topics_provider.dart
│   │   │   └── data/
│   │   │       ├── manual_repository.dart
│   │   │       └── models/cached_topic_model.dart
│   │   ├── simulados/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── simulado_config_screen.dart
│   │   │   │   │   ├── simulado_screen.dart
│   │   │   │   │   └── simulado_result_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── providers/simulado_provider.dart
│   │   │   └── data/simulado_repository.dart
│   │   └── anotacoes/
│   │       ├── presentation/
│   │       │   ├── screens/
│   │       │   │   ├── anotacoes_screen.dart
│   │       │   │   └── anotacao_detail_screen.dart
│   │       │   └── widgets/
│   │       ├── providers/anotacoes_provider.dart
│   │       └── data/anotacoes_repository.dart
│   └── shared/
│       ├── widgets/
│       │   ├── ato_bottom_nav.dart        # ScaffoldWithNav (ShellRoute wrapper)
│       │   ├── ato_app_bar.dart
│       │   ├── ato_loading_shimmer.dart
│       │   ├── ato_error_state.dart
│       │   └── ato_pro_gate_sheet.dart
│       └── models/
│           └── user_plan.dart             # enum UserPlan { free, pro }
├── assets/
│   ├── images/                            # PNGs, ilustrações
│   └── icons/                            # SVGs de ícones custom
└── pubspec.yaml
```

---

## pubspec.yaml (versões atuais)

```yaml
name: ato_app
description: ATO — Direito inteligente para sua aprovação
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0
  dio: ^5.4.3
  retrofit: ^4.1.0
  supabase_flutter: ^2.5.3
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.0
  retrofit_generator: ^8.1.0
  isar_generator: ^3.1.0+1
  json_annotation: ^4.9.0
  json_serializable: ^6.8.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - .env
```

---

## Comandos Frequentes

```bash
# Instalar dependências
cd front/ato_app && flutter pub get

# Gerar código (providers, models, repositories)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (desenvolvimento)
dart run build_runner watch --delete-conflicting-outputs

# Análise estática
flutter analyze

# Run iOS
flutter run -d iphone

# Run Android
flutter run -d android

# Build release iOS
flutter build ios --release

# Build release Android
flutter build appbundle --release
```

---

## Edge Cases de Naming

| Situação | Errado | Correto |
|----------|--------|---------|
| Widget com múltiplas palavras | `ChatInputbar.dart` | `chat_input_bar.dart` |
| Provider de lista | `topicsProvider` | `topicsNotifierProvider` (gerado do `TopicsNotifier`) |
| Model com JSON | `TopicModel.dart` | `topic_model.dart` + part `.g.dart` |
| Screen de detalhe | `TopicScreen.dart` | `topic_detail_screen.dart` |
| Repository interface | `ITopicRepository` | não usar — Retrofit gera a impl diretamente |
| Arquivo gerado | editar `topic_provider.g.dart` | NUNCA — é gerado pelo build_runner |

---

## Bundle ID e Configuração

- **App ID:** `com.bx.ato.app` (Android e iOS)
- **App name:** `ATO`
- **Env vars** (em `.env` na raiz de `front/ato_app/`):
  ```
  API_BASE_URL=http://localhost:3000
  SUPABASE_URL=<supabase_project_url>
  SUPABASE_ANON_KEY=<supabase_anon_key>
  ```
- `.env` não é commitado — verificar `.gitignore`

---

## Material 3 + Dark Theme

O app usa Material 3 (`useMaterial3: true`) com `ThemeData` dark configurado em
`core/theme/app_theme.dart`. O `ColorScheme` mapeia:

- `primary` → `AppColors.accent` (gold)
- `surface` → `AppColors.backgroundCard`
- `background` → `AppColors.background`

Sempre preferir widgets Material 3 (`FilledButton`, `Card`, `NavigationBar`)
quando disponíveis, mas ajustar com `style` usando `AppColors` — não confiar nos
defaults do tema para cores específicas do design.
