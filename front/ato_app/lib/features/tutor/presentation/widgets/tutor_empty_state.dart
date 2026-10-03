import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'tutor_suggestions_card.dart';
import 'tutor_welcome_card.dart';

class TutorEmptyState extends StatelessWidget {
  const TutorEmptyState({super.key, required this.onChipTap});

  final ValueChanged<String> onChipTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const TutorWelcomeCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          TutorSuggestionsCard(onChipTap: onChipTap),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
