import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/lcf_text_field.dart';
import '../../providers/auth_provider.dart';

class CadastroScreen extends ConsumerStatefulWidget {
  const CadastroScreen({super.key});

  @override
  ConsumerState<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends ConsumerState<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCriarConta() async {
    if (!_formKey.currentState!.validate()) return;

    final isNew = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _senhaCtrl.text,
          displayName: _nomeCtrl.text.trim(),
        );

    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);

    if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
      return;
    }

    if (isNew) {
      context.go('/onboarding');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final isLoading = auth is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fundo com logo
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderAccent, width: 2),
                      color: AppColors.backgroundCard,
                    ),
                    alignment: Alignment.center,
                    child: Text('LCF', style: AppTextStyles.logoTitle),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sua aprovação para OAB começa aqui',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.55,
            maxChildSize: 0.92,
            builder: (context, scrollCtrl) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSheet,
                  borderRadius: AppRadius.sheet,
                ),
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    // Handle + fechar
                    Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text('Criar conta com e-mail', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.xl),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nome
                          LcfTextField(
                            hint: 'Nome completo',
                            controller: _nomeCtrl,
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe seu nome';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // E-mail
                          LcfTextField(
                            hint: 'E-mail',
                            controller: _emailCtrl,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Informe seu e-mail';
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Senha
                          LcfTextField(
                            hint: 'Senha',
                            controller: _senhaCtrl,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onCriarConta(),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Informe uma senha';
                              if (v.length < 8) return 'Mínimo 8 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          LcfButton(
                            label: 'Criar conta e iniciar',
                            onPressed: _onCriarConta,
                            isLoading: isLoading,
                            suffixIcon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            'Ao continuar você concorda com os termos de uso '
                            'e política de privacidade',
                            style: AppTextStyles.labelSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
