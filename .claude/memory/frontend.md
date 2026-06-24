---
domain: frontend
updated: 2026-06-24
owner: flutter-lex
---

# Memória de Frontend — LEX

> Flutter 3.x, Riverpod 2.x (codegen), Isar 3.x (offline-first), Dio 5.x, GoRouter. Feature-first.
> Marca: **LEX** (renomeada de LCF em 2026-06-18). Bundle ID `com.lcf.app` ainda não migrado.

---

## Fonte única de design

`AppColors`, `AppTextStyles`, `AppRadius`, `AppSpacing` — nunca hardcodar cor/estilo/raio.
Tema dark escuro/gold. Fonte Inter via GoogleFonts.

## Padrões visuais fixados

- **`LexGlassSheet`** — vidro translúcido 30%, fio dourado no topo via `_GoldTrimPainter` (CustomPainter, só topo seguindo curvatura), respiro lateral 8px, blur sigma 18. **Todo bottom sheet usa `LexGlassSheet`.** Método estático `LexGlassSheet.show<T>()`.
- Telas-bottom-sheet usam rota transparente (`opaque:false` + scrim fade + slide) — nunca página opaca (vidro precisa de conteúdo atrás para frostar).
- `LexMarkdownBody` — widget compartilhado de markdown (bold dourado).
- `LexIcons` — assets de ícone centralizados (aguardando SVGs em `assets/icons/`).

## Utilities globais (code health)

`lexConfirmDialog` (shared/utils/lex_dialogs.dart) · `handleAsyncError` (shared/utils/async_value_handler.dart — 401 centralizado) · `context.bottomPad` (shared/extensions/context_extensions.dart) · `LexGlassSheet.show<T>()`.

## Convenções críticas

- **`useRootNavigator: true`** obrigatório em modais.
- MediaQuery injection para clearance global (não patch por tela).
- Deep links de esquema customizado interceptados em `main.dart` via `SystemChannels.navigation` — nunca chegam ao GoRouter (`uri.origin` em `com.lcf.app://` → StateError corrompe o router).
- Sem retry manual 401 no Dio interceptor (SDK Supabase já gerencia refresh) — evita loop infinito.
- `onboarding_done` (metadata Supabase) é fonte de verdade do roteamento.

## Status sprints Flutter (todos ✅)

F1 Fundação+Auth+Onboarding · F2 Dashboard · F3 Tutor IA · F4 Manual · F5 Simulados ·
F6 Anotações · F7 Perfil+Assinatura · F8 Hardening+Offline (Isar) · F9 Quiz Diagnóstico ·
Visual Icons Refactor (código pronto, aguardando SVGs).

## Build & validação

```
flutter analyze   # zero issues é o portão
dart run build_runner build --delete-conflicting-outputs   # após mudança de model/provider
```
Rodar sempre com `--dart-define=API_BASE_URL=...` (no emulador, `localhost` = o próprio emulador; use Railway ou `10.0.2.2`).

Ver também: [[backend.md]] · [[launch.md]]
