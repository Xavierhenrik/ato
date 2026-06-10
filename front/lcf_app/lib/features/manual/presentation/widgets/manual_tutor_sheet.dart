import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/manual_models.dart';
import '../../../tutor/data/models/tutor_models.dart';

/// Bottom sheet exibido ao tocar no ícone ⚡ de uma seção do tópico.
/// Apresenta ações rápidas do Tutor IA pré-configuradas com o contexto
/// do tópico atual e navega para /tutor/context com a mensagem inicial.
class ManualTutorSheet extends StatelessWidget {
  const ManualTutorSheet({
    super.key,
    required this.section,
    required this.topic,
  });

  final TopicSection section;
  final TopicDetail topic;

  // Combina todas as seções do tópico em um único bloco de contexto
  // para o system prompt do Tutor IA.
  String get _topicContent => topic.sections
      .map((s) => '${s.title}:\n${s.content}')
      .join('\n\n');

  static void show(
    BuildContext context,
    TopicSection section,
    TopicDetail topic,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ManualTutorSheet(section: section, topic: topic),
    );
  }

  void _navigate(BuildContext context, String? message) {
    Navigator.of(context).pop(); // fecha o sheet
    context.push(
      '/tutor/context',
      extra: TutorScreenArgs(
        initialMessage: message,
        topicContext: TutorTopicContext(
          topicTitle: topic.title,
          topicContent: _topicContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.borderAccent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  alignment: Alignment.center,
                  child: Text('Lex', style: AppTextStyles.accentMedium),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tutor IA', style: AppTextStyles.labelLarge),
                      Text(
                        section.title,
                        style: AppTextStyles.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // ── Ações rápidas ─────────────────────────────────────────────
          _ActionTile(
            icon: Icons.school_outlined,
            label: 'Resumo para prova',
            subtitle: 'Pontos-chave para o Exame da OAB',
            onTap: () => _navigate(
              context,
              'Faça um resumo desta seção com os pontos mais importantes para o Exame da OAB.',
            ),
          ),
          _ActionTile(
            icon: Icons.gavel_outlined,
            label: 'Como cai na OAB?',
            subtitle: 'Estilo de questão FGV sobre este conteúdo',
            onTap: () => _navigate(
              context,
              'Como este conteúdo costuma ser cobrado no Exame da OAB? Mostre exemplos do estilo FGV.',
            ),
          ),
          _ActionTile(
            icon: Icons.lightbulb_outline,
            label: 'Exemplo prático',
            subtitle: 'Situação real para fixar o conteúdo',
            onTap: () => _navigate(
              context,
              'Dê um exemplo prático e cotidiano para ilustrar e memorizar este conteúdo.',
            ),
          ),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            label: 'Tenho uma dúvida',
            subtitle: 'Abrir o chat para perguntar livremente',
            isLast: true,
            onTap: () => _navigate(context, null), // sem mensagem pré-definida
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.bodyMedium),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            color: AppColors.border,
            height: 1,
            indent: AppSpacing.lg + 20 + AppSpacing.md,
          ),
      ],
    );
  }
}
