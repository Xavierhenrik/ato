import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lex_error_state.dart';

/// Trata erros de [AsyncValue] de forma padronizada.
///
/// - 401 → redireciona para /login via [addPostFrameCallback] (evita setState durante build).
/// - Outros → exibe [LexErrorState] com botão de retry.
Widget handleAsyncError(
  Object error,
  BuildContext context, {
  required String message,
  required VoidCallback onRetry,
}) {
  if (error is DioException && error.response?.statusCode == 401) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
    return const SizedBox.shrink();
  }
  return LexErrorState(message: message, onRetry: onRetry);
}
