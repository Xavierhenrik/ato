import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class TutorConsentModal extends StatelessWidget {
  const TutorConsentModal({super.key});

  static const _privacyUrl = 'https://xavierhenrik.github.io/LCF/privacy/';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      title: Text('Tutor com Inteligência Artificial', style: AppTextStyles.h3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para responder suas dúvidas jurídicas, suas mensagens são '
            'processadas por Maritaca AI (Sabiá-4) e Anthropic (Claude). '
            'Essas empresas podem processar os dados conforme suas próprias '
            'políticas de privacidade. Não envie informações pessoais '
            'sensíveis nas mensagens ao Tutor.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(_privacyUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Text('Saiba mais', style: AppTextStyles.link),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Recusar',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Aceitar e continuar',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}
