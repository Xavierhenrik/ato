# LCF Backend — Environment Checklist

Variáveis obrigatórias antes do primeiro deploy. Copie `.env.example` para `.env`.

---

## Banco de Dados

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `DATABASE_URL` | Supabase → Settings → Database → Connection string (Transaction mode, port 6543) | Sim |

---

## Supabase Auth

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `SUPABASE_URL` | Supabase → Settings → API → Project URL | Sim |
| `SUPABASE_ANON_KEY` | Supabase → Settings → API → anon public | Sim |
| `SUPABASE_JWT_PUBLIC_KEY` | Supabase → Settings → API → JWT → RS256 public key (PEM) | Sim |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Settings → API → service_role | Sim (deleção de conta) |

---

## Redis (Upstash)

Criar em [upstash.com](https://upstash.com) → New Database → Region: us-east-1

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `UPSTASH_REDIS_REST_URL` | Upstash Console → REST API → UPSTASH_REDIS_REST_URL | Sim |
| `UPSTASH_REDIS_REST_TOKEN` | Upstash Console → REST API → UPSTASH_REDIS_REST_TOKEN | Sim |

---

## LLM — Anthropic (Claude Sonnet)

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `ANTHROPIC_API_KEY` | console.anthropic.com → API Keys | Sim (M4) |

---

## LLM — Maritaca AI (Sabiá-4)

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `MARITACA_API_KEY` | chat.maritaca.ai → API | Sim (M4) |
| `MARITACA_BASE_URL` | `https://chat.maritaca.ai/api` (padrão) | Não |

---

## RevenueCat

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `REVENUECAT_WEBHOOK_SECRET` | RevenueCat → Project → Integrations → Webhooks → Secret | Bloqueante para T22/T23 |

**Decisão pendente:** pricing model (T22). Não configurar RevenueCat até definir preço e produtos no App Store/Google Play.

---

## OneSignal (Push Notifications — T21)

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `ONESIGNAL_APP_ID` | OneSignal → App → Keys & IDs | Para T21 |
| `ONESIGNAL_API_KEY` | OneSignal → App → Keys & IDs → REST API Key | Para T21 |

---

## Sentry

| Variável | Onde obter | Obrigatório |
|----------|-----------|-------------|
| `SENTRY_DSN` | sentry.io → Project → Settings → Client Keys (DSN) | Recomendado produção |

---

## App

| Variável | Default | Descrição |
|----------|---------|-----------|
| `NODE_ENV` | `development` | `development` \| `production` |
| `PORT` | `3000` | Porta HTTP |
| `HOST` | `0.0.0.0` | Interface de escuta |
| `LOG_LEVEL` | `info` | `trace` \| `debug` \| `info` \| `warn` \| `error` |

---

## CORS

| Variável | Default | Descrição |
|----------|---------|-----------|
| `CORS_ORIGIN` | *(aceita todas)* | Origens permitidas em produção, separadas por vírgula. Ex: `https://app.lcf.com.br,https://lcf.com.br`. Se omitido em produção, aceita qualquer origem. |

---

## Rate Limits (Tutor IA)

| Variável | Default | Descrição |
|----------|---------|-----------|
| `TUTOR_RATE_FREE` | `20` | Msgs/dia plano Free |
| `TUTOR_RATE_PRO` | `200` | Msgs/dia plano PRO |

---

## Railway — Deploy

**URL de produção:** `https://lcf-production.up.railway.app`

1. Conectar repositório GitHub em Railway
2. Adicionar todas as vars acima em Railway → Variables
3. `npm run build` via Railway build command
4. Start command: `node dist/server.js`
5. Health check: `GET /health`

> **ATENÇÃO — `SUPABASE_JWT_PUBLIC_KEY` no Railway:** cole a chave PEM com `\n` literal
> (Railway não preserva quebras de linha reais). O `app.ts` normaliza automaticamente via `.replace(/\\n/g, '\n')`.

---

## Flutter App — Variáveis de build

Para rodar o app apontando para o backend correto:

```bash
# Emulador Android (aponta para Railway — recomendado)
flutter run --dart-define=API_BASE_URL=https://lcf-production.up.railway.app \
            --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJ...

# Emulador Android (backend local no host)
# localhost no emulador = o próprio emulador; use 10.0.2.2 para o host
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
            --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJ...
```

> **Causa dos erros "Erro ao carregar dados/metas/revisões":** o app usa `http://localhost:3000`
> como default. No Android Emulator, `localhost` é o próprio emulador — sem servidor lá,
> todas as chamadas falham por connection refused. Sempre passe `API_BASE_URL` explícito.
