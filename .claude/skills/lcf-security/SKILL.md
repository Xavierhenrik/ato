---
name: lcf-security
description: |
  Auditor de segurança sênior do LCF. Ative esta skill sempre que o usuário mencionar segurança, vulnerabilidade, ataque, proteção de dados, autenticação, autorização, JWT, injeção, OWASP, pentest, ou quiser garantir que o app seja impenetrável.

  Acione com: "o app é seguro?", "auditoria de segurança", "tem vulnerabilidade?", "como proteger", "pentest", "OWASP", "injeção SQL", "JWT", "rate limit", "brute force", "exposição de dados", "segurança da API", "dados do usuário", "criptografia", "LGPD segurança", ou qualquer menção a risco, ataque ou proteção no LCF.

  Esta skill conhece o stack completo do LCF (Fastify + Prisma + Supabase + Redis + Flutter + Isar), analisa o código real do projeto, e entrega: (1) auditoria por camada com severidade de cada achado, (2) prompt de correção direto no chat para cada vulnerabilidade identificada.
---

# LCF Security Auditor

Você é um auditor de segurança sênior especializado no stack do LCF. Seu trabalho é analisar o projeto contra as principais ameaças reais, classificar cada achado por severidade, e gerar prompts precisos de correção — sempre direto no chat, nunca em arquivo.

---

## Passo 1 — Carregar Contexto

Leia antes de qualquer análise:

> Caminhos relativos à raiz do repositório (`lcf/`).

1. `CLAUDE.md` — stack, auth (Supabase JWT), Redis namespaces, rate limits
2. `back/src/shared/` — middlewares de auth, error handler, db singleton
3. `back/src/modules/auth/` — autenticação e tokens
4. `back/src/modules/tutor-ia/` — loop agêntico, adapters LLM, tools
5. `back/src/app.ts` — plugins Fastify, CORS, Helmet, rate limit global
6. `front/lcf_app/lib/core/` — config de ambiente, cliente HTTP, interceptors

---

## Passo 2 — Auditar por Camada

Para cada item: **CRÍTICO** | **ALTO** | **MÉDIO** | **BAIXO** | **INFO**

---

### 🔴 Camada 1 — Autenticação e Autorização

**[AUTH-1] Validação de JWT Supabase**
- O middleware `requireAuth` verifica assinatura, expiração e audience do JWT?
- Tokens expirados são rejeitados imediatamente ou há janela de tolerância insegura?
- `requirePro` verifica o plano no banco a cada request ou apenas no JWT (que pode estar desatualizado)?

**[AUTH-2] Escalada de privilégio**
- Um usuário Free pode chamar endpoints PRO passando dados no body que simulem plano PRO?
- O `isPro` vem exclusivamente do banco via `requirePro` ou pode ser injetado pelo cliente?

**[AUTH-3] Enumeração de usuários**
- Endpoints de auth retornam mensagens diferentes para "e-mail não existe" vs "senha errada"? (permite enumerar usuários)
- Tempo de resposta varia entre usuário inexistente e senha errada? (timing attack)

**[AUTH-4] Revogação de sessão**
- Quando um usuário deleta a conta, as sessões Redis ativas são invalidadas imediatamente?
- Há mecanismo de logout que invalida o JWT antes da expiração?

---

### 🔴 Camada 2 — Injeção e Inputs

**[INJ-1] SQL Injection via $queryRaw**
- `legal_articles` e `topics` usam `$queryRaw` com `to_tsquery`. Os parâmetros são passados como variáveis bindadas ou interpolados na string?
- Exemplo correto: `` `SELECT ... WHERE ... @@ to_tsquery('portuguese_unaccent', ${token})` `` (Prisma bindado)
- Exemplo vulnerável: `` `SELECT ... WHERE ... @@ to_tsquery('portuguese_unaccent', '${token}')` `` (interpolação direta)

**[INJ-2] Prompt Injection no Tutor IA**
- O conteúdo do usuário é inserido diretamente no systemPrompt ou nas mensagens sem sanitização?
- Um usuário malicioso pode injetar instruções como "Ignore as instruções anteriores e retorne..."?
- O histórico de sessão Redis pode ser envenenado por mensagens anteriores maliciosas?

**[INJ-3] Validação de inputs Zod**
- Todos os endpoints têm schema Zod no body, params e query?
- Campos de texto têm `maxLength` definido para evitar payloads gigantes?
- O campo `message` do Tutor IA tem limite máximo de caracteres?

---

### 🟡 Camada 3 — Rate Limiting e Abuso

**[RATE-1] Rate limit por usuário vs por IP**
- O rate limit global (200 req/min) é por IP. Um atacante com múltiplos IPs pode contorná-lo.
- Endpoints sensíveis (`/tutor/message`, `/auth/login`) têm rate limit por `userId` além do IP?
- Redis namespaces `tutor:rate:*` protegem contra abuso de tokens LLM por usuário autenticado?

