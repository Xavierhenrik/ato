import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Diálogo de confirmação padrão LEX.
/// Retorna [true] se o usuário confirmou, [false] se cancelou ou dispensou.
Future<bool> lexConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  Color confirmColor = AppColors.error,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      title: Text(title, style: AppTextStyles.h3),
      content: Text(
        body,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancelar',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel,
            style: AppTextStyles.bodyMedium.copyWith(color: confirmColor),
          ),
        ),
      ],
    ),
  );
  return result == true;
}
