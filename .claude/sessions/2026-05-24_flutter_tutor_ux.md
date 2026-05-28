# Sessão 2026-05-24 — Flutter · Tutor IA UX

## O que foi feito

### Problema 1 — Fake Streaming (texto progressivo)
- `TutorChatState` recebeu campo `streamingContent: String?` e `clearStreamingContent` no `copyWith`
- `TutorNotifier` recebeu `Timer? _streamingTimer` + limpeza via `ref.onDispose`
- Novo método privado `_startStreaming(response)`: revela o texto da resposta char a char via `Timer.periodic`
  - 1º caractere exibido imediatamente (sem flash de bubble vazio)
  - Intervalo: 12 ms para < 300 chars · 8 ms para ≥ 300 chars
  - Ao finalizar: cancela timer, adiciona mensagem definitiva em `messages`, limpa `streamingContent`
- `endSession()` cancela o timer pendente antes de resetar o estado
- `tutor_screen.dart` — `_TutorScreenState.build()`:
  - `ref.listen` faz scroll automático a cada tick do timer
  - `hasMessages` inclui `streamingContent != null`
  - `ChatInputBar.enabled` desabilitado também durante streaming
- `_ChatListView` recebeu parâmetro `streamingContent: String?`; exibe `ChatBubble` temporário no slot extra enquanto streaming ativo; chips ocultos durante streaming

### Problema 2 — Chips horizontal scroll
- `ChipsRow` convertido de `StatelessWidget` para `StatefulWidget`
- `Row + SingleChildScrollView` substituído por `ListView.builder(scrollDirection: Axis.horizontal)` — handling de gestos correto quando aninhado em ListView vertical
- `ScrollController` com listener `_updateFade` controla visibilidade do gradiente
- Gradiente fade (AppColors.background transparent → opaco) sobreposto via `Stack + Positioned` nos últimos 24 px
- Gradiente some automaticamente quando scroll chega ao fim
- Cada chip limitado a `BoxConstraints(maxWidth: 180)` com `TextOverflow.ellipsis`
- Altura do container: `SizedBox(height: 36)` compatível com o chip de design (padding vertical 6 + texto ~18 px)

## Arquivos modificados
- `lib/features/tutor/providers/tutor_provider.dart` — TutorChatState + TutorNotifier
- `lib/features/tutor/presentation/screens/tutor_screen.dart` — build + _ChatListView
- `lib/features/tutor/presentation/widgets/chips_row.dart` — StatefulWidget completo

## Resultado do analyze
```
Analyzing lcf_app...
No issues found! (ran in 4.4s)
```

## Pendências / Próximos passos
- Testar no dispositivo real: velocidade do streaming parece boa em simulador, pode precisar ajuste fino em device físico lento
- Cursor piscante ("|") não implementado — foi avaliado como complexidade adicional desnecessária para o MVP

## Decisões tomadas
- Iniciamos com 1 char (não 0) para evitar flash de bubble vazio
- Input desabilitado durante streaming para evitar sobreposição de mensagens
- `clearStreamingContent: bool` em `copyWith` em vez de sentinel `Object()` — mais legível no codebase
