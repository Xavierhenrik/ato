import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/utils/ato_dialogs.dart';
import '../../../../shared/widgets/ato_button.dart';
import '../../data/models/simulado_models.dart';
import '../../data/simulado_repository.dart';
import '../widgets/answer_option.dart';
import '../widgets/question_card.dart';

class SimuladoAttemptScreen extends ConsumerStatefulWidget {
  const SimuladoAttemptScreen({super.key, required this.attempt});

  final SimuladoAttempt attempt;

  @override
  ConsumerState<SimuladoAttemptScreen> createState() =>
      _SimuladoAttemptScreenState();
}

class _SimuladoAttemptScreenState
    extends ConsumerState<SimuladoAttemptScreen> {
  final _scrollController = ScrollController();

  int _currentIndex = 0;
  String? _selectedAnswer;
  AnswerResult? _lastResult;
  bool _isLoading = false;

  SimuladoAttempt get _attempt => widget.attempt;
  Question get _currentQuestion => _attempt.questions[_currentIndex];
  bool get _isLastQuestion =>
      _currentIndex >= _attempt.totalQuestions - 1;

  AnswerState _stateFor(String letter) {
    final result = _lastResult;
    if (result == null) {
      return _selectedAnswer == letter
          ? AnswerState.selected
          : AnswerState.idle;
    }
    if (letter == result.correctAnswer) return AnswerState.correct;
    if (letter == _selectedAnswer && !result.correct) {
      return AnswerState.wrong;
    }
    return AnswerState.idle;
  }

  void _onSelect(String letter) {
    if (_lastResult != null || _isLoading) return;
    setState(() => _selectedAnswer = letter);
  }

  Future<void> _confirmAnswer() async {
    final selected = _selectedAnswer;
    if (selected == null || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(simuladoRepositoryProvider)
          .answerQuestion(
            simuladoId: _attempt.id,
            questionId: _currentQuestion.id,
            answer: selected,
          );
      if (mounted) setState(() => _lastResult = result);
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      if (status == 401) {
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao conectar. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _advance() async {
    if (_isLastQuestion) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(simuladoRepositoryProvider)
            .completeSimulado(_attempt.id);
        if (mounted) {
          context.go('/simulados/${_attempt.id}/results');
        }
      } on DioException catch (e) {
        if (!mounted) return;
        final status = e.response?.statusCode;
        if (status == 401) {
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao conectar. Tente novamente.'),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _lastResult = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmAbandon() async {
    final confirmed = await atoConfirmDialog(
      context,
      title: 'Abandonar simulado?',
      body: 'Seu progresso será perdido e o simulado será encerrado.',
      confirmLabel: 'Abandonar',
    );

    if (!confirmed || !mounted) return;
    try {
      await ref
          .read(simuladoRepositoryProvider)
          .abandonSimulado(_attempt.id);
    } catch (_) { /* fire-and-forget */ }
    if (mounted) context.go('/simulados');
  }

  String get _actionLabel {
    if (_lastResult == null) return 'Confirmar resposta';
    return _isLastQuestion ? 'Ver resultado' : 'Próxima questão';
  }

  bool get _actionEnabled {
    if (_isLoading) return false;
    if (_lastResult != null) return true;
    return _selectedAnswer != null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _attempt.totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AttemptAppBar(
        current: _currentIndex + 1,
        total: _attempt.totalQuestions,
        onAbandon: _confirmAbandon,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            color: AppColors.accent,
            minHeight: 3,
          ),

          // Content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: AppSpacing.screenPadding,
              children: [
                QuestionCard(question: _currentQuestion),
                const SizedBox(height: AppSpacing.lg),

                // Options
                ..._currentQuestion.opcoes.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AnswerOption(
                      letter: e.key,
                      text: e.value,
                      state: _stateFor(e.key),
                      onTap: () => _onSelect(e.key),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Action bar
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg + context.bottomPad,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: AtoButton(
              label: _isLoading ? 'Aguarde...' : _actionLabel,
              onPressed: _actionEnabled
                  ? (_lastResult == null ? _confirmAnswer : _advance)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AttemptAppBar({
    required this.current,
    required this.total,
    required this.onAbandon,
  });

  final int current;
  final int total;
  final VoidCallback onAbandon;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimary),
        onPressed: onAbandon,
      ),
      title: Text(
        'Questão $current de $total',
        style: AppTextStyles.h3,
      ),
      centerTitle: true,
    );
  }
}
