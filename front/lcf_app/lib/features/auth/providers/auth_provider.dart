import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

part 'auth_provider.g.dart';

// ── Onboarding done state — lido de metadata Supabase, persiste entre restarts ─

@Riverpod(keepAlive: true)
class OnboardingDone extends _$OnboardingDone {
  @override
  bool build() {
    return Supabase.instance.client.auth.currentUser
            ?.userMetadata?['onboarding_done'] as bool? ??
        false;
  }

  void markDone() => state = true;
  void reset() => state = false;
}

// ── Usuário atual (reativo) ───────────────────────────────────────────────────

@riverpod
Stream<User?> authUserStream(AuthUserStreamRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
}

// ── Ações de autenticação ─────────────────────────────────────────────────────

/// Estado: null = idle | data(null) = signed-out | data(User) = signed-in
/// Mutations atualizam `state` para refletir loading/error na UI.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    return AsyncData(Supabase.instance.client.auth.currentUser);
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await ref.read(authRepositoryProvider).verify();
      return response.user;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.lcf.app://auth-callback',
      );
      // Auth state listener no GoRouter atualiza o estado automaticamente
      state = AsyncData(Supabase.instance.client.auth.currentUser);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Retorna true se o usuário é novo (201), false se já existia (200).
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    bool isNew = false;
    state = await AsyncValue.guard(() async {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      if (response.user != null) {
        final result = await ref.read(authRepositoryProvider).verify();
        isNew = result.statusCode == 201;
      }
      return response.user;
    });
    return isNew;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AsyncData(null);
  }

  Future<void> resetPassword(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }
}
