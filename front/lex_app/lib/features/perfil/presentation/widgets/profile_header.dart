import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/perfil_models.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundCard,
            border: Border.all(color: AppColors.borderAccent, width: 2),
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.accent,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(profile.name, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(profile.email, style: AppTextStyles.bodySmall),
        if (profile.isPro) ...[
          const SizedBox(height: AppSpacing.sm),
          const _ProBadge(),
        ],
      ],
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSheet,
        border: Border.all(color: AppColors.accentDark),
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        'Membro PRÓ',
        style: AppTextStyles.accentMedium.copyWith(fontSize: 12),
      ),
    );
  }
}
