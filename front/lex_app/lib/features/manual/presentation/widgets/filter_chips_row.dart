import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/manual_provider.dart';

const _kFilters = [
  (label: 'Todos', code: null),
  (label: 'Constitucional', code: 'CF'),
  (label: 'Civil', code: 'CC'),
  (label: 'Penal', code: 'CP'),
  (label: 'Trabalho', code: 'CLT'),
  (label: 'Proc. Civil', code: 'CPC'),
  (label: 'Administrativo', code: 'Adm'),
];

class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key, this.onSelected});

  final void Function(String? lawCode)? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedLawCodeProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _kFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final filter = _kFilters[i];
          final isSelected = selected == filter.code;
          return _FilterChip(
            label: filter.label,
            isSelected: isSelected,
            onTap: () {
              ref.read(selectedLawCodeProvider.notifier).select(filter.code);
              onSelected?.call(filter.code);
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.backgroundCard,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color:
                isSelected ? AppColors.borderAccent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
