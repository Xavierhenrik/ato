import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/assets/lex_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lex_button.dart';

const _kProFeatures = [
  'Simulados ilimitados com relatórios',
  'Tutor IA avançado com auto-save',
  'Revisões ilimitadas e inteligentes',
  'Suporte prioritário',
];

class LexProBannerCard extends StatelessWidget {
  const LexProBannerCard({super.key, required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.borderAccent, width: 1.5),
        borderRadius: AppRadius.card,
      ),
      padding: AppSpacing.cardPadding,
      child: isPro ? const _ProContent() : const _FreeContent(),
    );
  }
}

class _FreeContent extends StatelessWidget {
  const _FreeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BannerHeader(),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Desbloqueie todo o potencial da sua preparação',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._kProFeatures.map((f) => _FeatureRow(text: f)),
        const SizedBox(height: AppSpacing.lg),
        LexButton(
          label: 'Assinar PRÓ',
          onPressed: () => context.push('/subscription'),
        ),
      ],
    );
  }
}

class _ProContent extends StatelessWidget {
  const _ProContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BannerHeader(),
        const SizedBox(height: AppSpacing.md),
        ..._kProFeatures.map((f) => _FeatureRow(text: f)),
        const SizedBox(height: AppSpacing.lg),
        LexButton(
          label: 'Gerenciar plano',
          onPressed: () => _openManagementUrl(context),
        ),
      ],
    );
  }

  Future<void> _openManagementUrl(BuildContext context) async {
    // TODO(F8): replace with Purchases.managementURL from RevenueCat SDK
    const url = 'https://apps.apple.com/account/subscriptions';
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o gerenciador de assinatura.'),
          ),
        );
      }
    }
  }
}

class _BannerHeader extends StatelessWidget {
  const _BannerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          LexIcons.crownPro, width: 20, height: 20,
          colorFilter: const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('Lex PRÓ', style: AppTextStyles.h3Gold),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
