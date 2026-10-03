---
domain: security
updated: 2026-06-24
owner: ato-security
---

# Memória de Segurança — ATO

> Postura de segurança por camada e histórico de auditorias. Produto jurídico + LGPD.

---

## Decisões de segurança vigentes

| Data | Item | Mitigação |
|------|------|-----------|
| 2026-06-07 | **JWT HS256 simétrico** | `@fastify/jwt` com `secret: SUPABASE_JWT_SECRET`. Supabase usa HS256, não RS256. Var ausente = undefined behavior. |
| 2026-06-07 | **Session ownership (IDOR)** | `tutor:session:owner:{sessionId}` vincula sessão ao userId (Redis TTL 4h). `validateOwnership` lança 403 antes de ler/injetar/deletar. Antes: qualquer JWT válido acessava sessão alheia por UUID. |
| 2026-06-07 | **DELETE /auth/me (LGPD)** | `supabaseAdmin.auth.admin.deleteUser` antes de `db.user.delete`. Sem isso, JWT do deletado ainda passava no `requireAuth` e auto-provisioning recriava a conta. |

## Camadas a auditar

1. **Auth** — JWT secret presente e correto; expiração; `requireAuth`/`requirePro` em toda rota sensível.
2. **Injeção** — Zod em todo input; `$queryRaw` sempre com params bindados (nunca interpolar SQL).
3. **Rate limit** — infra (Fastify por rota) + negócio (Redis por plano). Não confundir as duas camadas.
4. **IDOR/ownership** — todo recurso por UUID valida dono antes de operar.
5. **Mobile** — secrets nunca no binário; deep links validados; `--dart-define` para config.
6. **Infra** — CORS restrito em produção (`CORS_ORIGIN`); secrets só em Railway Variables, nunca no Git.
7. **LGPD** — consentimento explícito para IA; deleção real de conta; Umami sem cookies.

## Riscos abertos / vigiar

- `CORS_ORIGIN` em produção: se omitido, aceita qualquer origem. Definir antes do lançamento.
- Secrets rotation — sem rotação automática ainda.
- Rate limit Upstash: teto 10k cmds/dia pode ser superado por ataque de volume antes do limite de negócio.

## Validação

Auditoria por camada → achados no padrão FORJAR (via `/ato-forge`). CRÍTICO só para o que quebra segurança/credibilidade.

Ver também: [[infra.md]] · [[backend.md]] · [[launch.md]]
