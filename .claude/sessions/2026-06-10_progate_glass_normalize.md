# Sessão 2026-06-10 — Normalização do ProGateSheet para o padrão de vidro

## O que foi feito

O `ProGateSheet` (paywall "Recurso PRÓ", visível no screenshot da tela Simulado) ainda
usava o padrão antigo de bottom sheet: superfície sólida `AppColors.backgroundSheet`
(`#3D1200`) com `Border.all` dourado nas quatro arestas. Foi normalizado para o padrão
`LcfGlassSheet` fixado nas sessões anteriores de hoje (vidro translúcido 30 % + blur 18
+ fio dourado só no topo via `_GoldTrimPainter` + respiro lateral 8px).

1. **`LcfGlassSheet` com altura intrínseca** — o componente exigia `height` (conteúdo
   entrava via `Positioned.fill`, que precisa de altura limitada). Agora, quando
   `height == null`, o `child` entra não-posicionado no `Stack` e a folha dimensiona
   pela altura intrínseca do conteúdo. A gaveta do Manual (que passa `height`) mantém
   o comportamento original intacto.
2. **`ProGateSheet` no vidro** — `Container` sólido + borda integral substituídos por
   `Padding(horizontal: AppSpacing.sm)` → `LcfGlassSheet` → conteúdo. Handle, ícone,
   copy, lista de features e CTAs inalterados. Padding inferior agora soma
   `MediaQuery.padding.bottom` (safe area da barra de gestos) além de `viewInsets`.

Afeta os 5 pontos de uso sem mudança de chamada: tutor_screen (limite diário),
simulado_config_screen (Free 30+, modo PRO, mais questões) e simulado_result_screen.

## Arquivos modificados

- `front/lcf_app/lib/shared/widgets/lcf_glass_sheet.dart` — suporte a altura intrínseca (`height == null` → child não-posicionado no Stack)
- `front/lcf_app/lib/shared/widgets/pro_gate_sheet.dart` — superfície sólida + Border.all → LcfGlassSheet com respiro lateral 8px e safe area inferior

## Critérios de aceite cumpridos

- [x] ProGateSheet renderiza no padrão de vidro (superfície 30 %, fio dourado topo, cantos 30 px, respiro lateral 8px)
- [x] Gaveta do Manual (`LcfGlassSheet` com `height`) sem mudança de comportamento
- [x] Nenhum call site precisou mudar (`ProGateSheet.show` intacto)
- [x] `flutter analyze` zero issues (16.1s)

## Pendências / Próximos passos

- Verificação visual no emulador (abrir gate PRO em Simulado → "OAB Fase 2" como Free)
- Commit das alterações
- Auditoria futura: `simulado_config_screen` e `simulado_result_screen` apareceram no
  grep de `showModalBottomSheet` apenas por usarem `ProGateSheet` — nenhum outro sheet
  fora do padrão restante no app

## Decisões tomadas

- `AppColors.backgroundSheet` e `AppRadius.sheet`/`borderAccent` continuam no tema
  (podem ter outros usos); só o ProGateSheet deixou de consumi-los
- Padrão fixado: **todo bottom sheet novo do app usa `LcfGlassSheet`**
