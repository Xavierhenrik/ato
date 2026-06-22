# Sessão 2026-06-18 — Fix Emulador (Tela Preta + 401)

## O que foi feito

Diagnóstico e correção completa da regressão do emulador Android.

## Causa Raiz — Tela Preta

**Impeller rendering failure (`Width is zero. 0,0`).**

O emulador `LCF_Pixel6_API35:5554` usa o backend `Impeller (OpenGLES)`. Em condições
específicas (estado do emulador, versão do Flutter), o surface não recebe suas dimensões
antes de `runApp()` terminar — `FlutterRenderer` reporta `Width is zero. 0,0`, o frame
nunca é renderizado, e o emulador mostra tela preta.

O bug NÃO era relacionado ao código do app nem à migration SQL.

## Correção 1 — Impeller (debug only)

**Arquivo:** `front/lcf_app/android/app/src/debug/AndroidManifest.xml`

Adicionado `<meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false"/>` apenas no override de debug.

- Builds de release: Impeller **ativo** (melhor performance em dispositivo real)
- Builds de debug: Impeller **desabilitado** (evita `Width is zero` no emulador)

## Causa Raiz — 401 Unauthorized (pós-reboot do emulador)

**Race condition entre token refresh e chamadas de API.**

Após reboot do emulador, `Supabase.recoverSession()` é assíncrono. O router vê
`currentUser != null` (sessão cacheada) e navega para o dashboard. O dashboard
faz chamadas ao backend com o access token expirado → 401.

## Correção 2 — Interceptor Dio com retry em 401

**Arquivo:** `front/lcf_app/lib/core/network/api_client.dart`

Adicionado `onError` no interceptor Dio:
1. Em 401 (primeira tentativa): chama `Supabase.refreshSession()`
2. Se refresh OK: repete a requisição com o novo token
3. Se refresh falha (token expirado de vez): propaga o erro original
4. Flag `_kRetried` previne loop infinito caso o backend rejeite por outro motivo

## Diagnóstico do backend pós-migration

Verificado:
- `sprint1_manual.sql`: contém `CREATE TABLE tutor_sessions` com `msg_count` ✅
- `tutor_history.sql`: adiciona apenas `title text` + index ✅ (não foi a causa)
- `camada2_weak_topics.sql`: adiciona `weak_topics` + `analyzed_at` em `study_plans` ✅
- `npx tsc --noEmit` no backend: zero erros ✅
- `flutter analyze`: zero erros ✅

## Arquivos modificados

- `front/lcf_app/android/app/src/debug/AndroidManifest.xml` — Impeller desabilitado em debug
- `front/lcf_app/lib/core/network/api_client.dart` — retry em 401 com refresh token

## Estado verificado

Dashboard renderizando com dados reais do staging:
- Metas diárias: 0/10 questões ✅
- Revisão inteligente: Penal + Civil ✅
- Cards de matérias: 15 questões respondidas, 8 matérias ativas ✅
- 0 erros no processo Flutter após os fixes ✅

## Como rodar o app (correto)

```bash
# Via VS Code (recomendado — usa dart-defines corretos)
# Seleção: "LCF — Staging (debug)"

# Via terminal
cd front/lcf_app
flutter run -d emulator-5554 --dart-define-from-file=dart-defines/staging.json
```

**Atenção:** não usar `flutter run` sem `--dart-define-from-file` — usará as credenciais
placeholder (`YOUR_PROJECT.supabase.co`) e mostrará tela preta por outro motivo.

## Pendências

- Impeller deprecated warning: quando Flutter remover a opção `EnableImpeller`, testar
  se o emulador API 35 renderiza corretamente com o Impeller atual. Abrir issue no
  Flutter se necessário.
