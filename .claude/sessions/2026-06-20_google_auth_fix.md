# Sessão 2026-06-20 — Fix Google Sign-In no emulador

## O que foi feito

Diagnóstico e resolução do Google Sign-In que falhava silenciosamente no emulador Android.

### Causa raiz
O Supabase (staging + live) estava configurado com um Web Client ID antigo
(`330102139110-sljrnei82s2akbub14og7vknc8dbghp4...`, projeto diferente) enquanto o app
enviava idToken com audience `582625704045-pvsmv7a864cr079tpfd9snlsr6mdttjh...`
(projeto Firebase `lex-edtech-ia`). Resultado: `AuthException: Unacceptable audience in id_token status=400`.

### Por que múltiplos agentes falharam
O erro ocorria dentro do `AsyncValue.guard` sem captura de `AuthException` explícita —
a mensagem exibida era genérica. Agentes só liam código e continuavam corrigindo
configurações que já estavam certas (SHA-1, package name, dart-defines).

### O que foi implementado
`auth_provider.dart` — `signInWithGoogle()` reescrito com diagnóstico passo a passo:
- `[GSI-1]` verifica se `GOOGLE_WEB_CLIENT_ID` chegou via dart-define
- `[GSI-2]` captura `PlatformException` com código de erro Google (10=SHA-1, 12501=cancel)
- `[GSI-3]` verifica idToken e accessToken com mensagens específicas
- `[GSI-4]` captura `AuthException` do Supabase com status code
- `[GSI-5]` confirma `/auth/verify` no backend

### Fix definitivo
Supabase Dashboard → Authentication → Providers → Google:
- Client IDs atualizado para: `582625704045-pvsmv7a864cr079tpfd9snlsr6mdttjh.apps.googleusercontent.com`
- Client Secret atualizado (Google Cloud Console → projeto lex-edtech-ia → Web Client)
- Aplicado em **staging** (`zmwufyrpcdlmihjcsajh`) e **live**

## Arquivos modificados

- `front/lex_app/lib/features/auth/providers/auth_provider.dart` — diagnóstico granular no `signInWithGoogle()`

## Critérios de aceite cumpridos

- [x] `flutter analyze` zero issues
- [x] Google Sign-In funciona no emulador (Pixel6 API35)
- [x] `[GSI-5] verify OK` confirmado no debug console

## Decisões tomadas

- Manter os prints `[GSI-*]` no código — são diagnóstico ativo útil para debugging futuro
- `PlatformException` e `AuthException` capturados separadamente para mensagens precisas

## Pendências

- Os prints `[GSI-*]` podem ser removidos antes do build de produção (não são necessários em release)
