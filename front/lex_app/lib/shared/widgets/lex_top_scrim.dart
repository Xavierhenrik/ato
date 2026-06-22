import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_tokens.dart';

/// Gradiente de vidro para telas sem AppBar (e.g. TutorScreen).
/// Aplicado como overlay no topo do Stack do body — é transparente a toques.
class LexTopScrim extends StatelessWidget {
  const LexTopScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    final height = top + kToolbarHeight;

    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: RepaintBoundary(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: kGlassFrostSigma,
                sigmaY: kGlassFrostSigma,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundCard.withValues(alpha: 0.55),
                      AppColors.backgroundCard.withValues(alpha: 0.0),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.accent.withValues(alpha: kGlassTrimOpacity),
                      width: kGlassTrimStroke,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
