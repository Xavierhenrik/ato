# Sessão 2026-06-10 — Auth Signup Unificado

## O que foi feito

- **Botões Google + Apple na tela de cadastro** (`cadastro_screen.dart`): adicionados acima do divider "ou cadastre-se com e-mail". Ambos reutilizam `signInWithGoogle` e `signInWithApple` de `auth_provider.dart`.
- **`signInWithGoogle` corrigido**: agora usa flag `_pendingGoogleVerify` + listener em `build()` para chamar `verify()` quando o deep link retorna. Antes, setava `state = AsyncData(null)` imediatamente após `signInWithOAuth` (user ainda era null).
- **`signUp` simplificado**: removido `isNew = result.statusCode == 201` (código morto — backend sempre retorna 200). Retorna `Future<void>`.
- **Roteamento uniforme**: removidos todos os `context.go('/dashboard')` e `context.go('/onboarding')` baseados em `isNew`. O redirect #2/#3 do `app_router.dart` assume o roteamento pós-auth.
- **`getOrCreateUser` → `getUser`** (`auth.service.ts` + `auth.controller.ts`): renomeado; a função só faz `findUnique`, não cria — nome enganoso corrigido.
- **`social_auth_icons.dart`** criado em `shared/widgets/`: `GoogleAuthIcon` e `AppleAuthIcon` extraídos de `login_screen.dart` para evitar duplicação.
- **Deep links registrados**:
  - iOS `Info.plist`: `CFBundleURLTypes` com `CFBundleURLSchemes = com.lcf.app`
  - Android `AndroidManifest.xml`: `intent-filter` com `com.lcf.app://auth-callback` + `android:exported="true"` implícito via activity
- **`purchasePackage` deprecated** corrigido em `subscription_screen.dart`: migrado para `Purchases.purchase(PurchaseParams.package(package))` (API RevenueCat v10).

## Arquivos modificados

- `front/lcf_app/lib/features/auth/providers/auth_provider.dart` — listener Google, flag, signUp simplificado
- `front/lcf_app/lib/features/auth/presentation/screens/login_screen.dart` — remover context.go, usar GoogleAuthIcon/AppleAuthIcon
- `front/lcf_app/lib/features/auth/presentation/screens/cadastro_screen.dart` — remover isNew, adicionar Google+Apple
- `front/lcf_app/lib/features/auth/data/auth_repository.dart` — doc comment atualizado
- `front/lcf_app/lib/shared/widgets/social_auth_icons.dart` — novo arquivo
- `front/lcf_app/lib/features/perfil/presentation/screens/subscription_screen.dart` — fix purchasePackage deprecated
- `front/lcf_app/ios/Runner/Info.plist` — CFBundleURLTypes adicionado
- `front/lcf_app/android/app/src/main/AndroidManifest.xml` — intent-filter OAuth adicionado
- `back/src/modules/auth/auth.service.ts` — getOrCreateUser → getUser
- `back/src/modules/auth/auth.controller.ts` — referência atualizada

## Critérios de aceite cumpridos

- [x] Tela de cadastro exibe os 3 métodos (email, Google, Apple)
- [x] `signInWithGoogle` chama `verify()` após a sessão ser estabelecida (via listener)
- [x] Nenhum método faz `context.go` manual baseado em `isNew`; o router decide onboarding vs dashboard
- [x] Deep link `com.lcf.app://auth-callback` presente em Info.plist e AndroidManifest.xml
- [x] `getOrCreateUser` renomeado para `getUser`; sem código morto de 201/isNew
- [x] `flutter analyze` zero issues
- [x] `cd back && npx tsc --noEmit` zero erros

## Decisões tomadas

- Flag `_pendingGoogleVerify` em vez de listener global para todos os `signedIn`: evita double-call de `verify()` para email/Apple que já chamam explicitamente.
- `DraggableScrollableSheet` expandida de `initialChildSize: 0.65` para `0.75` no cadastro para acomodar os dois botões adicionais.
- `context.pop()` no botão fechar do cadastro substituído por `Navigator.of(context).maybePop()` (mais seguro se não há rota anterior).
