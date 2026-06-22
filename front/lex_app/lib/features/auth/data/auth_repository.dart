import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  const AuthRepository(this._dio);
  final Dio _dio;

  /// Sincroniza sessão Supabase com o backend LCF.
  /// O auto-provisioning ocorre no middleware requireAuth do backend.
  Future<Response<void>> verify() {
    return _dio.post<void>('/auth/verify');
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(dioProvider));
}
