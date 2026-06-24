---
domain: launch
updated: 2026-06-24
owner: lex-infra + lex-apple-compliance
---

# Memória de Lançamento — LEX

> Checklist de produção. App quase pronto para submeter. Bloqueantes ordenados por dependência.

---

## Bloqueantes ordenados (cadeia de dependência)

1. **Licença Apple Developer ($99/ano)** — desbloqueia toda a cadeia iOS. Pagar só quando pronto para submeter.
2. **App IDs Apple/Google** — bloqueia RevenueCat (preços dinâmicos) e Apple Sign In em produção.
3. **Xcode:** ativar capability *Sign In with Apple* (Guideline 4.8 — obrigatório pois há Google OAuth). Aguarda licença + Mac.
4. **Apple Developer Portal:** Services ID + Key `.p8`.
5. **Supabase:** ativar Apple Auth Provider (depende do passo 4).
6. **App Store Connect:** Age Rating 17+, conta demo, URL da privacy policy.
7. **RevenueCat:** produtos IAP + `REVENUECAT_APPLE_API_KEY` (depende de App Store Connect).

## Pendências de infra para o go-live

| Item | Ação | Memória |
|------|------|---------|
| Railway Root Directory | `/` → `back` (Settings → Source) | [[infra.md]] |
| `CORS_ORIGIN` produção | restringir às origens reais | [[security.md]] |
| `SENTRY_DSN` | provisionar projeto + DSN (front + back) | [[infra.md]] |
| OneSignal | `ONESIGNAL_APP_ID` + `ONESIGNAL_API_KEY` | [[infra.md]] |
| Privacy Policy URL | deploy de `docs/privacy/index.html` (repo privado — GH Pages requer plano pago) | — |
| Domínio + Cloudflare | configurar CDN | [[infra.md]] |

## Pricing PRO (definido)

R$29,90/mês · R$249,90/ano (badge "Economize 30%"). Break-even ~30 assinantes. Grade store Apple/Google.

## Fora do MVP de lançamento

- Módulo 2ª fase OAB (validar 1ª fase primeiro).
- pgvector/RAG (v1.1).
- Memória entre sessões da Lexia (v2.0).
- Transcrição de voz / Whisper (v1.1).

## Compliance Apple já implementado

Privacy Policy (HTML pronto), Consent Modal IA, Delete Account UI, Disclaimer jurídico, Sign in with Apple (código), RevenueCat dynamic prices. Ver skill `lex-apple-compliance`.

Ver também: [[infra.md]] · [[security.md]]
