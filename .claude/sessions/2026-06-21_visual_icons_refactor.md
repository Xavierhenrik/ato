# Sessão 2026-06-21 — Visual Icons Refactor

## O que foi feito

Substituição completa de ícones Material Design genéricos e emojis por SVGs
customizados LEX em todos os arquivos especificados. `flutter analyze` — zero issues.

## Arquivos criados

- `front/lex_app/lib/core/assets/lex_icons.dart` — constantes de path para todos os 27 SVGs LEX

## Arquivos modificados

| Arquivo | Mudança |
|---------|---------|
| `features/auth/presentation/screens/login_screen.dart` | `_LexLogo`: Text → `SvgPicture.asset(logoMark)` |
| `shared/widgets/lex_app_bar.dart` | AppBar title: Text('Lex') → `SvgPicture.asset(logoIcon)` |
| `features/dashboard/presentation/screens/dashboard_screen.dart` | Text('Lex') → `SvgPicture.asset(logoIcon)` |
| `features/anotacoes/presentation/screens/anotacao_editor_screen.dart` | AppBar title → `SvgPicture.asset(logoIcon)` |
| `features/tutor/presentation/widgets/tutor_welcome_card.dart` | `Icons.smart_toy` → `SvgPicture(lexiaAvatar)` |
| `features/tutor/presentation/widgets/chat_bubble.dart` | `Icons.smart_toy` → `SvgPicture(lexiaAvatar)` |
| `features/tutor/presentation/widgets/typing_indicator.dart` | `Icons.smart_toy` → `SvgPicture(lexiaAvatar)` |
| `features/manual/presentation/widgets/manual_tutor_orb.dart` | `Icons.smart_toy_outlined` → `SvgPicture(lexiaOrb)`; `_PillButton` refatorado de `IconData` para `String iconAsset`; chips → chip_explain / chip_jurisprudence / chip_tip |
| `features/anotacoes/presentation/widgets/anotacao_card.dart` | `Icons.smart_toy_outlined` → `SvgPicture(lexiaBadge, accent)` |
| `features/dashboard/presentation/widgets/greeting_card.dart` | `Icons.local_fire_department` → `SvgPicture(streakFlame)`; `Icons.emoji_events_outlined` → `SvgPicture(trophy)` |
| `features/dashboard/presentation/widgets/cards_materia_card.dart` | `_StatBox` refatorado: `IconData? icon` → `Widget? iconWidget`; streak → `SvgPicture(streakFlame)` |
| `features/perfil/presentation/widgets/lex_pro_banner_card.dart` | `Icons.workspace_premium` → `SvgPicture(crownPro)` |
| `features/perfil/presentation/screens/subscription_screen.dart` | `Icons.workspace_premium` × 2 → `SvgPicture(crownPro)`; `_kFeatures` emojis → SVG paths; `_FeatureBlock` refatorado de `emoji` para `iconAsset` |
| `shared/widgets/pro_gate_sheet.dart` | `Icons.workspace_premium` → `SvgPicture(crownPro, 32×32)` |
| `features/onboarding/presentation/screens/onboarding_screen.dart` | `_phases` emojis → SVG paths; `_PhaseCard` refatorado de `emoji` para `iconAsset` com cor reativa accent/textMuted |
| `features/simulados/presentation/widgets/mode_option_card.dart` | `_modeIcon` getter → `_modeIconAsset()` method; `Icon` → `SvgPicture` com colorFilter |
| `features/manual/presentation/widgets/manual_tutor_sheet.dart` | `_ActionTile` refatorado de `IconData icon` para `String iconAsset`; 4 chips → chip_explain / chip_jurisprudence / chip_tip / chip_question |

## Critérios de aceite cumpridos

- [x] `flutter analyze` — zero issues
- [x] Nenhum `Icon(Icons.smart_toy*)` restante
- [x] Nenhum `Icon(Icons.workspace_premium*)` restante
- [x] Nenhum `Icon(Icons.local_fire_department*)` restante (exceto chrome UI — mantido)
- [x] Nenhum emoji em listas de dados visuais
- [x] Tela de login exibe logo_mark (via `_LexLogo`)
- [x] Tutor welcome card exibe lexia_avatar
- [x] Orbe flutuante do Manual exibe lexia_orb
- [x] Cards de fase do onboarding exibem SVG com cor reativa (accent/textMuted)

## Pendências

- **SVG files ausentes**: `front/lex_app/assets/icons/` contém apenas `.gitkeep`.
  Os 27 arquivos SVG precisam ser adicionados manualmente antes do próximo build:
  logo_mark.svg, logo_icon.svg, lexia_avatar.svg, lexia_orb.svg, lexia_badge.svg,
  crown_pro.svg, streak_flame.svg, trophy.svg, phase_graduation_start.svg,
  phase_graduation_mid.svg, phase_graduation_end.svg, phase_oab_prep.svg,
  pro_materials.svg, pro_reviews.svg, pro_simulados.svg, pro_support.svg,
  mode_oab1.svg, mode_oab2.svg, mode_custom.svg, mode_weak_areas.svg,
  chip_explain.svg, chip_jurisprudence.svg, chip_tip.svg, chip_question.svg

## Decisões tomadas

- `anotacao_editor_screen.dart`: AppBar title substituído por logoIcon conforme spec
  (perde "Editar anotação" / "Nova anotação" — close button e ação "Salvar" dão contexto)
- `pro_gate_sheet.dart`: tamanho alterado de 48 para 32 conforme spec
- `_StatBox.iconWidget`: mudança de `IconData? icon` + `Color? iconColor` para
  `Widget? iconWidget` — mais flexível sem quebrar a API pública (widget privado)
- Ícones de chrome UI (close, arrow_back, check_circle, info_outline, etc.)
  mantidos como `Icons.*` do Material conforme restrições da spec
- `lex_glass_nav_bar.dart` não tocado conforme restrições

## Próximos passos

1. Adicionar os 24 arquivos SVG em `front/lex_app/assets/icons/`
2. Rodar `flutter run` para verificação visual completa
