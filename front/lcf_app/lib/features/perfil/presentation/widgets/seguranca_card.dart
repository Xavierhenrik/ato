import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/perfil_repository.dart';


class SegurancaCard extends ConsumerStatefulWidget {
  const SegurancaCard({super.key});

  @override
  ConsumerState<SegurancaCard> createState() => _SegurancaCardState();
}

class _SegurancaCardState extends ConsumerState<SegurancaCard> {
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

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Excluir conta?', style: AppTextStyles.h3),
        content: Text(
          'Sua conta e todos os seus dados (anotações, histórico de simulados, '
          'plano PRO) serão permanentemente apagados. Esta ação não pode ser desfeita.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Excluir minha conta',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      await ref.read(perfilRepositoryProvider).deleteAccount();
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _feedback = 'Erro ao excluir conta. Tente novamente.';
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

          // Alterar senha
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

          const Divider(color: AppColors.border, height: AppSpacing.lg),

          // Excluir conta
          InkWell(
            onTap: _isLoading ? null : _deleteAccount,
            borderRadius: AppRadius.button,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excluir conta',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.error),
                        ),
                        Text(
                          'Remove todos os seus dados permanentemente',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
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
                color: _isError ? AppColors.errorBg : AppColors.info,
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
