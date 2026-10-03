import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ato_button.dart';
import '../../../../shared/widgets/ato_glass_sheet.dart';
import '../../../../shared/widgets/ato_text_field.dart';
import '../../../../shared/widgets/social_auth_icons.dart';
import '../../providers/auth_provider.dart';

enum _AuthMethod { none, google, apple, email }

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

  _AuthMethod _loading = _AuthMethod.none;

  bool get _anyLoading => _loading != _AuthMethod.none;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCriarConta() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = _AuthMethod.email);

    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _senhaCtrl.text,
          displayName: _nomeCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _loading = _AuthMethod.none);

    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
    // Sucesso: navegação delegada ao redirect do app_router.
  }

  Future<void> _onGoogle() async {
    setState(() => _loading = _AuthMethod.google);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = _AuthMethod.none);

    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
    // Sucesso: browser aberto — listener onAuthStateChange cuida da navegação.
  }

  Future<void> _onApple() async {
    setState(() => _loading = _AuthMethod.apple);
    await ref.read(authNotifierProvider.notifier).signInWithApple();
    if (!mounted) return;
    setState(() => _loading = _AuthMethod.none);

    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Overlay modal: a rota é transparente (_slideUpPage com opaque: false),
    // o login permanece visível atrás e o AtoGlassSheet o frosta. Sem fundo
    // próprio — o logo e a tagline são os do login, atrás do scrim.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Área acima do sheet — tap fecha, como em bottom sheet nativo.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:
                  _anyLoading ? null : () => Navigator.of(context).maybePop(),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollCtrl) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: AtoGlassSheet(
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
                            onTap: _anyLoading
                                ? null
                                : () => Navigator.of(context).maybePop(),
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
                      AtoButton(
                        label: 'Cadastrar com Google',
                        variant: AtoButtonVariant.social,
                        prefixIcon: const GoogleAuthIcon(),
                        onPressed: _anyLoading ? null : _onGoogle,
                        isLoading: _loading == _AuthMethod.google,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Apple
                      AtoButton(
                        label: 'Cadastrar com Apple',
                        variant: AtoButtonVariant.social,
                        prefixIcon: const AppleAuthIcon(),
                        onPressed: _anyLoading ? null : _onApple,
                        isLoading: _loading == _AuthMethod.apple,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Text(
                              'ou cadastre-se com e-mail',
                              style: AppTextStyles.labelSmall,
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Nome
                            AtoTextField(
                              hint: 'Nome completo',
                              controller: _nomeCtrl,
                              icon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              enabled: !_anyLoading,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Informe seu nome';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // E-mail
                            AtoTextField(
                              hint: 'E-mail',
                              controller: _emailCtrl,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !_anyLoading,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Informe seu e-mail';
                                }
                                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                                  return 'E-mail inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Senha
                            AtoTextField(
                              hint: 'Senha',
                              controller: _senhaCtrl,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              enabled: !_anyLoading,
                              onSubmitted: (_) => _onCriarConta(),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Informe uma senha';
                                }
                                if (v.length < 8) return 'Mínimo 8 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            AtoButton(
                              label: 'Criar conta e iniciar',
                              onPressed: _anyLoading ? null : _onCriarConta,
                              isLoading: _loading == _AuthMethod.email,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
