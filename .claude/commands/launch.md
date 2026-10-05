---
description: Checklist de lançamento — infra + segurança + Apple compliance + QA
argument-hint: "[opcional: área específica]"
---

# /launch — Orquestrador de Lançamento

Verifica se o ATO está pronto para submeter às lojas. App quase pronto — este command audita o que falta.

## Fluxo

1. Carregue `.claude/memory/launch.md` — a cadeia de bloqueantes ordenada.
2. Acione cada guardião:
   - **`ato-infra`** — Railway Root Directory, CORS produção, Sentry, OneSignal, domínio/Cloudflare.
   - **`ato-security`** — postura final (secrets, CORS, LGPD, deleção de conta).
   - skill **`ato-apple-compliance`** — Sign in with Apple, privacy policy URL, Age Rating, conta demo.
   - skill **`ato-qa`** — fluxos críticos passam fim-a-fim.
3. Consolide num **checklist go/no-go** com o próximo bloqueante da cadeia de dependência (licença Apple → App IDs → Xcode → Portal → Supabase → App Store Connect → RevenueCat).
4. Atualize `launch.md` com o estado de cada item.

## Saída
Tabela go/no-go: item · responsável · estado · bloqueia o quê. Honestidade: nada de "pronto" sem evidência.
