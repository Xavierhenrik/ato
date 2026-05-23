import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) onSend(val);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Digite sua pergunta sobre direito',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: enabled ? () => onSend(controller.text) : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: enabled ? AppColors.accent : AppColors.accentDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              '🔒 Respostas geradas por IA, sempre confira as fontes e a legislação vigente',
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
