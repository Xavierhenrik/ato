import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_app_bar.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/lcf_text_field.dart';
import '../../providers/auth_provider.dart';

class ResetSenhaScreen extends ConsumerStatefulWidget {
  const ResetSenhaScreen({super.key});

  @override
  ConsumerState<ResetSenhaScreen> createState() => _ResetSenhaScreenState();
}

class _ResetSenhaScreenState extends ConsumerState<ResetSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onEnviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .resetPassword(_emailCtrl.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LcfAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: _sent ? _SentState() : _InputState(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            loading: _loading,
            onEnviar: _onEnviar,
          ),
        ),
      ),
    );
  }
}

class _InputState extends StatelessWidget {
  const _InputState({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onEnviar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderAccent, width: 1.5),
                color: AppColors.backgroundCard,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.accent,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Recuperar senha', style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Digite seu e-mail e enviaremos um link de recuperação',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          LcfTextField(
            hint: 'Seu e-mail',
            controller: emailCtrl,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onEnviar(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe seu e-mail';
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          LcfButton(
            label: 'Enviar link',
            onPressed: onEnviar,
            isLoading: loading,
          ),
        ],
      ),
    );
  }
}

class _SentState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderAccent, width: 1.5),
              color: AppColors.backgroundCard,
            ),
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.accent, size: 32),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('E-mail enviado!', style: AppTextStyles.h2, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Verifique sua caixa de entrada e siga as instruções',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        LcfButton(
          label: 'Voltar ao login',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