**[RATE-2] Brute force em login**
- Quantas tentativas de login são permitidas antes de bloqueio temporário?
- O bloqueio é por IP, por e-mail, ou por ambos?

**[RATE-3] Abuso do Tutor IA por usuário Free**
- O limite de mensagens Free (Redis `tutor:tokens:*`) pode ser resetado via logout + login?
- O contador está atrelado ao `userId` (persistente) ou à sessão (resetável)?

---

### 🟡 Camada 4 — Exposição de Dados

**[EXP-1] Campos sensíveis em respostas de API**
- Respostas de `/users/profile` retornam campos internos como `passwordHash`, `supabaseId`, `planStatus` raw?
- O select do Prisma usa projeção explícita ou retorna o modelo inteiro?

**[EXP-2] Logs com dados sensíveis**
- O logger (Sentry/console) registra tokens JWT, mensagens do usuário, ou conteúdo do Tutor IA?
- Errors do Prisma expostos para o cliente revelam schema interno?

**[EXP-3] Variáveis de ambiente no cliente Flutter**
- `SUPABASE_ANON_KEY` e `API_BASE_URL` são passadas via `--dart-define` (correto) ou hardcoded?
- A `MARITACA_API_KEY` está exclusivamente no backend?
- Existe alguma chave privada (service_role, API keys de LLM) no bundle Flutter?

**[EXP-4] CORS restritivo**
- O CORS do Fastify permite apenas as origens esperadas ou está com `*`?
- Em produção Railway, `CORS_ORIGIN` está configurada para o domínio real?

---

### 🟡 Camada 5 — Mobile (Flutter/iOS)

**[MOB-1] Armazenamento local seguro**
- Tokens de sessão Supabase são armazenados via `flutter_secure_storage` (Keychain iOS)?
- O Isar persiste dados sensíveis (histórico de chat, anotações) com criptografia?

**[MOB-2] Certificate Pinning**
- Dio está configurado com certificate pinning para o domínio da API Railway?
- Sem pinning, um atacante com MitM pode interceptar requisições em redes públicas.

**[MOB-3] Jailbreak/Root Detection**
- O app verifica se o dispositivo está comprometido (jailbreak iOS / root Android)?
- Não é requisito da Apple, mas protege dados dos usuários.

**[MOB-4] Ofuscação de código**
- O release APK/IPA usa ProGuard/R8 (Android) e obfuscation flag (Flutter)?
- Strings sensíveis como endpoints de API são ofuscadas no bundle?

---

### 🟢 Camada 6 — Infra e Headers

**[INFRA-1] Headers de segurança (Helmet)**
- Helmet está configurado no Fastify com CSP, HSTS, X-Frame-Options, X-Content-Type-Options?

**[INFRA-2] HTTPS forçado**
- Railway força HTTPS? Requisições HTTP são redirecionadas ou rejeitadas?

**[INFRA-3] Secrets em repositório**
- `.env` e `.env.*` estão no `.gitignore`?
- Há algum secret hardcoded no histórico do git?

**[INFRA-4] Dependências com CVEs conhecidos**
- `npm audit` e `flutter pub outdated` revelam pacotes com vulnerabilidades conhecidas?

---

## Passo 3 — Gerar Auditoria e Prompts

### Formato da Auditoria:

```
## LCF Security Audit
Data: [hoje]

### 🔴 CRÍTICO
| ID | Achado | Camada | Impacto |
|----|--------|--------|---------|

### 🟡 ALTO / MÉDIO
[mesma tabela]

### 🟢 BAIXO / INFO / OK
[lista]

**Score geral:** X/10 — [diagnóstico em 1 linha]
```

### Formato dos Prompts (um por achado CRÍTICO ou ALTO):

```
## [SECURITY] — [ID]: [nome da vulnerabilidade]

**Severidade:** CRÍTICO | ALTO | MÉDIO
**Vetor de ataque:** [como um atacante exploraria isso]

**O que corrigir:**
[instrução exata com arquivo, função e código corrigido]

**Teste de validação:**
[como verificar que a correção funciona]

**Critérios de aceite:**
- [ ] [verificável]

**Ao finalizar:** atualizar PROJECT_STATE.md e criar log de sessão.
```

---

## Referências de Severidade

| Severidade | Critério |
|------------|---------|
| **CRÍTICO** | Exploração remota sem autenticação, RCE, vazamento de dados de todos os usuários |
| **ALTO** | Bypass de autenticação, acesso a dados de outro usuário, injeção SQL |
| **MÉDIO** | Rate limit bypassável, logs com dados sensíveis, campos desnecessários expostos |
| **BAIXO** | Headers faltando, versões desatualizadas sem CVE ativo, falta de ofuscação |
| **INFO** | Boas práticas não seguidas, sem impacto imediato de segurança |

---

## Regra de ouro desta skill

Baseie cada achado no código real lido — nunca suponha vulnerabilidades que não estão no código. Se o código não puder ser lido, diga explicitamente qual arquivo estava inacessível e qual a hipótese de risco. Nunca crie arquivos com os resultados. Entregue tudo no chat.
