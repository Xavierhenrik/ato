import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/assets/ato_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ato_button.dart';
import '../../../../shared/widgets/ato_text_field.dart';
import '../../../../shared/widgets/social_auth_icons.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthMethod { none, email, google, apple }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _rememberMeKey = 'auth_remember_me';
  static const _rememberedEmailKey = 'auth_remembered_email';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _lembrarMe = false;
  _AuthMethod _loading = _AuthMethod.none;

  bool get _anyLoading => _loading != _AuthMethod.none;

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
    setState(() => _loading = _AuthMethod.email);

    await ref.read(authNotifierProvider.notifier).signInWithEmailPassword(
          email: email,
          password: _senhaCtrl.text,
        );

    if (!mounted) return;
    setState(() => _loading = _AuthMethod.none);

    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncData && auth.value != null) {
      await _persistRememberMe(email);
      // Navegação delegada ao redirect do app_router (redirect #2).
    } else if (auth is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error.toString())),
      );
    }
  }

  Future<void> _onGoogle() async {
    setState(() => _loading = _AuthMethod.google);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = _AuthMethod.none);

    final auth = ref.read(authNotifierProvider);
    if (auth is AsyncError) {
      // ignore: avoid_print
      print('[AUTH] Google sign-in error: ${auth.error}\n${auth.stackTrace}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error.toString()),
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.red[800],
        ),
      );
    }
    // Sucesso: navegação delegada ao redirect do app_router (redirect #2).
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
                const _AtoLogo(),
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
                AtoTextField(
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
                AtoTextField(
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
                AtoButton(
                  label: 'Entrar',
                  onPressed: _anyLoading ? null : _onLogin,
                  isLoading: _loading == _AuthMethod.email,
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
                AtoButton(
                  label: 'Entrar com Google',
                  variant: AtoButtonVariant.social,
                  prefixIcon: const GoogleAuthIcon(),
                  onPressed: _anyLoading ? null : _onGoogle,
                  isLoading: _loading == _AuthMethod.google,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Apple
                AtoButton(
                  label: 'Entrar com Apple',
                  variant: AtoButtonVariant.social,
                  prefixIcon: const AppleAuthIcon(),
                  onPressed: _anyLoading ? null : _onApple,
                  isLoading: _loading == _AuthMethod.apple,
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

class _AtoLogo extends StatelessWidget {
  const _AtoLogo();

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
        child: SvgPicture.asset(AtoIcons.logoMark, width: 64, height: 64),
      ),
    );
  }
}

