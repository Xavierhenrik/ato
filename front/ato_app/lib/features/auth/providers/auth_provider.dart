import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

// Web Client ID do Google Cloud Console (Credentials → OAuth 2.0 → Web application).
// Necessário para que o SDK nativo retorne o idToken compatível com o Supabase.
// Injete via --dart-define=GOOGLE_WEB_CLIENT_ID=... ou defina aqui para dev.
const _kGoogleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '',
);

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
    state = await AsyncValue.guard(() async {
      final googleSignIn = GoogleSignIn(
        serverClientId: _kGoogleWebClientId.isNotEmpty ? _kGoogleWebClientId : null,
      );

      await googleSignIn.signOut();

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } on PlatformException catch (e) {
        // code 10 = DEVELOPER_ERROR (SHA-1 ou package name não registrado no Google Cloud Console)
        // code 12501 = usuário cancelou o picker
        throw Exception('Google Sign-In falhou [code: ${e.code}]. ${e.message ?? ''}');
      }

      if (googleUser == null) {
        throw Exception('Google Sign-In cancelado.');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'Não foi possível obter o token do Google. '
          'Verifique se GOOGLE_WEB_CLIENT_ID está configurado corretamente.',
        );
      }

      final AuthResponse response;
      try {
        response = await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: googleAuth.accessToken,
        );
      } on AuthException catch (e) {
        throw Exception('Falha na autenticação: ${e.message}');
      }

      await ref.read(authRepositoryProvider).verify();
      return response.user;
    });
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
