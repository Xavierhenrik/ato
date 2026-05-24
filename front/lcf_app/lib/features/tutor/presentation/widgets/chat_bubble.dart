import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/tutor_models.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.animate = false,
    this.streaming = false,
  });

  final TutorMessage message;

  /// Run typewriter animation on this bubble. Used for the first render of a
  /// freshly received assistant message.
  final bool animate;

  /// This bubble is showing live chunks coming from the backend (SSE).
  /// While true, content is rendered as plain text to avoid markdown parser
  /// flicker on partial input (e.g. unclosed **bold** or incomplete bullets).
  /// Render switches to full markdown once streaming finishes.
  final bool streaming;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  static const Duration _tickInterval = Duration(milliseconds: 18);

  Timer? _timer;
  int _visibleLength = 0;

  bool get _isUser => widget.message.role == 'user';
  bool get _shouldAnimate => widget.animate && !_isUser;

  @override
  void initState() {
    super.initState();
    if (_shouldAnimate) {
      _startAnimation();
    } else {
      _visibleLength = widget.message.content.length;
    }
  }

  @override
  void didUpdateWidget(covariant ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.content != widget.message.content) {
      if (_shouldAnimate) {
        _restartAnimation();
      } else {
        _timer?.cancel();
        _visibleLength = widget.message.content.length;
      }
    } else if (oldWidget.animate != widget.animate) {
      if (_shouldAnimate) {
        _restartAnimation();
      } else {
        _timer?.cancel();
        setState(() => _visibleLength = widget.message.content.length);
      }
    }
  }

  void _restartAnimation() {
    _timer?.cancel();
    _visibleLength = 0;
    _startAnimation();
  }

  void _startAnimation() {
    final totalLength = widget.message.content.length;
    if (totalLength == 0) return;
    _timer = Timer.periodic(_tickInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleLength >= totalLength) {
        timer.cancel();
        return;
      }
      setState(() => _visibleLength++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Decides whether to render plain text (during streaming/animation, to avoid
  /// markdown parser flicker on partial content) or full markdown.
  Widget _buildContent(String content) {
    if (_isUser) {
      return SelectableText(content, style: AppTextStyles.bodyMedium);
    }
    final stillTyping =
        _shouldAnimate && _visibleLength < widget.message.content.length;
    if (widget.streaming || stillTyping) {
      // Plain text while content is incoming or being revealed.
      return Text(content, style: AppTextStyles.bodyMedium);
    }
    // Final render: markdown (bold, headers, bullets, code) + selectable.
    return MarkdownBody(
      data: content,
      shrinkWrap: true,
      selectable: true,
      styleSheet: _markdownStyleSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayContent = _shouldAnimate
        ? widget.message.content.substring(0, _visibleLength)
        : widget.message.content;

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
              child: _buildContent(displayContent),
            ),
          ),
        ],
      ),
    );
  }

  static final MarkdownStyleSheet _markdownStyleSheet = MarkdownStyleSheet(
    p: AppTextStyles.bodyMedium,
    h1: AppTextStyles.h1,
    h2: AppTextStyles.h2,
    h3: AppTextStyles.h3Gold,
    h4: AppTextStyles.labelLarge,
    h5: AppTextStyles.labelLarge,
    h6: AppTextStyles.labelLarge,
    strong: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
    em: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
    code: AppTextStyles.bodyMedium.copyWith(
      fontFamily: 'monospace',
      color: AppColors.accentLight,
      backgroundColor: AppColors.backgroundCard,
    ),
    codeblockDecoration: BoxDecoration(
      color: AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      border: Border.all(color: AppColors.border),
    ),
    codeblockPadding: const EdgeInsets.all(AppSpacing.md),
    blockquote: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
      fontStyle: FontStyle.italic,
    ),
    blockquoteDecoration: BoxDecoration(
      color: AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      border: const Border(
        left: BorderSide(color: AppColors.accent, width: 3),
      ),
    ),
    blockquotePadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    listBullet: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
    a: AppTextStyles.link,
    tableHead: AppTextStyles.labelLarge,
    tableBody: AppTextStyles.bodyMedium,
    tableBorder: TableBorder.all(color: AppColors.border),
    tableCellsPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    horizontalRuleDecoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
  );
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
