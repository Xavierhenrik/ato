import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Paleta de background por matéria (conforme SCREENS.md §10).
const Map<String, Color> _subjectColors = {
  'Constitucional':  Color(0xFF1A3A5C),
  'Civil':           Color(0xFF1A3A2A),
  'Penal':           Color(0xFF5C1A1A),
  'Trabalho':        Color(0xFF3A2A1A),
  'Proc. Civil':     Color(0xFF2A1A5C),
  'Administrativo':  Color(0xFF1A3A3A),
  'OAB':             Color(0xFF3A3A1A),
};

/// Pill colorido de categoria/matéria.
///
/// Uso:
/// ```dart
/// CategoryTag(label: 'Constitucional')             // cor automática por matéria
/// CategoryTag(label: 'Outro', color: AppColors.tagBackground) // cor manual
/// ```
class CategoryTag extends StatelessWidget {
  const CategoryTag({
    super.key,
    required this.label,
    this.color,
  });

  final String label;

  /// Se null, lookup em [_subjectColors]; fallback: [AppColors.tagBackground].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ??
        _subjectColors.entries
            .firstWhere(
              (e) => label.contains(e.key),
              orElse: () =>
                  const MapEntry('', AppColors.tagBackground),
            )
            .value;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
