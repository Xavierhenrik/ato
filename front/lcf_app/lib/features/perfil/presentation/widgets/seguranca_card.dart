import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

// Faint gold background for success feedback (no withOpacity)
const Color _kSuccessBg = Color(0xFF231D0A);

class SegurancaCard extends StatefulWidget {
  const SegurancaCard({super.key});

  @override
  State<SegurancaCard> createState() => _SegurancaCardState();
}

class _SegurancaCardState extends State<SegurancaCard> {
  bool _isLoading = false;
  String? _feedback;
  bool _isError = false;

  Future<void> _resetPassword() async {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = false;
          _feedback = 'Link de recuperação enviado para $email';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _feedback = 'Erro ao enviar e-mail. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.card,
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Segurança da conta', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _isLoading ? null : _resetPassword,
            borderRadius: AppRadius.button,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alterar senha', style: AppTextStyles.labelLarge),
                        Text(
                          'Enviar link de recuperação por e-mail',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            ),
          ),
          if (_feedback != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _isError ? AppColors.errorBg : _kSuccessBg,
                borderRadius: AppRadius.button,
              ),
              child: Text(
                _feedback!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _isError ? AppColors.error : AppColors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
