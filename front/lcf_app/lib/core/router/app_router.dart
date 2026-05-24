import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/anotacoes/data/models/anotacao_models.dart';
import '../../features/anotacoes/presentation/screens/anotacao_editor_screen.dart';
import '../../features/anotacoes/presentation/screens/anotacoes_screen.dart';
import '../../features/auth/presentation/screens/cadastro_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_senha_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/manual/presentation/screens/manual_detail_screen.dart';
import '../../features/manual/presentation/screens/manual_list_screen.dart';
import '../../features/onboarding/presentation/screens/diagnostico_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/perfil/presentation/screens/perfil_screen.dart';
import '../../features/perfil/presentation/screens/subscription_screen.dart';
import '../../features/simulados/data/models/simulado_models.dart';
import '../../features/simulados/presentation/screens/simulado_attempt_screen.dart';
import '../../features/simulados/presentation/screens/simulado_config_screen.dart';
import '../../features/simulados/presentation/screens/simulado_result_screen.dart';
import '../../features/tutor/presentation/screens/tutor_screen.dart';
import '../../shared/widgets/scaffold_with_nav.dart';

part 'app_router.g.dart';

// Rotas públicas (acessíveis sem sessão; bloqueiam usuários logados)
const _publicRoutes = {'/login', '/cadastro', '/esqueci-senha'};
// Rotas acessíveis com sessão mas antes do onboarding ser concluído
const _preOnboardingRoutes = {'/onboarding', '/diagnostico'};

class _RouterNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _RouterNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  void refresh() => notifyListeners();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final notifier = _RouterNotifier();
  ref.onDispose(notifier.dispose);

  // Refresh router quando o estado de onboarding muda
  ref.listen<bool>(onboardingDoneProvider, (_, __) => notifier.refresh());

  // Ao trocar de usuário (login/logout), re-sincroniza o estado de onboarding
  ref.listen<AsyncValue<User?>>(authUserStreamProvider, (_, curr) {
    final user = curr.valueOrNull;
    if (user == null) {
      ref.read(onboardingDoneProvider.notifier).reset();
    } else {
      final done = user.userMetadata?['onboarding_done'] as bool? ?? false;
      if (done) ref.read(onboardingDoneProvider.notifier).markDone();
    }
    notifier.refresh();
  });

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;
      final loc = state.matchedLocation;
      final onboardingDone = ref.read(onboardingDoneProvider);

      // 1. Não autenticado + rota protegida → login
      if (!isLoggedIn && !_publicRoutes.contains(loc)) return '/login';

      // 2. Autenticado + rota pública → dashboard
      if (isLoggedIn && _publicRoutes.contains(loc)) return '/dashboard';

      // 3. Autenticado + onboarding pendente + fora das telas de onboarding → onboarding
      if (isLoggedIn &&
          !onboardingDone &&
          !_preOnboardingRoutes.contains(loc)) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      // ── Auth (sem BottomNav) ───────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const CadastroScreen(),
      ),
      GoRoute(
        path: '/esqueci-senha',
        builder: (context, state) => const ResetSenhaScreen(),
      ),

      // ── Onboarding (sem BottomNav) ─────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/diagnostico',
        builder: (context, state) => const DiagnosticoScreen(),
      ),

      // ── Push routes (sem ShellRoute) ──────────────────────────────────
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/anotacoes/nova',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AnotacaoEditorScreen()),
      ),
      GoRoute(
        path: '/anotacoes/:id/editar',
        pageBuilder: (context, state) {
          final anotacao = state.extra as Anotacao?;
          return _fadeSlidePage(
            state,
            AnotacaoEditorScreen(anotacao: anotacao),
          );
        },
      ),
      GoRoute(
        path: '/manual',
        builder: (context, state) => const ManualListScreen(),
        routes: [
          GoRoute(
            path: 'topic/:id',
            pageBuilder: (context, state) => _fadeSlidePage(
              state,
              ManualDetailScreen(topicId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/simulados',
        builder: (context, state) => const SimuladoConfigScreen(),
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final attempt = state.extra as SimuladoAttempt?;
              final screen = attempt == null
                  ? const SimuladoConfigScreen()
                  : SimuladoAttemptScreen(attempt: attempt);
              return _fadeSlidePage(state, screen);
            },
            routes: [
              GoRoute(
                path: 'results',
                pageBuilder: (context, state) => _fadeSlidePage(
                  state,
                  SimuladoResultScreen(
                    simuladoId: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Shell — telas com BottomNav ────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/tutor',
            builder: (context, state) => const TutorScreen(),
          ),
          GoRoute(
            path: '/anotacoes',
            builder: (context, state) => const AnotacoesScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, state) => const PerfilScreen(),
          ),
        ],
      ),
    ],
  );
}
