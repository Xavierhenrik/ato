import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

enum LcfButtonVariant { primary, secondary, outline, social, destructive }

class LcfButton extends StatelessWidget {
  const LcfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LcfButtonVariant.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 52.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final LcfButtonVariant variant;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final double width;
  final double height;

  _ButtonStyle get _style => switch (variant) {
        LcfButtonVariant.primary => const _ButtonStyle(
            background: AppColors.accent,
            foreground: Colors.white,
            borderColor: Colors.transparent,
          ),
        LcfButtonVariant.secondary => const _ButtonStyle(
            background: AppColors.backgroundCard,
            foreground: Colors.white,
            borderColor: AppColors.border,
          ),
        LcfButtonVariant.outline => const _ButtonStyle(
            background: Colors.transparent,
            foreground: AppColors.textMuted,
            borderColor: AppColors.borderMuted,
          ),
        LcfButtonVariant.social => const _ButtonStyle(
            background: AppColors.backgroundCard,
            foreground: Colors.white,
            borderColor: AppColors.border,
          ),
        LcfButtonVariant.destructive => const _ButtonStyle(
            background: Colors.transparent,
            foreground: AppColors.error,
            borderColor: AppColors.error,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: s.background,
          foregroundColor: s.foreground,
          side: BorderSide(color: s.borderColor),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: s.foreground,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label, style: AppTextStyles.labelLarge.copyWith(color: s.foreground)),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    required this.borderColor,
  });
  final Color background;
  final Color foreground;
  final Color borderColor;
}
