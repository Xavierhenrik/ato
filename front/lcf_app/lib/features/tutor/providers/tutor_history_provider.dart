import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/tutor_history_models.dart';
import '../data/tutor_repository.dart';

part 'tutor_history_provider.g.dart';

/// Estado da lista de histórico — sessões acumuladas por paginação + metadata.
class TutorHistoryState {
  const TutorHistoryState({
    this.sessions = const [],
    this.isLoadingMore = false,
    this.nextCursor,
    this.retention = 'all',
    this.hasLoaded = false,
  });

  final List<HistorySession> sessions;
  final bool isLoadingMore;
  final String? nextCursor;
  /// 'all' (PRO) ou '7d' (Free) — controla exibição do banner.
  final String retention;
  /// true após a primeira página ter sido carregada com sucesso.
  final bool hasLoaded;

  bool get hasMore => nextCursor != null;

  TutorHistoryState copyWith({
    List<HistorySession>? sessions,
    bool? isLoadingMore,
    String? nextCursor,
    bool clearNextCursor = false,
    String? retention,
    bool? hasLoaded,
  }) =>
      TutorHistoryState(
        sessions: sessions ?? this.sessions,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        nextCursor:
            clearNextCursor ? null : (nextCursor ?? this.nextCursor),
        retention: retention ?? this.retention,
        hasLoaded: hasLoaded ?? this.hasLoaded,
      );
}

/// Provider da lista de histórico. Recebe o [mode] como parâmetro ('direct' | 'reading').
/// Usa paginação por cursor. Suporta carga incremental e delete otimista.
@riverpod
class TutorHistoryNotifier extends _$TutorHistoryNotifier {
  @override
  Future<TutorHistoryState> build(String mode) async {
    final response = await ref
        .read(tutorRepositoryProvider)
        .getHistory(mode: mode);
    return TutorHistoryState(
      sessions: response.sessions,
      nextCursor: response.nextCursor,
      retention: response.retention,
      hasLoaded: true,
    );
  }

  /// Carrega a próxima página usando o cursor atual.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.isLoadingMore) return;
    final cursor = current.nextCursor;
    if (cursor == null) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final response = await ref
          .read(tutorRepositoryProvider)
          .getHistory(mode: mode, cursor: cursor);

      final updated = current.copyWith(
        sessions: [...current.sessions, ...response.sessions],
        nextCursor: response.nextCursor,
        clearNextCursor: response.nextCursor == null,
        retention: response.retention,
        isLoadingMore: false,
        hasLoaded: true,
      );
      state = AsyncData(updated);
    } catch (e, st) {
      // Reverte flag de loading mas mantém os dados já carregados
      state = AsyncData(current.copyWith(isLoadingMore: false));
      // Re-expose o erro via AsyncError temporário — a tela pode usar .hasError
      // Não fazemos rethrow pois não queremos perder os dados já carregados.
      // Ignorado silenciosamente: a tela mostrará o estado anterior.
      Error.throwWithStackTrace(e, st);
    }
  }

  /// Delete otimista: remove da lista localmente, chama API, reverte em erro.
  Future<void> deleteSession(String sessionId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final originalSessions = List<HistorySession>.from(current.sessions);
    final filtered =
        current.sessions.where((s) => s.id != sessionId).toList();
    state = AsyncData(current.copyWith(sessions: filtered));

    try {
      await ref.read(tutorRepositoryProvider).deleteHistory(sessionId);
    } catch (_) {
      // Reverte em caso de erro
      state = AsyncData(current.copyWith(sessions: originalSessions));
      rethrow;
    }
  }
}
