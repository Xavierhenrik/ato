import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'api_client.g.dart';

const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

// Chave extra que marca requisições que já passaram pelo retry de 401.
// Evita loop infinito caso o backend rejeite o token por motivo diferente de expiração.
const _kRetried = 'dio_auth_retried';

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
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (DioException err, handler) async {
        // 401 na primeira tentativa: tenta fazer refresh do token Supabase e
        // repete a requisição uma única vez. Se o refresh falhar ou o segundo
        // 401 vier, deixa o erro propagar (o router redirect para /login via
        // onAuthStateChange do Supabase).
        final alreadyRetried = err.requestOptions.extra[_kRetried] == true;
        if (err.response?.statusCode == 401 && !alreadyRetried) {
          try {
            await Supabase.instance.client.auth.refreshSession();
            final newSession = Supabase.instance.client.auth.currentSession;
            if (newSession == null) {
              return handler.next(err);
            }
            final opts = err.requestOptions
              ..extra[_kRetried] = true
              ..headers['Authorization'] = 'Bearer ${newSession.accessToken}';
            final response = await instance.fetch(opts);
            return handler.resolve(response);
          } catch (_) {
            // Refresh falhou — propaga o erro original para o provider mostrar
            // estado de erro; o onAuthStateChange do Supabase cuidará do logout.
          }
        }
        handler.next(err);
      },
    ),
  );

  return instance;
}
