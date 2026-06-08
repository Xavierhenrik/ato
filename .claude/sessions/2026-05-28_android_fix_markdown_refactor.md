# Sessão 2026-05-28

## O que foi feito

- **Android AGP 9+ fix**: `front/lcf_app/android/build.gradle.kts` — correção de compatibilidade para `isar_flutter_libs 3.1.0` com AGP 9.0.1 + Gradle 9.1.0. Dois problemas corrigidos:
  1. namespace ausente (obrigatório AGP 8+) — via `plugins.withId` + reflexão
  2. `checkDebugAarMetadata` false-positive (compileSdkVersion 30 < 34 exigido por AndroidX transitivo) — desabilitado via `tasks.whenTaskAdded` com guard `name == "isar_flutter_libs"`
- **Shared Markdown Widget**: `front/lcf_app/lib/shared/widgets/lcf_markdown_body.dart` — widget `LcfMarkdownBody` extraído das telas de Tutor IA e Manual. Usa tokens do design system LCF (AppColors, inter, tamanhos canônicos)
- **Refactor ChatBubble**: `chat_bubble.dart` — substituído `MarkdownBody` + `_markdownStyleSheet` estático (~60 linhas) por `LcfMarkdownBody(data: message.content)`
- **Refactor TopicSectionTile**: `topic_section_tile.dart` — substituído `Text(section.content)` por `LcfMarkdownBody(data: section.content)` — conteúdo do Manual agora renderiza markdown corretamente
- **Emulador Android**: habilitado teclado físico (`hw.keyboard=yes` em `config.ini` do AVD `LCF_Pixel6_API35`)
- **Usuário staging criado**: `development.lcf@gmail.com / Teste@123456` em staging Supabase (email confirmado)
- **JWT mismatch resolvido**: backend local iniciado com `npm run dev:staging` (.env.staging) apontando para staging Supabase — app usa `http://10.0.2.2:3000`

## Arquivos modificados

- `front/lcf_app/android/build.gradle.kts` — fix AGP 9+ / isar_flutter_libs 3.1.0
- `front/lcf_app/lib/shared/widgets/lcf_markdown_body.dart` — novo widget compartilhado de markdown
- `front/lcf_app/lib/features/tutor/presentation/widgets/chat_bubble.dart` — usa LcfMarkdownBody
- `front/lcf_app/lib/features/manual/presentation/widgets/topic_section_tile.dart` — usa LcfMarkdownBody
- `front/lcf_app/.metadata` — plataforma alterada para windows (subproduto de --platforms=windows anterior)

## Pendências / Próximos passos

- Investigar onboarding screen stuck: POST /onboarding/complete retorna erro ou DB staging não migrado
- Aplicar migration Sprint 4: `npx prisma migrate dev --name sprint4_simulado_indexes`
- `back/nixpacks.toml` — NÃO commitar (usuário rejeitou, deve ser deletado)
- `front/lcf_app/windows/` — NÃO commitar (plataforma incompleta)

## Decisões tomadas

- Desabilitar `checkAarMetadata` via `tasks.whenTaskAdded` é preferível a tentar forçar `compileSdkVersion` via reflexão (AGP 9 bloqueia mutação após finalização da extensão)
- `LcfMarkdownBody` centraliza estilos: qualquer mudança de design (fonte, cores, tamanho) é feita num único lugar
