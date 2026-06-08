# Sessão 2026-06-07 — Apple App Store Compliance

## O que foi feito

Implementação dos 6 itens obrigatórios para submissão na Apple App Store, identificados pela skill `lcf-apple-compliance`.

---

## Itens implementados

### Item 1 — Privacy Policy acessível [Guideline 5.1.1.i] ✅
- Criado `front/lcf_app/assets/privacy_policy.md` com menção explícita a Maritaca AI (Sabiá-4) e Anthropic (Claude Sonnet), direitos LGPD e e-mail de contato
- Adicionado link "Política de Privacidade" na `LoginScreen` abaixo de "Criar conta", usando `url_launcher`
- **Pendente externo:** publicar policy em `https://xavierhenrik.github.io/LCF/privacy` e cadastrar URL no App Store Connect

### Item 2 — Consentimento IA de Terceiros [Guideline 5.1.2.i] ✅
- Criado `front/lcf_app/lib/features/tutor/presentation/widgets/tutor_consent_modal.dart` — AlertDialog com `barrierDismissible: false`, texto sobre Maritaca AI e Anthropic, link para Privacy Policy
- Integrado em `TutorScreen.initState` via `addPostFrameCallback` — check em `SharedPreferences` antes de qualquer envio
- Consentimento persistido com chave `tutor_ai_consent_accepted`
- Chave removida no `signOut()` de `AuthNotifier`

### Item 3 — Botão "Excluir conta" na UI [Guideline 5.1.1.v] ✅
- `SegurancaCard` convertido de `StatefulWidget` para `ConsumerStatefulWidget`
- Adicionado `deleteAccount()` ao `PerfilRepository` (chama `DELETE /auth/me`)
- Botão "Excluir conta" com ícone `delete_outline` e cor `AppColors.error` adicionado ao card
- Fluxo: dialog de confirmação → `DELETE /auth/me` → `supabase.auth.signOut()` → `context.go('/login')`

### Item 4 — Disclaimer jurídico no Tutor [Guideline 1.4.1] ✅
- Adicionado container com disclaimer ao `TutorWelcomeCard` (visível no estado vazio antes do 1º envio)
- Texto: "O Tutor LCF tem fins educacionais e não substitui consultoria jurídica profissional."

### Item 5 — Sign in with Apple [Guideline 4.8] ✅
- Adicionado `sign_in_with_apple: ^6.0.0` e `crypto: ^3.0.3` ao `pubspec.yaml`
- Criado `ios/Runner/Runner.entitlements` com `com.apple.developer.applesignin: Default`
- Implementado `signInWithApple()` no `AuthNotifier`:
  - Gera rawNonce + SHA256 hash via `crypto`
  - Chama `SignInWithApple.getAppleIDCredential()` com o hashedNonce
  - Chama `supabase.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken, nonce: rawNonce)`
  - Chama `/auth/verify` (mesmo fluxo Google/email) para sync no backend LCF
- Botão "Entrar com Apple" adicionado na `LoginScreen` imediatamente após botão Google
- **Decisão arquitetural:** usando `signInWithIdToken` do Supabase em vez de endpoint customizado — Supabase já valida tokens Apple natively, elimina necessidade de migration Prisma (`appleId` field)
- **Pendentes externos:**
  - Ativar "Sign In with Apple" nas Signing & Capabilities no Xcode
  - Ativar no Identifier no App Store Connect
  - Referenciar `Runner.entitlements` no Xcode project (`CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`)
  - Ativar Apple como Auth Provider no Supabase Dashboard (Authentication → Providers → Apple)

### Item 6 — RevenueCat SDK + preços dinâmicos [Guideline 3.1.1] ✅
- Adicionado `purchases_flutter: ^7.0.0` ao `pubspec.yaml`
- `Purchases.configure(PurchasesConfiguration(key))` em `main.dart` com guard (`if (key.isNotEmpty)`)
- Adicionado `offeringsProvider` (FutureProvider) em `perfil_provider.dart`
- `SubscriptionScreen` refatorado:
  - Preços `R$249,90` e `R$29,90` hardcoded **removidos**
  - `_PlanCard` recebe `Package?` e exibe `package?.storeProduct.priceString ?? '—'`
  - `_handlePurchase(Package?)` chama `Purchases.purchasePackage()` — sem SnackBar fake
