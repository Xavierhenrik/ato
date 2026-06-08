---
name: lcf-versioning
description: |
  Padrão de versionamento do LCF. Ative esta skill sempre que for commitar, fazer push, fechar uma sessão de trabalho, ou padronizar o histórico do git.

  Acione com: "commita", "commit", "versiona isso", "faz o push", "git", "fecha a sessão", "salva no repo", "padroniza os commits", "prepara o commit", ou ao final de qualquer trabalho que alterou arquivos.

  Garante a regra inegociável do LCF: **alterou → aprovou → commitou**. Nada de trabalho fica fora do controle de versão ao fim de uma sessão. Padroniza mensagens (Conventional Commits), agrupa por intenção, e bloqueia segredos antes de qualquer stage. Funciona como PORTÃO 3 do loop de trabalho, em par com o Stop hook (session-end.sh).
---

# LCF Versioning

Você padroniza e executa o versionamento do LCF. Histórico limpo é histórico auditável — e auditoria é requisito do projeto. Cada commit conta uma história única, legível, e nunca carrega um segredo.

**Regra de ouro: alterou → aprovou → commitou.** Toda sessão termina com a árvore limpa (`working tree clean`) ou com o pendente explicitamente registrado. Trabalho não commitado é trabalho em risco e não-portável.

---

## Passo 1 — Inventariar antes de tocar

```
git status
git diff --stat
```
Entenda o que mudou e por quê. Se há mudanças de mais de uma intenção misturadas, elas viram **commits separados** (Passo 4).

---

## Passo 2 — PORTÃO de segredos (sempre, antes de qualquer `add`)

Nenhum segredo entra no índice. Verifique:

```
git status --porcelain | grep -iE "\.env($|\.)|settings.local|\.secret|\.pem|id_rsa"
```
- Só `.env.example` é permitido (template). Qualquer `.env`, `.env.staging`, `settings.local.json`, chave ou token → **pare**, confirme que está no `.gitignore`, e `git restore --staged` se já tiver sido adicionado.
- Em dúvida sobre um arquivo novo, não commite — pergunte.

---

## Passo 3 — Revisar o diff

Para mudanças não triviais, leia o diff real (`git diff <arquivo>`), não só os nomes. Você é o "aprovou" da regra. Não commite o que não revisou.

> Cuidado com blobs grandes entrando pela primeira vez (ex.: app inteiro, pasta nova). Eles ainda assim devem ser **um commit próprio**, nunca misturados com mudanças de lógica.

---

## Passo 4 — Agrupar por intenção e commitar

Um commit = uma intenção. Não misture refactor com feature, nem back com front sem relação.

### Formato (Conventional Commits)

```
tipo(escopo): assunto no imperativo, ≤ 72 caracteres

[corpo opcional: o porquê, não o quê]
```

**Tipos:** `feat` · `fix` · `refactor` · `chore` · `docs` · `test` · `perf` · `ci`

**Escopos do LCF** (use o mais específico):
`back`, `front`/`flutter`, `auth`, `tutor-ia`, `simulados`, `manual`, `dashboard`, `onboarding`, `anotacoes`, `subscriptions`, `users`, `data`/`etl`, `ai`, `infra`, `ai-env` (skills/hooks/state do `.claude/`), `docs`

**Regras de mensagem:**
- Idioma: **português**, consistente. Assunto no imperativo ("adiciona", "corrige", "remove").
- **Sem BOM / sem caractere invisível** no início (o histórico atual tem `﻿feat` corrompido — nunca repita).
- Sem ponto final no assunto. Sem emoji.
- O corpo explica *por que*, quando não for óbvio.

### Exemplos bons
```
feat(simulados): adiciona limite diário de 15 questões para Free
fix(auth): rejeita JWT expirado sem janela de tolerância
chore(ai-env): versiona skills, hooks e settings compartilhados
refactor(flutter): extrai LcfMarkdownBody para widget compartilhado
```

### Exemplo de sessão com mudanças mistas
```
git add .claude/ CLAUDE.md .gitignore && git commit -m "chore(ai-env): versiona ambiente de IA + portabilidade"
git add back/src/modules/tutor-ia/ && git commit -m "fix(tutor-ia): robustez do parser de resposta"
git add front/ && git commit -m "chore(flutter): adiciona app ao repositório"
```

---

## Passo 5 — Push e verificação

```
git push origin main
git status        # deve dizer: working tree clean
git log --oneline -5
```
Cole o `git log --oneline -5` como evidência. Árvore não-limpa = sessão não terminada.

---

## Passo 6 — Fechamento de sessão (alinha com o Stop hook)

Antes de encerrar:
- [ ] `working tree clean` (ou pendência registrada em PROJECT_STATE.md)
- [ ] PROJECT_STATE.md atualizado
- [ ] log em `.claude/sessions/YYYY-MM-DD_<slug>.md` criado

> O hook `session-end.sh` já força o log de sessão. Esta skill fecha o outro lado: o commit. Juntos, garantem **alterou → aprovou → commitou**.

---

## Quando gerar prompt em vez de executar

Se você está no Cowork (sem credenciais de push) e o usuário quer delegar, **não** tente commitar — emita um prompt no padrão FORJAR para o Claude Code rodar na máquina dele, contendo: inventário, portão de segredos, agrupamento sugerido, comandos exatos e a evidência esperada.

---

## Regra de ouro

Histórico é documentação permanente e auditável. Um commit que mistura intenções, ou que vaza um segredo, é um débito que nunca sai do repo. Reviseo, agrupe, padronize — sempre. Caminhos relativos à raiz do repositório (`lcf/`).
