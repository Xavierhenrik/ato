# Sessão 2026-06-10 — Tutor Flutuante de Vidro no Manual

## O que foi feito

Redesenhado o ponto de entrada do Tutor IA no Manual: substituído o ícone ⚡ por seção
por um orbe flutuante único que abre uma gaveta de vidro animada sobre o conteúdo.

## Arquivos modificados

- `shared/widgets/lcf_glass_sheet.dart` — **CRIADO** — componente reutilizável do padrão
  de vidro LCF (translúcido 30 %, fio dourado no topo, sem BackdropFilter, cantos 30 px).
  Constantes `_kSurfaceOpacity` e `_kTopBorderOpacity` isoladas no arquivo.

- `features/manual/presentation/widgets/manual_tutor_orb.dart` — **CRIADO** — overlay
  completo com animação: orbe 56 px ↔ âncora no topo da gaveta, scrim 12 % preta,
  gaveta `LcfGlassSheet` 400 dp, 3 pills com stagger (Interval 0.40/0.52/0.64),
  `ChatInputBar` reusado, navegação `/tutor/context` com `TutorTopicContext` do tópico
  inteiro.

- `features/manual/presentation/screens/manual_detail_screen.dart` — body no modo `data`
  agora usa Stack com `ManualTutorOrb` em `Positioned.fill`; `onTutorTap` removido das
  chamadas de `TopicSectionTile`; import `manual_tutor_sheet` substituído por
  `manual_tutor_orb`.

- `features/manual/presentation/widgets/topic_section_tile.dart` — parâmetro `onTutorTap`
  e ícone `Icons.bolt_rounded` removidos.

- `shared/widgets/lcf_app_bar.dart` — `LcfTutorAppBar` em modo `showBack: true` agora
  exibe header minimalista (`Icons.arrow_back_ios_new` + texto "Resumo" em `accent`),
  sem avatar/identidade. Modo padrão (`showBack: false`) inalterado.

- `front/docs/DESIGN_TOKENS.md` — seção de vidro atualizada com referência à
  implementação canônica em `LcfGlassSheet`.

## Critérios de aceite cumpridos

- [x] `ManualDetailScreen` tem orbe-robô flutuante; ⚡ por seção removido
- [x] Tocar no orbe abre a gaveta; orbe anima e ancora no topo da gaveta
- [x] Tocar fora ou no orbe novamente cancela com animação reversa
- [x] Fundo do resumo nítido (sem blur); gaveta translúcida com fio dourado
- [x] Pills e input sólidos/opacos; barra inferior é o `ChatInputBar` reusado
- [x] Pill/envio navega para `/tutor/context` com `topicContext` do tópico inteiro
- [x] Tutor em modo contexto: apenas seta + "Resumo" sutil; avatar do topo removido
- [x] `shared/widgets/lcf_glass_sheet.dart` criado e usado pela gaveta
- [x] `flutter analyze` — zero issues

## Decisões tomadas

- Orbe animado via `AnimatedController` + `lerpDouble` dentro de um Stack em
  `Positioned.fill` (não `showGeneralDialog`/`OverlayEntry`) para manter o orbe
  sempre no mesmo contexto de widget e simplificar o ciclo de vida.
- `onNavigate` é `void Function(String)` não-nullable (todos os pilots passam mensagem;
  `ChatInputBar.onSend` é `ValueChanged<String>`). String vazia mapeada para `null`
  em `TutorScreenArgs.initialMessage`.
- `withValues(alpha:)` em vez de `withOpacity` para conformidade com Flutter 3.x.
- Stagger das pills via `CurvedAnimation` com `Interval` no mesmo `AnimationController`
  principal — sem controller adicional.

## Hotfix pós-teste no emulador (mesma sessão)

- **Bug:** `LcfGlassSheet` usava `Border` com lados não-uniformes + `borderRadius` —
  inválido no Flutter (exception de paint). Sintomas: fio dourado invisível, pills e
  `ChatInputBar` não renderizavam.
- **Fix:** componente reescrito — `ClipRRect` > `BackdropFilter` (blur σ18, efeito
  fosco, decisão do produto sobrepondo o "sem blur" original) > Container translúcido
  0.30 > Stack com hairline dourada 1.5 px no topo.
- `_SheetContent` agora usa `Spacer` para ancorar o `ChatInputBar` no fundo da gaveta
  (o conteúdo passou a preencher a altura via `Positioned.fill`).
- `flutter analyze` — zero issues após o fix.

## Pendências / Próximos passos

- `manual_tutor_sheet.dart` ficou como arquivo morto — remover em próxima sessão de code
  health (sem urgência; não referenciado por nenhum import).
- Testar em dispositivo físico iOS para confirmar posicionamento do orbe acima do home
  indicator (depende de `mq.padding.bottom` correto).
