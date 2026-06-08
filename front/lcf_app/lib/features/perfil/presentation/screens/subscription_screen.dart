import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_app_bar.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/lcf_error_state.dart';
import '../../../../shared/widgets/lcf_loading_shimmer.dart';
import '../../providers/perfil_provider.dart';

enum _PlanType { monthly, annual }

const _kFeatures = [
  ('📤', 'Todos os materiais\nliberados'),
  ('🎯', 'Revisões ilimitadas\ne inteligentes'),
  ('✅', 'Simulados avançados\ne relatórios'),
  ('💬', 'Suporte prioritário\ncom IA'),
];

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  _PlanType _selected = _PlanType.annual;

  Future<void> _handlePurchase(Package? package) async {
    if (package == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loja indisponível. Tente novamente.')),
      );
      return;
    }
    try {
      await Purchases.purchasePackage(package);
    } on PurchasesError catch (e) {
      if (e.code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro na compra. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LcfAppBar(showBack: true, fallbackRoute: '/perfil'),
      body: perfilAsync.when(
        loading: () => const Center(child: LcfLoadingShimmer(height: 200)),
        error: (e, _) => LcfErrorState(
          message: 'Erro ao carregar dados. Tente novamente.',
          onRetry: () => ref.invalidate(perfilDataProvider),
        ),
        data: (profile) => profile.isPro
            ? _buildAlreadyPro()
            : _buildSubscriptionContent(),
      ),
    );
  }

  Widget _buildAlreadyPro() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium,
              color: AppColors.accent,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Você já é PRÓ!', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Aproveite todos os recursos exclusivos do LCF PRÓ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent() {
    final offeringsAsync = ref.watch(offeringsProvider);
    final annual = offeringsAsync.valueOrNull?.current?.annual;
    final monthly = offeringsAsync.valueOrNull?.current?.monthly;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const _SubscriptionHeader(),
          const SizedBox(height: AppSpacing.xl),
          const _FeatureGrid(),
          const SizedBox(height: AppSpacing.xl),
          Text('Escolha seu plano', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            type: _PlanType.monthly,
            isSelected: _selected == _PlanType.monthly,
            package: monthly,
            onTap: () => setState(() => _selected = _PlanType.monthly),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PlanCard(
            type: _PlanType.annual,
            isSelected: _selected == _PlanType.annual,
            package: annual,
            onTap: () => setState(() => _selected = _PlanType.annual),
          ),
          const SizedBox(height: AppSpacing.xxl),
          LcfButton(
            label: 'Assinar e ativar plano PRÓ',
            onPressed: () => _handlePurchase(
              _selected == _PlanType.annual ? annual : monthly,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SecureFooter(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SubscriptionHeader extends StatelessWidget {
  const _SubscriptionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.workspace_premium,
              color: AppColors.accent,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'LCF PRÓ',
              style: AppTextStyles.h1.copyWith(color: AppColors.accent),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tudo que você precisa para passar na OAB',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: _kFeatures
          .map((f) => _FeatureBlock(emoji: f.$1, label: f.$2))
          .toList(),
    );
  }
}

class _FeatureBlock extends StatelessWidget {
  const _FeatureBlock({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.package,
  });

  final _PlanType type;
  final bool isSelected;
  final VoidCallback onTap;
  final Package? package;

  @override
  Widget build(BuildContext context) {
    final isAnnual = type == _PlanType.annual;
    final priceString = package?.storeProduct.priceString ?? '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border.all(
            color: isSelected ? AppColors.borderAccent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.textMuted,
                  width: 2,
                ),
                color: isSelected ? AppColors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAnnual ? 'Plano anual' : 'Plano mensal',
                        style: AppTextStyles.labelLarge,
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const _SavingsBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isAnnual ? 'melhor custo-benefício' : 'cancele quando quiser',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(priceString, style: AppTextStyles.accentMedium),
                Text(
                  isAnnual ? '/ano' : '/mês',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsBadge extends StatelessWidget {
  const _SavingsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        'Economize 30%',
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SecureFooter extends StatelessWidget {
  const _SecureFooter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary,
            size: 14,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Ambiente 100% seguro com criptografia',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
