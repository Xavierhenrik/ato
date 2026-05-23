import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/cadastro_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_senha_screen.dart';
import '../../features/onboarding/presentation/screens/diagnostico_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../shared/widgets/scaffold_with_nav.dart';

part 'app_router.g.dart';

// Routes que não exigem autenticação
const _publicRoutes = {'/login', '/cadastro', '/esqueci-senha'};

// ChangeNotifier que dispara refresh no GoRouter ao mudar estado de auth
class _AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthChangeNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final notifier = _AuthChangeNotifier();
  ref.onDispose(notifier.dispose);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;
      final loc = state.matchedLocation;

      if (!isLoggedIn && !_publicRoutes.contains(loc)) return '/login';
      if (isLoggedIn && _publicRoutes.contains(loc)) return '/dashboard';

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

      // ── Shell — telas com BottomNav ────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/tutor',
            builder: (context, state) => const _PlaceholderScreen(label: 'Tutor IA'),
          ),
          GoRoute(
            path: '/anotacoes',
            builder: (context, state) => const _PlaceholderScreen(label: 'Anotações'),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const _PlaceholderScreen(label: 'Dashboard'),
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, state) => const _PlaceholderScreen(label: 'Perfil'),
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
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
