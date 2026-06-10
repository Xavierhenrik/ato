import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/lcf_text_field.dart';
import '../../../../shared/widgets/social_auth_icons.dart';
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

    await ref.read(authNotifierProvider.notifier).signUp(
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
    // Sucesso: navegação delegada ao redirect do app_router.
    // Redirect #3 envia para /onboarding quando onboarding_done != true.
  }

  Future<void> _onGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    // Navegação delegada ao redirect do app_router via deep link callback.
  }

  Future<void> _onApple() async {
    await ref.read(authNotifierProvider.notifier).signInWithApple();
    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
    // Sucesso: navegação delegada ao redirect do app_router.
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
                    child: Text('Lex', style: AppTextStyles.logoTitle),
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
            initialChildSize: 0.75,
            minChildSize: 0.65,
            maxChildSize: 0.95,
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
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text('Criar conta', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.lg),

                    // Google
                    LcfButton(
                      label: 'Cadastrar com Google',
                      variant: LcfButtonVariant.social,
                      prefixIcon: const GoogleAuthIcon(),
                      onPressed: _onGoogle,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Apple
                    LcfButton(
                      label: 'Cadastrar com Apple',
                      variant: LcfButtonVariant.social,
                      prefixIcon: const AppleAuthIcon(),
                      onPressed: _onApple,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text(
                            'ou cadastre-se com e-mail',
                            style: AppTextStyles.labelSmall,
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

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
