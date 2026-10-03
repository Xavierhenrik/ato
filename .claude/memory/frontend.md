---
domain: frontend
updated: 2026-06-24
owner: flutter-ato
---

# Memória de Frontend — ATO

> Flutter 3.x, Riverpod 2.x (codegen), Isar 3.x (offline-first), Dio 5.x, GoRouter. Feature-first.
> Marca: **ATO** desde 2026-10-03 (LCF até 18/06, LEX até 03/10). App ID `com.bx.ato.app` no Android e no iOS; deep link `com.bx.ato.app://auth-callback`.

---

## Fonte única de design

`AppColors`, `AppTextStyles`, `AppRadius`, `AppSpacing` — nunca hardcodar cor/estilo/raio.
Tema dark escuro/gold. Fonte Inter via GoogleFonts.

## Padrões visuais fixados

- **`AtoGlassSheet`** — vidro translúcido 30%, fio dourado no topo via `_GoldTrimPainter` (CustomPainter, só topo seguindo curvatura), respiro lateral 8px, blur sigma 18. **Todo bottom sheet usa `AtoGlassSheet`.** Método estático `AtoGlassSheet.show<T>()`.
- Telas-bottom-sheet usam rota transparente (`opaque:false` + scrim fade + slide) — nunca página opaca (vidro precisa de conteúdo atrás para frostar).
- `AtoMarkdownBody` — widget compartilhado de markdown (bold dourado).
- `AtoIcons` — assets de ícone centralizados (aguardando SVGs em `assets/icons/`).

## Utilities globais (code health)

`atoConfirmDialog` (shared/utils/ato_dialogs.dart) · `handleAsyncError` (shared/utils/async_value_handler.dart — 401 centralizado) · `context.bottomPad` (shared/extensions/context_extensions.dart) · `AtoGlassSheet.show<T>()`.

## Convenções críticas

- **`useRootNavigator: true`** obrigatório em modais.
- MediaQuery injection para clearance global (não patch por tela).
- Deep links de esquema customizado interceptados em `main.dart` via `SystemChannels.navigation` — nunca chegam ao GoRouter (`uri.origin` em `com.bx.ato.app://` → StateError corrompe o router).
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
