# Sessão 2026-05-28 23:xx — Verificação no Emulador Android

## O que foi feito

### 1. Fix `api_client.dart` — Dio 401 loop infinito removido
- Removida lógica de retry manual no interceptor Dio. O interceptor agora apenas anexa o token atual e passa a requisição adiante.
- Motivo: staging JWT rejeitado pela produção causava ciclo `401 → refresh → retry → 401 → …` infinito. O Supabase Flutter SDK já gerencia refresh de token automaticamente via listener de sessão.
- Sem retry manual, o app recebe 401 → redireciona para login (comportamento correto).

### 2. Fix profile APK build — `isar_flutter_libs` + AGP 9+
- O `build.gradle.kts` desabilita **todos** os tasks `*AarMetadata*` para `isar_flutter_libs` (incluindo `writeProfileAarMetadata`).
- Isso quebrava o build de profile: nenhum arquivo `aar-metadata.properties` era criado para a variante `profile`.
- Solução: pré-criadas as pastas e arquivos de metadados para a variante `profile` manualmente:
  - `build/isar_flutter_libs/intermediates/aar_metadata/profile/writeProfileAarMetadata/aar-metadata.properties` (copiado do debug)
  - `build/isar_flutter_libs/intermediates/aar_metadata_check/profile/checkProfileAarMetadata/` (dir vazio)
- Resultado: `✓ Built build\app\outputs\flutter-apk\app-profile.apk (77.3MB)` — build bem-sucedido.

### 3. Backend reiniciado na porta 3001
- Porta 3000 ocupada pelo processo `judicializacao-web` (Next.js, PID 20512).
- Backend iniciado com: `npx dotenv-cli -e .env.staging -- npx tsx src\server.ts` (porta 3001).
- Conectividade do emulador confirmada: `nc 10.0.2.2 3001` → HTTP 200.
- Cold start do banco: ~4–5s na primeira request (Supabase idle pool reaquecendo).

### 4. Verificação visual no emulador (LCF_Pixel6_API35 — emulator-5554)

#### Dashboard
- ✅ "Bom dia, development.lcf!" renderizado corretamente após warmup.
- ✅ `DashboardData.plan = "free"`, streak, progresso diário — todos os campos presentes.
- Obs: backend demora ~4–5s no cold start; durante esse período o provider entra em estado de erro — pull-to-refresh ou botão "Tentar novamente" resolve sem reiniciar o app.

#### LcfMarkdownBody — Manual (seção Artigos Centrais)
- ✅ Navegado: Dashboard → Manual → primeiro tópico (Código Civil).
- ✅ `**Art. 1.072, § 6.º**` e `**Art. 1.072, § 5.º**` renderizados em dourado `Color(0xFFE8B84B)` (`AppColors.accentLight`).
- ✅ Texto normal em branco; bold em ouro. Diferença de cor claramente visível no zoom.

#### LcfMarkdownBody — Tutor IA (chat bubbles)
- ✅ Confirmado na sessão anterior: termos legais em bold renderizados em `AppColors.accentLight`.
- Widget compartilhado funciona nos dois contextos.

#### Dio 401 fix — verificação de código
- ✅ `api_client.dart` lido e confirmado: zero lógica de retry. Sem `onError` handler, sem `DioException.requestOptions.data` reutilizado.
- ✅ Build e execução normais — nenhum loop de log visível.

#### AGP 9+ fix — build.gradle.kts
- ✅ Debug APK: `✓ Built build\app\outputs\flutter-apk\app-debug.apk`
- ✅ Profile APK (após fix de metadados): `✓ Built build\app\outputs\flutter-apk\app-profile.apk (77.3MB)`

## Arquivos modificados

- `front/lcf_app/lib/core/network/api_client.dart` — Dio interceptor sem retry manual (401 loop removido)
- `front/lcf_app/android/build/isar_flutter_libs/intermediates/aar_metadata/profile/writeProfileAarMetadata/aar-metadata.properties` — pré-criado (não commitado — pasta `build/` no .gitignore)
- `front/lcf_app/android/build/isar_flutter_libs/intermediates/aar_metadata_check/profile/checkProfileAarMetadata/` — dir vazio pré-criado (não commitado)

## Critérios de aceite cumpridos

- [x] App Flutter roda no emulador `LCF_Pixel6_API35` sem crash
- [x] Dashboard exibe dados reais do usuário de staging (`development.lcf@gmail.com`)
- [x] `LcfMarkdownBody` renderiza bold em dourado `0xFFE8B84B` no Manual
- [x] `LcfMarkdownBody` renderiza bold em dourado no Tutor IA
- [x] `api_client.dart` não tem retry manual de 401 — código confirmado
- [x] Profile APK build bem-sucedido com AGP 9+ e isar_flutter_libs 3.1.0

## Pendências / Próximos passos

- Dashboard cold start delay (4–5s): avaliar skeleton loader ou timeout de loading state mais explícito para UX
- Backend porta 3001 em staging local: documentar `API_BASE_URL=http://10.0.2.2:3001` para evitar confusão futura
- `api_client.dart` mudança ainda não commitada junto com as demais (pendente commit Flutter)
- Arquivos de metadados pré-criados em `build/` (gitignore) precisam ser recriados após `flutter clean`; considerar script de setup ou nota no README

## Decisões tomadas

- Pré-criar arquivos de metadados estáticos em `build/` é a abordagem correta para `isar_flutter_libs 3.1.0` + AGP 9+: a lib é pré-compilada (sem código Kotlin/Java), então os metadados nunca mudam entre builds.
- Retry manual no Dio interceptor é desnecessário e perigoso quando se usa Supabase Flutter SDK — o SDK notifica mudanças de sessão via `onAuthStateChange`; o app deve escutar esse stream e redirecionar para login quando necessário.
