# Sessão 2026-06-10 — Ajustes finos do tutor flutuante do Manual

## O que foi feito

4 ajustes de acabamento na 1ª versão do tutor flutuante de vidro:

1. **Fio dourado contorna o shape** — a hairline reta (`Positioned` top, height 1.5) era
   cortada pelo `ClipRRect` nos cantos. Substituída por `Border.all(accent 60 %, 1.5)` no
   `BoxDecoration` do container translúcido — o dourado percorre topo + quinas + laterais;
   a base fica fora da tela (gaveta ancorada embaixo). `Stack`/`Positioned` removidos.
2. **Input bar homogênea ao vidro** — `ChatInputBar` ganhou parâmetro
   `backgroundColor` (default `AppColors.background`, comportamento da tab `/tutor`
   inalterado). Na gaveta (`manual_tutor_orb.dart`), passa `Colors.transparent` —
   o fundo se funde ao vidro; campo de texto e botão de enviar continuam sólidos.
3. **Header de identidade removido** — `LcfTutorAppBar` modo padrão (`showBack == false`)
   perdeu o `Row` "Lex / Tutor IA / Direito inteligente para sua aprovação"; ficou
   minimalista, só `actions`. Modo contexto ("Resumo") intacto. Import `app_theme.dart`
   removido (ficou sem uso).
4. **`/tutor/context` com BottomNav** — builder da rota envolto em `ScaffoldWithNav`
   (rota continua fora do `ShellRoute`). `ProviderScope` com override de
   `tutorNotifierProvider` preservado (sessão de contexto isolada da tab) e
   `showBack`/`topicContext` preservados (voltar "Resumo" no topo). A aba Tutor fica
   destacada na nav (`matchedLocation` `/tutor/context` startsWith `/tutor`).

## Arquivos modificados

- `front/lcf_app/lib/shared/widgets/lcf_glass_sheet.dart` — hairline → `Border.all` no shape; doc atualizada
- `front/lcf_app/lib/features/tutor/presentation/widgets/chat_input_bar.dart` — parâmetro `backgroundColor`
- `front/lcf_app/lib/features/manual/presentation/widgets/manual_tutor_orb.dart` — `backgroundColor: Colors.transparent` na `ChatInputBar` da gaveta
- `front/lcf_app/lib/shared/widgets/lcf_app_bar.dart` — `LcfTutorAppBar` modo padrão minimalista; import sem uso removido
- `front/lcf_app/lib/core/router/app_router.dart` — `/tutor/context` envolto em `ScaffoldWithNav`

> Nota: o prompt citava `manual_tutor_sheet.dart` como local da input bar da gaveta,
> mas o uso real está em `manual_tutor_orb.dart` (gaveta de vidro). O
> `manual_tutor_sheet.dart` (bottom sheet legado de ações rápidas) não usa `ChatInputBar`
> e não foi alterado.

## Critérios de aceite cumpridos

- [x] Fio dourado contorna topo + quinas + laterais da gaveta
- [x] Barra de input se funde ao vidro; campo e botão continuam sólidos
- [x] Header de identidade removido no modo padrão; "Resumo" intacto no modo contexto
- [x] Chat aberto pelo Manual mostra BottomNav e mantém voltar "Resumo"; sessão isolada
- [x] `flutter analyze` zero issues (8.3s)

## Pendências / Próximos passos

- Verificação visual no emulador (borda dourada, fusão da input bar, BottomNav no contexto)
- Commit das alterações (5 arquivos + PROJECT_STATE + este log)

## Decisões tomadas

- `Border.all` uniforme com `BorderRadius.vertical(top)` — Flutter pinta a borda seguindo
  o radius; a aresta inferior fica fora da viewport, então não aparece linha na base.
- `ScaffoldWithNav` aplicado manualmente no builder (não movido para dentro do
  `ShellRoute`) para manter o `ProviderScope` isolado e a transição `_fadeSlidePage`.
