# Sessão 2026-06-18 — Renomeação LCF → LEX

## O que foi feito

Renomeação completa de marca LCF → LEX em todo o codebase, executada por cadeia de 5 subagentes.

## Arquivos modificados

### Backend (`back/src/`)
- `src/server.ts` — log startup: "LCF Backend" → "LEX Backend"
- `src/modules/auth/auth.routes.ts` — comentário: "usuário LCF" → "usuário LEX"
- `src/modules/tutor-ia/prompts/system.prompt.ts` — persona: "Tutora IA do LCF" → "Lexia, Tutora IA do LEX"
- `src/modules/simulados/profile-analysis.service.ts` — coach prompt: "LCF" → "LEX"
- `back/CLAUDE.md` — heading: "LCF Backend" → "LEX Backend"

### Flutter (`front/lcf_app/lib/`)
**Widgets renomeados (arquivo + classe):**
- `shared/widgets/lcf_app_bar.dart` → `lex_app_bar.dart` (LcfAppBar, LcfTutorAppBar)
- `shared/widgets/lcf_button.dart` → `lex_button.dart` (LcfButton, LcfButtonVariant)
- `shared/widgets/lcf_empty_state.dart` → `lex_empty_state.dart` (LcfEmptyState)
- `shared/widgets/lcf_error_state.dart` → `lex_error_state.dart` (LcfErrorState)
- `shared/widgets/lcf_glass_nav_bar.dart` → `lex_glass_nav_bar.dart` (LcfGlassNavBar)
- `shared/widgets/lcf_glass_sheet.dart` → `lex_glass_sheet.dart` (LcfGlassSheet)
- `shared/widgets/lcf_loading_shimmer.dart` → `lex_loading_shimmer.dart` (LcfLoadingShimmer, LcfListShimmer)
- `shared/widgets/lcf_markdown_body.dart` → `lex_markdown_body.dart` (LcfMarkdownBody)
- `shared/widgets/lcf_text_field.dart` → `lex_text_field.dart` (LcfTextField)
- `shared/widgets/lcf_top_scrim.dart` → `lex_top_scrim.dart` (LcfTopScrim)
- `features/perfil/presentation/widgets/lcf_pro_banner_card.dart` → `lex_pro_banner_card.dart` (LcfProBannerCard)

**Arquivos de feature atualizados (imports + class names):**
- core/router/app_router.dart
- features/anotacoes/presentation/screens/anotacoes_screen.dart
- features/auth/presentation/screens/cadastro_screen.dart
- features/auth/presentation/screens/login_screen.dart
- features/auth/presentation/screens/reset_senha_screen.dart
- features/dashboard/presentation/widgets/ (4 arquivos)
- features/manual/presentation/screens/ (2 arquivos)
- features/manual/presentation/widgets/ (2 arquivos)
- features/onboarding/presentation/screens/ (2 arquivos)
- features/perfil/presentation/screens/ (2 arquivos)
- features/simulados/presentation/screens/ (3 arquivos)
- features/tutor/presentation/screens/ (3 arquivos)
- features/tutor/presentation/widgets/chat_bubble.dart
- shared/widgets/pro_gate_sheet.dart
- shared/widgets/scaffold_with_nav.dart

**pubspec.yaml:** `name: lcf_app` → `name: lex_app`, description atualizada

## Critérios de aceite cumpridos
- [x] Backend: `tsc --noEmit` zero erros (verificado pelo agente backend)
- [x] Flutter: zero resíduos de `lcf_` ou `Lcf` em arquivos não-gerados (verificado pelo agente de features)
- [x] pubspec.yaml: `name: lex_app` confirmado

## Pendências / Próximos passos
- [ ] Rodar `dart run build_runner build --delete-conflicting-outputs` em `front/lex_app/` para regenerar `.g.dart` files
- [ ] Testar `flutter analyze` após build_runner
- [ ] Bundle ID Android/iOS: `com.lcf.app` → `com.lex.app` (requer mudança manual em AndroidManifest.xml, build.gradle, Info.plist, Xcode project; e atualizar Supabase OAuth redirect URL de `com.lcf.app://auth-callback` para `com.lex.app://auth-callback`)
- [x] Skill files `.claude/skills/lcf-*` → `lex-*` ✅ 2026-06-19
- [x] Diretório `front/lcf_app/` → `front/lex_app/` ✅ 2026-06-19 (diretório vazio residual — deletar manualmente: `rmdir lcf\front\lcf_app`)

## Decisões tomadas
- Bundle ID mantido temporariamente: mudança afeta Supabase OAuth, App Store Connect, Google Play Console — requer ciclo de deploy coordenado
