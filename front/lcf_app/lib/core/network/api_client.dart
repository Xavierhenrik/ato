import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'api_client.g.dart';

const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

@riverpod
Dio dio(DioRef ref) {
  final instance = Dio(
    BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  instance.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Supabase SDK keeps the session fresh automatically — just attach the
        // current token.  No manual refresh needed here; doing so would cause
        // an infinite retry loop when the backend rejects the JWT for any
        // reason other than expiry (e.g. wrong JWT secret in dev/staging).
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
    ),
  );

  return instance;
}
