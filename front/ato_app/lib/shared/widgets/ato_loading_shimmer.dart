import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Shimmer genérico. Passe [width] e [height] para um bloco único,
/// ou [child] para shimmer sobre widget customizado.
class AtoLoadingShimmer extends StatelessWidget {
  const AtoLoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius,
    this.child,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundCard,
      highlightColor: AppColors.border,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius:
                  borderRadius ?? BorderRadius.circular(AppRadius.md),
            ),
          ),
    );
  }
}

/// Lista vertical de shimmer cards — atalho para estados de loading em listas.
class AtoListShimmer extends StatelessWidget {
  const AtoListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => AtoLoadingShimmer(height: itemHeight),
    );
  }
}
