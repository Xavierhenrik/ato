# Flutter LCF — Padrões Detalhados

## 1. AsyncNotifier completo (com Isar + API)

```dart
// features/manual/providers/topics_provider.dart
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/manual_repository.dart';
import '../data/models/cached_topic_model.dart';
part 'topics_provider.g.dart';

@riverpod
class TopicsNotifier extends _$TopicsNotifier {
  @override
  Future<List<CachedTopic>> build() async {
    final isar = ref.watch(isarProvider);
    final cached = isar.cachedTopics.where().findAll();

    // Servir cache imediatamente se fresco (< 24h)
    if (cached.isNotEmpty) {
      final freshEnough = DateTime.now()
          .difference(cached.first.cachedAt)
          .inHours < 24;
      if (freshEnough) return cached;
    }

    // Buscar da API e atualizar cache
    return _fetchAndCache();
  }

  Future<List<CachedTopic>> _fetchAndCache() async {
    final repo = ref.read(manualRepositoryProvider);
    final isar = ref.read(isarProvider);

    final remoteTopics = await repo.getTopics();
    final models = remoteTopics.map((t) => CachedTopic()
      ..remoteId = t.id
      ..title = t.title
      ..content = t.content
      ..cachedAt = DateTime.now()
      ..isRead = false).toList();

    await isar.writeTxn(() async {
      await isar.cachedTopics.putAll(models);
    });

    return isar.cachedTopics.where().findAll();
  }

  Future<void> markAsRead(String remoteId) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      final topic = isar.cachedTopics
          .filter()
          .remoteIdEqualTo(remoteId)
          .findFirstSync();
      if (topic != null) {
        topic.isRead = true;
        await isar.cachedTopics.put(topic);
      }
    });
    ref.invalidateSelf(); // re-render com dado atualizado
  }
}
```

---

## 2. GoRouter com Guard de Auth

```dart
// core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(supabaseAuthStateProvider);

  return GoRouter(
    initialLocation: '/tutor',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) return '/auth/login';
      if (isAuthenticated && isAuthRoute) return '/tutor';
      return null; // sem redirect
    },
    routes: [
      // Auth routes (sem bottom nav)
      GoRoute(
        path: '/auth/login',
        builder: (c, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/onboarding',
        builder: (c, s) => const OnboardingScreen(),
      ),

      // App routes (com bottom nav via ShellRoute)
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/tutor',
            builder: (c, s) => const TutorScreen(),
            routes: [
              GoRoute(
                path: 'session/:id',
                builder: (c, s) => TutorSessionScreen(
                  sessionId: s.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(path: '/anotacoes', builder: (c, s) => const AnotacoesScreen()),
          GoRoute(
            path: '/home',
            builder: (c, s) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'simulado/:id/result',
                builder: (c, s) => SimuladoResultScreen(
                  args: s.extra as SimuladoResultArgs,
                ),
              ),
            ],
          ),
          GoRoute(path: '/perfil', builder: (c, s) => const PerfilScreen()),
        ],
      ),
    ],
  );
}
```

---

## 3. Shimmer Loading (padrão LCF)

```dart
// shared/widgets/lex_loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class LcfLoadingShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LcfLoadingShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundCard,
      highlightColor: AppColors.border,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

---

## 4. Error State Padrão LCF

```dart
// shared/widgets/lex_error_state.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LcfErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const LcfErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Pro Gate Bottom Sheet

```dart
// shared/widgets/lcf_pro_gate_sheet.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LcfProGateSheet {
  static void show(BuildContext context, {required String feature}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProGateContent(feature: feature),
    );
  }
}

class _ProGateContent extends StatelessWidget {
  final String feature;
  const _ProGateContent({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.workspace_premium, color: AppColors.accent, size: 48),
          const SizedBox(height: 16),
          Text('Recurso PRO', style: AppTextStyles.headline2),
          const SizedBox(height: 8),
          Text(
            'Assine o LCF PRO por R\$29,90/mês e tenha acesso ilimitado.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: navegar para tela de assinatura
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Assinar PRO'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Isar Provider (singleton)

```dart
// core/providers/isar_provider.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/manual/data/models/cached_topic_model.dart';
// import outros models aqui
part 'isar_provider.g.dart';

@Riverpod(keepAlive: true) // singleton — nunca destruir
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      CachedTopicSchema,
      // adicionar outros schemas aqui
    ],
    directory: dir.path,
  );
}
```

---

## 7. Dio Provider com Interceptor JWT

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://localhost:3000'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      // Token expirado — tentar refresh
      if (error.response?.statusCode == 401) {
        await Supabase.instance.client.auth.refreshSession();
        final newSession = Supabase.instance.client.auth.currentSession;
        if (newSession != null) {
          error.requestOptions.headers['Authorization'] =
              'Bearer ${newSession.accessToken}';
          final retry = await dio.fetch(error.requestOptions);
          return handler.resolve(retry);
        }
      }
      handler.next(error);
    },
  ));

  return dio;
}
```
