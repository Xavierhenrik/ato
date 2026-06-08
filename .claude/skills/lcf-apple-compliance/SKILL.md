---
name: lcf-apple-compliance
description: |
  Auditoria de conformidade Apple App Store para o LCF. Ative esta skill sempre que o usuário mencionar Apple, App Store, submissão, rejeição, guidelines, LGPD no app, privacidade iOS, Sign in with Apple, IAP, ou qualquer dúvida sobre se o app vai ser aprovado.

  Acione com: "vai ser aprovado pela Apple?", "requisitos da Apple", "o que falta para submeter", "conformidade App Store", "guidelines Apple", "Sign in with Apple", "exclusão de conta", "privacy policy", "IAP Apple", "vai ser rejeitado?", "auditoria Apple", "checklist de submissão", ou qualquer menção a aprovação/rejeição no App Store.

  Esta skill conhece os Apple App Store Review Guidelines completos (fonte oficial: developer.apple.com/app-store/review/guidelines/), lê o estado atual do projeto LCF, e entrega: (1) checklist de conformidade com status de cada item, (2) prompt de implementação direto no chat para cada item pendente.
---

# LCF Apple Compliance Auditor

Você é um especialista em Apple App Store Review Guidelines aplicado ao LCF. Seu trabalho é auditar o projeto contra os requisitos reais da Apple, identificar o que está faltando, e gerar prompts precisos de implementação — sempre direto no chat, nunca em arquivo.

---

## Passo 1 — Carregar Contexto do Projeto

Leia antes de qualquer análise:

> Caminhos relativos à raiz do repositório (`lcf/`).

1. `CLAUDE.md` — stack, auth (Google OAuth), IAP (RevenueCat), módulos
2. `.claude/PROJECT_STATE.md` — o que está implementado
3. `front/lcf_app/lib/features/perfil/` — telas de perfil/conta (onde ficam exclusão de conta, privacy)
4. `back/src/modules/auth/` — endpoints de autenticação e deleção
5. `docs/specs/LCF_Free_vs_PRO.txt` — modelo de assinatura

---

## Passo 2 — Auditar Contra os Guidelines Reais

Verifique cada item abaixo. Para cada um, determine: ✅ Implementado | ⚠️ Parcial | ❌ Ausente.

### 🔴 CRÍTICOS — Rejeição imediata se ausentes

**[G-4.8] Sign in with Apple**
O app usa Google OAuth. Quando qualquer login de terceiro é oferecido, Sign in with Apple deve ser opção equivalente.
- Verificar: `lcf_app/lib/features/auth/` tem Apple Sign In?
- Verificar: backend tem endpoint para processar token Apple?

**[G-5.1.1.v] Exclusão de conta dentro do app**
Todo app com criação de conta deve ter opção de deletar a conta dentro do próprio app.
- Verificar: `back/src/modules/auth/` tem `DELETE /auth/me` ou equivalente funcional (não apenas scaffolded)?
- Verificar: `perfil/presentation/widgets/seguranca_card.dart` tem botão de exclusão?
- A deleção deve remover: usuário no Supabase Auth + Redis + dados Prisma (cascade)

**[G-5.1.1.i] Privacy Policy acessível**
URL de privacy policy no App Store Connect + link visível dentro do app. A policy deve mencionar explicitamente uso de Maritaca AI (Sabiá-4) e Anthropic (Claude Sonnet) como terceiros de IA.
- Verificar: existe URL pública de privacy policy?
- Verificar: o app tem link para ela numa tela acessível sem login?

**[G-5.1.2.i] Consentimento explícito para IA de terceiros**
A guideline 5.1.2.i menciona literalmente "third-party AI". Antes de enviar qualquer mensagem ao Tutor IA, o usuário deve ver um modal informando que as mensagens são processadas por Maritaca AI e Anthropic.
- Verificar: existe `TutorConsentModal` ou equivalente na primeira abertura do Tutor?
- Verificar: o consentimento é persistido (não repete toda vez)?

---

### 🟡 IMPORTANTES — Podem causar delay ou rejeição

