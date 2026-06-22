import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/lex_app_bar.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_error_state.dart';
import '../../../../shared/widgets/lex_loading_shimmer.dart';
import '../../data/models/perfil_models.dart';
import '../../providers/perfil_provider.dart';
import '../widgets/dados_pessoais_card.dart';
import '../widgets/lex_pro_banner_card.dart';
import '../widgets/preferencias_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/seguranca_card.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LexAppBar(),
      body: perfilAsync.when(
        loading: () => const _PerfilShimmer(),
        error: (e, _) => LexErrorState(
          message: 'Erro ao carregar perfil. Tente novamente.',
          onRetry: () => ref.invalidate(perfilDataProvider),
        ),
        data: (profile) => _buildContent(profile),
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          ProfileHeader(profile: profile),
          const SizedBox(height: AppSpacing.xl),
          DadosPessoaisCard(profile: profile),
          const SizedBox(height: AppSpacing.sectionGap),
          const SegurancaCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          LexProBannerCard(isPro: profile.isPro),
          const SizedBox(height: AppSpacing.sectionGap),
          const PreferenciasCard(),
          const SizedBox(height: AppSpacing.xxxl),
          LexButton(
            label: _isSigningOut ? 'Saindo...' : 'Sair do aplicativo',
            variant: LexButtonVariant.destructive,
            isLoading: _isSigningOut,
            onPressed: _isSigningOut ? null : _signOut,
          ),
          SizedBox(height: context.bottomPad),
        ],
      ),
    );
  }
}

class _PerfilShimmer extends StatelessWidget {
  const _PerfilShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          const Center(
            child: LexLoadingShimmer(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(child: LexLoadingShimmer(width: 160, height: 20)),
          const SizedBox(height: AppSpacing.xs),
          const Center(child: LexLoadingShimmer(width: 200, height: 14)),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sectionGap),
              child: LexLoadingShimmer(height: 100),
            ),
          ),
        ],
      ),
    );
  }
}
