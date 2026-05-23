import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/cadastro_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_senha_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/diagnostico_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/manual/presentation/screens/manual_detail_screen.dart';
import '../../features/manual/presentation/screens/manual_list_screen.dart';
import '../../features/tutor/presentation/screens/tutor_screen.dart';
import '../../shared/widgets/scaffold_with_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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

      // ── Push routes (sem ShellRoute) ─────────────────────────────────────
      GoRoute(
        path: '/manual',
        builder: (context, state) => const ManualListScreen(),
        routes: [
          GoRoute(
            path: 'topic/:id',
            builder: (context, state) => ManualDetailScreen(
              topicId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/simulados',
        builder: (context, state) =>
            const _PlaceholderScreen(label: 'Simulados'),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                const _PlaceholderScreen(label: 'Simulado em andamento'),
            routes: [
              GoRoute(
                path: 'results',
                builder: (context, state) =>
                    const _PlaceholderScreen(label: 'Resultado'),
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
            builder: (context, state) =>
                const _PlaceholderScreen(label: 'Anotações'),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, state) =>
                const _PlaceholderScreen(label: 'Perfil'),
          ),
        ],
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    // Scaffold próprio para rotas fora do ShellRoute (manual, simulados, etc.)
    // Removido quando a tela real for implementada em F4/F5.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(label, style: AppTextStyles.h3)),
      body: Center(child: Text(label, style: AppTextStyles.h2)),
    );
  }
}
