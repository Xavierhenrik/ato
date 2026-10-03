#!/bin/bash
# Stop hook — ATO Project
# Porta 1: log de sessão criado hoje
# Porta 2: working tree limpa (alterou → aprovoucommitou)

TODAY=$(date +%Y-%m-%d)
SESSIONS_DIR="$(cd "$(dirname "$0")/.." && pwd)/sessions"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

PENDING=""

# ── Porta 1: log de sessão ───────────────────────────────────────────────────
if ! find "$SESSIONS_DIR" -name "${TODAY}*.md" 2>/dev/null | grep -q .; then
  PENDING="${PENDING}LOG"
fi

# ── Porta 2: working tree limpa ──────────────────────────────────────────────
if [ -d "$REPO_ROOT/.git" ]; then
  DIRTY=$(cd "$REPO_ROOT" && git status --porcelain 2>/dev/null)
  if [ -n "$DIRTY" ]; then
    PENDING="${PENDING}COMMIT"
  fi
fi

# Ambas as portas OK — encerra silenciosamente
[ -z "$PENDING" ] && exit 0

# ── Saída de bloqueio ────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  PENDÊNCIAS OBRIGATÓRIAS antes de finalizar a sessão     ║"
echo "╚══════════════════════════════════════════════════════════╝"

if [[ "$PENDING" == *"LOG"* ]]; then
  cat << EOF

PORTA 1 — Log de sessão ausente
Crie .claude/sessions/${TODAY}_<slug>.md com:
  ## O que foi feito / Arquivos modificados / Criterios de aceite / Decisoes

Atualize .claude/PROJECT_STATE.md (updated: $TODAY, status dos modulos).

EOF
fi

if [[ "$PENDING" == *"COMMIT"* ]]; then
  cat << EOF
PORTA 2 — Working tree nao esta limpa
Arquivos pendentes:
$(cd "$REPO_ROOT" && git status --short 2>/dev/null)

Regra: alterou -> aprovou -> commitou.
Use a skill ato-versioning para agrupar e commitar antes de encerrar.

EOF
fi

exit 0