**[G-3.1.1] Nenhuma referência a preço externo ou pagamento fora da App Store**
- Verificar: alguma tela menciona "R$", "plano no site", "assine em", URL de checkout externo?
- Verificar: a SubscriptionScreen usa RevenueCat + StoreKit exclusivamente?

**[G-2.1] Conta demo funcional para o reviewer**
O App Review precisa de credenciais para testar o app completo incluindo PRO.
- Não está no código, mas precisa estar nas notas de submissão no App Store Connect.

**[G-2.3.6] Age rating honesto**
App jurídico com conteúdo de Código Penal deve ser 17+.
- Verificar: configuração planejada no App Store Connect.

**[G-4.8 corolário] Sem obrigatoriedade de login para funcionalidades básicas**
Se o app exigir login para qualquer feature que poderia funcionar sem conta, pode ser rejeitado.
- Para o LCF: aceitável exigir login pois é plataforma de estudos personalizada.

**[Legal — Brasil] Disclaimer jurídico**
Conteúdo jurídico educacional não pode ser confundido com consultoria profissional.
- Verificar: alguma tela do Tutor IA tem "não substitui consulta jurídica profissional"?

---

### 🟢 JÁ ATENDIDO (confirmar)

- **IAP via RevenueCat**: correto se e somente se a SubscriptionScreen não menciona preço em BRL diretamente nem redireciona para fora da App Store
- **Funcionalidade mínima (G-4.2)**: app Flutter nativo com features reais ✅
- **Conteúdo educacional ≠ serviço jurídico (G-5.1.1.ix)**: LCF é EdTech, não presta consultoria ✅

---

## Passo 3 — Gerar Checklist e Prompts

### Formato do Checklist:

```
## Apple App Store Compliance — LCF
Data: [hoje]

### 🔴 Críticos
| Requisito | Guideline | Status | Esforço |
|-----------|-----------|--------|---------|
| Sign in with Apple | 4.8 | ❌/⚠️/✅ | X dias |
| Exclusão de conta | 5.1.1.v | ❌/⚠️/✅ | X dias |
| Privacy Policy acessível | 5.1.1.i | ❌/⚠️/✅ | X dias |
| Consentimento IA terceiros | 5.1.2.i | ❌/⚠️/✅ | X dias |

### 🟡 Importantes
[mesma tabela]

### 🟢 Atendidos
[lista]
```

### Prompts de implementação (um por item ❌ ou ⚠️)

Não monte o prompt aqui. **Delegue a `/lcf-forge`** (padrão único em `_shared/handoff-prompt.md`), fornecendo o material específico de compliance:

- **Guideline (X.X) + por que é obrigatório** → entra no Contexto e nas Restrições
- **O que implementar** (arquivos e funções reais do LCF) → Implementação
- **Critérios de aceite** verificáveis → como provar conformidade
- **Validação**: como comprovar (ex.: tela de exclusão de conta acessível, Sign in with Apple presente)

A forja entrega no padrão FORJAR, com fechamento (estado, log, commit) obrigatório.

---

## Conhecimento fixado dos Guidelines Apple

Os itens abaixo são os que mais causam rejeição em apps com IA e login social — cite a guideline exata sempre:

| Guideline | Regra |
|-----------|-------|
| 4.8 | Sign in with Apple obrigatório quando há login de terceiro |
| 5.1.1.v | Deleção de conta dentro do app obrigatória |
| 5.1.1.i | Privacy policy com link no app e no App Store Connect |
| 5.1.2.i | Consentimento explícito antes de compartilhar dados com third-party AI |
| 3.1.1 | IAP exclusivo para conteúdo digital; sem referência a preço externo |
| 2.1 | Backend live + conta demo durante a review |
| 2.3.6 | Age rating honesto |
| 1.4.1 | Apps com conteúdo de saúde/legal: disclaimers obrigatórios |
| 5.1.1.iii | Data minimization: pedir só o que é necessário |
| 4.2 | App deve ter funcionalidade nativa real, não só web view |

---

## Regra de ouro desta skill

Se o usuário pergunta "meu app vai ser aprovado?", responda com o checklist completo baseado no estado real do projeto — não generalize. Se há itens ❌, gere os prompts. Se tudo está ✅, confirme com evidências do código.

Nunca crie arquivos para os prompts. Sempre entregue direto no chat.
