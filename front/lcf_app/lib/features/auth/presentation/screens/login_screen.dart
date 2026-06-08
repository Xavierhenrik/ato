import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/lcf_text_field.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _rememberMeKey = 'auth_remember_me';
  static const _rememberedEmailKey = 'auth_remembered_email';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _lembrarMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMeKey) ?? false;
    final savedEmail = prefs.getString(_rememberedEmailKey);
    if (!mounted) return;
    setState(() {
      _lembrarMe = remember;
      if (remember && savedEmail != null && savedEmail.isNotEmpty) {
        _emailCtrl.text = savedEmail;
      }
    });
  }

  Future<void> _persistRememberMe(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_lembrarMe) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_rememberedEmailKey, email);
    } else {
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_rememberedEmailKey);
    }
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    await ref.read(authNotifierProvider.notifier).signInWithEmailPassword(
          email: email,
          password: _senhaCtrl.text,
        );

    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncData && auth.value != null) {
      await _persistRememberMe(email);
      if (!mounted) return;
      context.go('/dashboard');
    } else if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
  }

  Future<void> _onGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _onApple() async {
    await ref.read(authNotifierProvider.notifier).signInWithApple();
    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncData && auth.value != null) context.go('/dashboard');
    if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final isLoading = auth is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                const _LcfLogo(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Sua aprovação para OAB começa aqui',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // E-mail
                Text('E-mail', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                LcfTextField(
                  hint: 'Digite seu e-mail',
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
                const SizedBox(height: AppSpacing.lg),

                // Senha
                Text('Senha', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                LcfTextField(
                  hint: 'Digite sua senha',
                  controller: _senhaCtrl,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onLogin(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe sua senha';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                // Lembrar + esqueci
                Row(
                  children: [
                    Checkbox(
                      value: _lembrarMe,
                      onChanged: (v) => setState(() => _lembrarMe = v ?? false),
                      activeColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.border),
                    ),
                    Text('Lembrar de mim', style: AppTextStyles.bodySmall),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/esqueci-senha'),
                      child: Text('Esqueci minha senha', style: AppTextStyles.link),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Entrar
                LcfButton(
                  label: 'Entrar',
                  onPressed: _onLogin,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'ou continue com',
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Google
                LcfButton(
                  label: 'Entrar com Google',
                  variant: LcfButtonVariant.social,
                  prefixIcon: const _GoogleIcon(),
                  onPressed: _onGoogle,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Apple
                LcfButton(
                  label: 'Entrar com Apple',
                  variant: LcfButtonVariant.social,
                  prefixIcon: const Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _onApple,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Criar conta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Não tem uma conta? ', style: AppTextStyles.bodySmall),
                    GestureDetector(
                      onTap: () => context.push('/cadastro'),
                      child: Text('Criar conta', style: AppTextStyles.link),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Privacy Policy
                Center(
                  child: GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse(
                        'https://xavierhenrik.github.io/LCF/privacy/',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Política de Privacidade',
                      style: AppTextStyles.link.copyWith(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LcfLogo extends StatelessWidget {
  const _LcfLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderAccent, width: 2),
          color: AppColors.backgroundCard,
        ),
        alignment: Alignment.center,
        child: Text('LCF', style: AppTextStyles.logoTitle),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  static const _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: _googleBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}
