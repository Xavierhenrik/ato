import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/auth_repository.dart';

part 'auth_provider.g.dart';

String _generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
}

String _sha256(String input) {
  final bytes = utf8.encode(input);
  return sha256.convert(bytes).toString();
}

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
  // Sinaliza que estamos aguardando o callback de redirect do Google OAuth.
  // Usado pelo listener de onAuthStateChange para chamar verify() exatamente
  // uma vez, sem interferir nos fluxos de email/Apple que já chamam verify().
  bool _pendingGoogleVerify = false;

  @override
  AsyncValue<User?> build() {
    final sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn && _pendingGoogleVerify) {
        _pendingGoogleVerify = false;
        _verifyAndSetState(event.session?.user);
      }
    });
    ref.onDispose(sub.cancel);
    return AsyncData(Supabase.instance.client.auth.currentUser);
  }

  Future<void> _verifyAndSetState(User? user) async {
    try {
      if (user != null) await ref.read(authRepositoryProvider).verify();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
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
    _pendingGoogleVerify = true;
    try {
      final res = await Supabase.instance.client.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: 'com.lcf.app://auth-callback',
      );
      final uri = Uri.parse(res.url);

      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched) {
        throw Exception(
          'Não foi possível abrir o navegador. '
          'Verifique se há um browser instalado no dispositivo.',
        );
      }
    } catch (e, st) {
      _pendingGoogleVerify = false;
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      if (response.user != null) {
        await ref.read(authRepositoryProvider).verify();
      }
      return response.user;
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: rawNonce,
      );

      await ref.read(authRepositoryProvider).verify();
      return response.user;
    });
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutor_ai_consent_accepted');
    await Supabase.instance.client.auth.signOut();
    state = const AsyncData(null);
  }

  Future<void> resetPassword(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }
}