- **Pendentes externos:** `REVENUECAT_APPLE_API_KEY` + produtos IAP criados no App Store Connect

---

## Arquivos modificados

| Arquivo | Mudança |
|---------|---------|
| `front/lcf_app/assets/privacy_policy.md` | NOVO — policy LGPD com menção a Maritaca AI e Anthropic |
| `front/lcf_app/ios/Runner/Runner.entitlements` | NOVO — Apple Sign In capability |
| `front/lcf_app/lib/features/tutor/presentation/widgets/tutor_consent_modal.dart` | NOVO — modal consentimento IA |
| `front/lcf_app/pubspec.yaml` | sign_in_with_apple, crypto, purchases_flutter adicionados |
| `front/lcf_app/lib/main.dart` | RevenueCat.configure com guard |
| `front/lcf_app/lib/features/auth/presentation/screens/login_screen.dart` | Botão Apple + link Privacy Policy |
| `front/lcf_app/lib/features/auth/providers/auth_provider.dart` | signInWithApple() + nonce helpers + clear consent em signOut |
| `front/lcf_app/lib/features/tutor/presentation/screens/tutor_screen.dart` | Consent check em initState |
| `front/lcf_app/lib/features/tutor/presentation/widgets/tutor_welcome_card.dart` | Disclaimer jurídico |
| `front/lcf_app/lib/features/perfil/presentation/widgets/seguranca_card.dart` | ConsumerStatefulWidget + botão Excluir conta |
| `front/lcf_app/lib/features/perfil/data/perfil_repository.dart` | deleteAccount() |
| `front/lcf_app/lib/features/perfil/providers/perfil_provider.dart` | offeringsProvider |
| `front/lcf_app/lib/features/perfil/presentation/screens/subscription_screen.dart` | Preços dinâmicos RevenueCat |
| `CLAUDE.md` | Removido "Sem Apple Sign In — Removido do escopo"; substituído pela decisão correta |

## Critérios de aceite cumpridos

- [x] `flutter analyze` zero issues
- [x] `build_runner` zero erros (949 outputs gerados)
- [x] Nenhum preço BRL hardcoded no código Flutter
- [x] Consentimento modal persiste e não repete em sessões subsequentes
- [x] Delete account: `DELETE /auth/me` (não `admin.deleteUser` direto no Flutter)
- [x] Disclaimer jurídico visível no estado vazio do Tutor
- [x] Botão Apple com equivalência visual ao botão Google
- [x] Decisão "Sem Apple Sign In" revogada no CLAUDE.md

## Pendências / Próximos passos (ações externas)

1. **GitHub Pages:** publicar `assets/privacy_policy.md` em `https://xavierhenrik.github.io/LCF/privacy`
2. **App Store Connect:** cadastrar URL da Privacy Policy em App Info
3. **Xcode:** adicionar capability "Sign In with Apple" em Signing & Capabilities → referencia `Runner.entitlements`
4. **App Store Connect → Identifiers:** ativar "Sign In with Apple" no Bundle ID
5. **Supabase Dashboard:** Authentication → Providers → Apple → ativar e configurar Service ID + Key
6. **RevenueCat:** criar conta, configurar produtos IAP anuais e mensais, obter `REVENUECAT_APPLE_API_KEY`
7. **App Store Connect:** criar produtos IAP (com.lcf.pro.monthly, com.lcf.pro.annual)
8. **App Store Connect:** configurar Age Rating 17+
9. **App Store Connect:** criar conta demo para reviewer

## Decisões tomadas

- Apple Sign In usa `supabase.auth.signInWithIdToken` — não endpoint customizado. Elimina migration Prisma e reutiliza fluxo existente.
- RevenueCat inicializado com guard — app funciona sem key (preços exibem '—'); não há crash.
- Privacy Policy URL apontando para GitHub Pages (padrão para indie devs/startups).
