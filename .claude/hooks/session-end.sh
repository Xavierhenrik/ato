#!/bin/bash
# Stop hook — LCF Project
# Verifica se um log de sessão foi criado hoje.
# Se não, retorna instrução forçando o Claude a escrever antes de finalizar.

TODAY=$(date +%Y-%m-%d)
SESSIONS_DIR="$(cd "$(dirname "$0")/.." && pwd)/sessions"

# Verifica se existe arquivo de sessão com a data de hoje
if find "$SESSIONS_DIR" -name "${TODAY}*.md" 2>/dev/null | grep -q .; then
  # Log já existe — saída silenciosa, Claude pode finalizar
  exit 0
fi

# Sem log hoje — força Claude a continuar e escrever o resumo
cat << EOF
PENDÊNCIA OBRIGATÓRIA: Nenhum log de sessão foi registrado para hoje ($TODAY).

Antes de finalizar, execute as duas ações abaixo:

1. Crie o arquivo .claude/sessions/${TODAY}_$(date +%H).md com o seguinte conteúdo:

# Sessão $TODAY $(date +%H:%M)

## O que foi feito
-

## Arquivos modificados
- 

## Critérios de aceite cumpridos
- [ ] 

## Pendências / Próximos passos
-

## Decisões tomadas
-

2. Atualize .claude/PROJECT_STATE.md:
   - Marque [x] nos critérios de aceite cumpridos nesta sessão
   - Atualize o status dos módulos modificados (🔄 Esqueleto → ✅ Completo se aplicável)
   - Adicione uma linha na tabela "Log de Sessões" com data e resumo
   - Atualize o campo "updated:" no frontmatter para $TODAY

Após criar os dois arquivos, você pode finalizar.
EOF

exit 0
