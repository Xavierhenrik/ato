import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_markdown_body.dart';
import '../../data/models/tutor_models.dart';

/// Renders one chat message bubble.
///
/// For assistant messages we always render Markdown (bold, lists, blockquotes,
/// italics, links). The widget is intentionally stateless: the typewriter
/// reveal during streaming is driven by [TutorNotifier], which updates
/// `streamingContent` char by char — each tick rebuilds this widget with a
/// new `message.content`. We accept the small parser cost in exchange for
/// progressively-formatted text (the ChatGPT/Claude pattern), instead of a
/// jarring plain-text → markdown swap at the end.
///
/// For user messages we use a plain SelectableText (no markdown — user inputs
/// shouldn't render formatting).
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
              child: _isUser
                  ? SelectableText(
                      message.content,
                      style: AppTextStyles.bodyMedium,
                    )
                  : LcfMarkdownBody(data: message.content),
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
