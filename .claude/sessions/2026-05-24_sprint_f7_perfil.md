# Sessão 2026-05-24 — Sprint F7 Perfil + Assinatura PRÓ

## O que foi feito

Sprint F7 completo: telas de Perfil e Assinatura PRÓ conforme SCREENS.md seções 7 e 8.

## Arquivos criados

- `lib/features/perfil/data/models/perfil_models.dart` — `UserProfile` com `isPro` getter
- `lib/features/perfil/data/perfil_repository.dart` — `getProfile()` + `updateProfile()` via Dio
- `lib/features/perfil/data/perfil_repository.g.dart` — gerado pelo build_runner
- `lib/features/perfil/providers/perfil_provider.dart` — `perfilDataProvider` (AutoDisposeFuture)
- `lib/features/perfil/providers/perfil_provider.g.dart` — gerado pelo build_runner
- `lib/features/perfil/presentation/widgets/profile_header.dart` — avatar círculo + badge PRÓ
- `lib/features/perfil/presentation/widgets/dados_pessoais_card.dart` — nome + email (read-only MVP)
- `lib/features/perfil/presentation/widgets/seguranca_card.dart` — reset password inline feedback
- `lib/features/perfil/presentation/widgets/lcf_pro_banner_card.dart` — variante Free/PRO + url_launcher
- `lib/features/perfil/presentation/widgets/preferencias_card.dart` — tema decorativo + badge "Em breve"
- `lib/features/perfil/presentation/screens/perfil_screen.dart` — scroll com todos os cards + signOut
- `lib/features/perfil/presentation/screens/subscription_screen.dart` — planos Mensal/Anual + CTA stub

## Arquivos modificados

- `pubspec.yaml` — adicionado `url_launcher: ^6.2.0` (resolveu como 6.3.2)
- `lib/core/router/app_router.dart` — `/subscription` GoRoute adicionado; `/perfil` substituído de `_PlaceholderScreen` para `PerfilScreen()`

## Decisões tomadas

| Decisão | Motivo |
|---------|--------|
| url_launcher adicionado no F7 | LcfProBannerCard PRO precisa abrir RevenueCat managementURL; TODO(F8) para URL real via Purchases.managementURL |
| RevenueCat purchase como stub com SnackBar | F8 Hardening integrará SDK; por ora evita bloqueio de release |
| DadosPessoaisCard read-only | MVP — sem upload avatar, sem CPF/telefone (campos não existem no schema Prisma) |
| SegurancaCard: StatefulWidget (não ConsumerStatefulWidget) | Apenas estado local (loading + feedback); Supabase acessado diretamente via `Supabase.instance.client` |
| /subscription fora do ShellRoute | Tela push sem BottomNav — acesso via context.push('/subscription') |
| Preços: R$29,90/mês · R$249,90/ano | Conforme conflito resolvido no briefing; anual selecionado por padrão |

## Critérios de aceite cumpridos

- [x] PerfilScreen com ProfileHeader (badge Membro PRÓ apenas se plan==pro)
- [x] DadosPessoaisCard nome + email (read-only)
- [x] SegurancaCard: resetPasswordForEmail com feedback in-line (sem navegação)
- [x] LcfProBannerCard variante Free (CTA → /subscription) e PRO (features + Gerenciar plano via url_launcher)
- [x] PreferenciasCard decorativa com badge "Em breve"
- [x] Botão "Sair" → signOut() → context.go('/login')
- [x] SubscriptionScreen: grid 2×2 features, plan cards Mensal/Anual, anual selecionado por padrão
- [x] Preços corretos: R$29,90/mês · R$249,90/ano
- [x] Badge "Economize 30%" no plano anual
- [x] CTA "Assinar e ativar plano PRÓ" → _handlePurchase() stub com SnackBar
- [x] Estado "Você já é PRÓ" se plan==pro (sem botão de compra)
- [x] Rodapé 🔒 "Ambiente 100% seguro com criptografia"
- [x] build_runner: 2 .g.dart gerados corretamente
- [x] flutter analyze: zero issues

## Pendências / Próximos passos

- F6 — Anotações (já marcado como concluído no PROJECT_STATE — verificar se realmente está implementado)
- F8 — Hardening + Offline: integrar RevenueCat SDK (substituir TODO(F8) em lcf_pro_banner_card.dart e subscription_screen.dart)
- F8 — Configurar url_launcher no iOS (Info.plist) e Android (AndroidManifest.xml) para LSApplicationQueriesSchemes
