import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/ato_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/simulado_models.dart';

class ModeOptionCard extends StatelessWidget {
  const ModeOptionCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
    this.isComingSoon = false,
  });

  final SimuladoMode mode;
  final bool isSelected;
  final bool isLocked;
  final bool isComingSoon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = (isLocked || isComingSoon)
        ? AppColors.textMuted
        : (isSelected ? AppColors.accent : AppColors.textSecondary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSelected && !isLocked && !isComingSoon
            ? AppColors.accent.withValues(alpha: 0.1)
            : AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isSelected && !isLocked && !isComingSoon
              ? AppColors.borderAccent
              : AppColors.border,
          width: isSelected && !isLocked && !isComingSoon ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.card,
          splashColor: AppColors.accent.withValues(alpha: 0.12),
          highlightColor: AppColors.accent.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    SvgPicture.asset(
                      _modeIconAsset(), width: 28, height: 28,
                      colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                    ),
                    if (isComingSoon)
                      Positioned(
                        right: -2,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSheet,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.border, width: 0.5),
                          ),
                          child: Text(
                            'Em breve',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      )
                    else if (isLocked)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundSheet,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock,
                              color: AppColors.textMuted, size: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  mode.label,
                  style: AppTextStyles.labelMedium.copyWith(color: activeColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _modeIconAsset() => switch (mode) {
        SimuladoMode.oabPhase1  => AtoIcons.modeOab1,
        SimuladoMode.oabPhase2  => AtoIcons.modeOab2,
        SimuladoMode.custom     => AtoIcons.modeCustom,
        SimuladoMode.weakAreas  => AtoIcons.modeWeakAreas,
      };
}
