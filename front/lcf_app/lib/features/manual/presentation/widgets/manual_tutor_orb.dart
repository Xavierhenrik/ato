import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_glass_sheet.dart';
import '../../../tutor/data/models/tutor_models.dart';
import '../../../tutor/presentation/widgets/chat_input_bar.dart';
import '../../data/models/manual_models.dart';

const double _kOrbSize = 56.0;
const double _kSheetHeight = 400.0;

/// Orbe flutuante que abre a gaveta de vidro do Tutor IA.
///
/// Deve ser envolvido em [Positioned.fill] dentro de um [Stack] que cobre
/// toda a área do corpo do [ManualDetailScreen].
class ManualTutorOrb extends StatefulWidget {
  const ManualTutorOrb({super.key, required this.topic});

  final TopicDetail topic;

  @override
  State<ManualTutorOrb> createState() => _ManualTutorOrbState();
}

class _ManualTutorOrbState extends State<ManualTutorOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pillAnim0;
  late final Animation<double> _pillAnim1;
  late final Animation<double> _pillAnim2;
  final _inputController = TextEditingController();

  String get _topicContent => widget.topic.sections
      .map((s) => '${s.title}:\n${s.content}')
      .join('\n\n');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _pillAnim0 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.78, curve: Curves.easeOut),
    );
    _pillAnim1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.52, 0.88, curve: Curves.easeOut),
    );
    _pillAnim2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.64, 1.00, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _open() => _controller.forward();
  void _close() => _controller.reverse();
  void _toggle() => _controller.isCompleted ? _close() : _open();

  void _navigate(String message) {
    _inputController.clear();
    _controller.reverse().then((_) {
      if (!mounted) return;
      context.push(
        '/tutor/context',
        extra: TutorScreenArgs(
          initialMessage: message.isEmpty ? null : message,
          topicContext: TutorTopicContext(
            topicTitle: widget.topic.title,
            topicContent: _topicContent,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final bottomPad = mq.padding.bottom;

    // Posição fechada: canto inferior direito acima da safe area
    final closedLeft = screenWidth - 16.0 - _kOrbSize;
    final closedBottom = 16.0 + bottomPad;

    // Posição aberta: centralizado horizontalmente, meio sobreposto ao topo da gaveta
    final openLeft = (screenWidth - _kOrbSize) / 2.0;
    const openBottom = _kSheetHeight - _kOrbSize / 2.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final interactive = t > 0.01;

        return Stack(
          children: [
            // ── Scrim ─────────────────────────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !interactive,
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.12 * t),
                  ),
                ),
              ),
            ),

            // ── Gaveta de vidro ────────────────────────────────────────────
            // Respiro lateral: a gaveta não encosta nos cantos do aparelho.
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: -_kSheetHeight + _kSheetHeight * t,
              child: IgnorePointer(
                ignoring: !interactive,
                child: LcfGlassSheet(
                  height: _kSheetHeight,
                  child: _SheetContent(
                    inputController: _inputController,
                    pill0Anim: _pillAnim0,
                    pill1Anim: _pillAnim1,
                    pill2Anim: _pillAnim2,
                    onNavigate: _navigate,
                    topPadding: _kOrbSize / 2.0 + AppSpacing.sm,
                  ),
                ),
              ),
            ),

            // ── Orbe (sempre interativo, anima entre as duas posições) ─────
            Positioned(
              left: lerpDouble(closedLeft, openLeft, t)!,
              bottom: lerpDouble(closedBottom, openBottom, t)!,
              child: GestureDetector(
                onTap: _toggle,
                child: const _OrbButton(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Orb button ─────────────────────────────────────────────────────────────────

class _OrbButton extends StatelessWidget {
  const _OrbButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kOrbSize,
      height: _kOrbSize,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 26),
    );
  }
}

// ── Sheet content ──────────────────────────────────────────────────────────────

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.inputController,
    required this.pill0Anim,
    required this.pill1Anim,
    required this.pill2Anim,
    required this.onNavigate,
    required this.topPadding,
  });

  final TextEditingController inputController;
  final Animation<double> pill0Anim;
  final Animation<double> pill1Anim;
  final Animation<double> pill2Anim;
  final void Function(String) onNavigate;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: topPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              _PillButton(
                animation: pill0Anim,
                icon: Icons.school_outlined,
                label: 'Resumo para a prova',
                onTap: () => onNavigate(
                  'Faça um resumo do tópico com os pontos mais importantes para o Exame da OAB.',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PillButton(
                animation: pill1Anim,
                icon: Icons.gavel_outlined,
                label: 'Como cai na OAB?',
                onTap: () => onNavigate(
                  'Como este conteúdo costuma ser cobrado no Exame da OAB? Mostre exemplos do estilo FGV.',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PillButton(
                animation: pill2Anim,
                icon: Icons.lightbulb_outline,
                label: 'Exemplo prático',
                onTap: () => onNavigate(
                  'Dê um exemplo prático e cotidiano para ilustrar e memorizar este conteúdo.',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        ChatInputBar(
          controller: inputController,
          onSend: onNavigate,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}

// ── Pill button ────────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.animation,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Animation<double> animation;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(label, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
