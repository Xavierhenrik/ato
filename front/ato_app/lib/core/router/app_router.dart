import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../features/tutor/data/models/tutor_models.dart';
import '../../features/tutor/presentation/screens/tutor_history_detail_screen.dart';
import '../../features/tutor/presentation/screens/tutor_history_screen.dart';
import '../../features/tutor/presentation/screens/tutor_screen.dart';
import '../../features/tutor/providers/tutor_provider.dart';
import '../../shared/widgets/scaffold_with_nav.dart';

part 'app_router.g.dart';

// Rotas públicas (acessíveis sem sessão; bloqueiam usuários logados)
const _publicRoutes = {'/login', '/cadastro', '/esqueci-senha'};
// Rotas acessíveis com sessão mas antes do onboarding ser concluído
const _preOnboardingRoutes = {'/onboarding', '/diagnostico'};

class _RouterNotifier extends ChangeNotifier with WidgetsBindingObserver {
  late final StreamSubscription<AuthState> _sub;

  _RouterNotifier() {
    WidgetsBinding.instance.addObserver(this);
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  void refresh() => notifyListeners();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub.cancel();
    super.dispose();
  }
}

// Transição de bottom sheet modal — a rota é transparente (opaque: false),
// então a tela anterior continua pintada atrás; um scrim escurece em fade e
// o conteúdo sobe de baixo. É o que permite ao AtoGlassSheet frostar o que
// está atrás: sem a tela anterior visível, o blur não tem o que desfocar.
CustomTransitionPage<void> _slideUpPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: curved,
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        ],
      );
    },
  );
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
      if (isLoggedIn && !onboardingDone && !_preOnboardingRoutes.contains(loc)) {
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
        pageBuilder: (context, state) =>
            _slideUpPage(state, const CadastroScreen()),
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

      // ── Tutor com contexto do Manual (push, com BottomNav) ───────────
      // ProviderScope isolado: garante que a sessão de contexto não interfere
      // com a sessão do Tutor tab (tutorNotifierProvider global).
      // ScaffoldWithNav manual: a rota fica fora do ShellRoute (sessão
      // isolada), mas o chat aberto pelo Manual deve mostrar a BottomNav.
      GoRoute(
        path: '/tutor/context',
        pageBuilder: (context, state) {
          final args = state.extra as TutorScreenArgs?;
          return _fadeSlidePage(
            state,
            ScaffoldWithNav(
              child: ProviderScope(
                overrides: [
                  tutorNotifierProvider.overrideWith(TutorNotifier.new),
                ],
                child: TutorScreen(
                  initialMessage: args?.initialMessage,
                  topicContext: args?.topicContext,
                ),
              ),
            ),
          );
        },
      ),

      // ── Histórico do Tutor IA ─────────────────────────────────────────
      GoRoute(
        path: '/tutor/history',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const TutorHistoryScreen()),
      ),
      GoRoute(
        path: '/tutor/history/:id',
        pageBuilder: (context, state) => _fadeSlidePage(
          state,
          TutorHistoryDetailScreen(
            sessionId: state.pathParameters['id']!,
          ),
        ),
      ),

      // ── Push routes fullscreen (sem nav bar) ──────────────────────────
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
      // Sub-rotas profundas do Manual — fullscreen, fora do ShellRoute
      GoRoute(
        path: '/manual/topic/:id',
        pageBuilder: (context, state) => _fadeSlidePage(
          state,
          ManualDetailScreen(topicId: state.pathParameters['id']!),
        ),
      ),
      // Sub-rotas profundas de Simulados — fullscreen, fora do ShellRoute
      GoRoute(
        path: '/simulados/:id',
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

      // ── Shell — telas com nav bar flutuante ───────────────────────────
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
          GoRoute(
            path: '/manual',
            builder: (context, state) => ManualListScreen(
              initialSubject: state.uri.queryParameters['subject'],
            ),
          ),
          GoRoute(
            path: '/simulados',
            builder: (context, state) => const SimuladoConfigScreen(),
          ),
        ],
      ),
    ],
  );
}
