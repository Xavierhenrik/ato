import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/tutor_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final TutorMessage message;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            const _RobotAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _isUser
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.backgroundCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.md),
                  topRight: const Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(
                    _isUser ? AppRadius.md : AppRadius.xs,
                  ),
                  bottomRight: Radius.circular(
                    _isUser ? AppRadius.xs : AppRadius.md,
                  ),
                ),
                border: Border.all(
                  color: _isUser
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Text(message.content, style: AppTextStyles.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _RobotAvatar extends StatelessWidget {
  const _RobotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderAccent),
      ),
      child: const Icon(Icons.smart_toy, color: AppColors.accent, size: 18),
    );
  }
}
