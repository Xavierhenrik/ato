import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_tokens.dart';
import '../providers/nav_bar_provider.dart';

// ── Métricas da barra ──────────────────────────────────────────────────────────
const double _kBarHeight = 58.0;
const double _kBarMargin = AppSpacing.sm; // 8 px

/// Espaço que as telas do shell devem reservar na base para não ficar oculto.
const double _kClearance = _kBarHeight + _kBarMargin * 2;

// ── Tabs ───────────────────────────────────────────────────────────────────────

const _kMainTabs = [
  _Tab('/tutor', Icons.chat_bubble_outline, Icons.chat_bubble, 'Tutor'),
  _Tab('/dashboard', Icons.home_outlined, Icons.home, 'Início'),
  _Tab('/perfil', Icons.person_outline, Icons.person, 'Perfil'),
];

const _kMoreTabs = [
  _Tab('/anotacoes', Icons.edit_note_outlined, Icons.edit_note, 'Anotações'),
  _Tab('/manual', Icons.menu_book_outlined, Icons.menu_book, 'Manual'),
  _Tab('/simulados', Icons.quiz_outlined, Icons.quiz, 'Simulados'),
];

// ── Widget principal ───────────────────────────────────────────────────────────

class LcfGlassNavBar extends ConsumerStatefulWidget {
  const LcfGlassNavBar({super.key, required this.location});

  final String location;

  static const double clearance = _kClearance;
  static const double barHeight = _kBarHeight;
  static const double barMargin = _kBarMargin;

  @override
  ConsumerState<LcfGlassNavBar> createState() => _LcfGlassNavBarState();
}

class _LcfGlassNavBarState extends ConsumerState<LcfGlassNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _moreCtrl;
  late final AnimationController _compactCtrl; // conteúdo: expanded → compact
  late final Animation<double> _pill0;
  late final Animation<double> _pill1;
  late final Animation<double> _pill2;

  bool _awaitingExpand = false; // primeiro toque no círculo compacto

  @override
  void initState() {
    super.initState();
    _moreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _compactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _pill0 = CurvedAnimation(
      parent: _moreCtrl,
      curve: const Interval(0.40, 0.78, curve: Curves.easeOut),
    );
    _pill1 = CurvedAnimation(
      parent: _moreCtrl,
      curve: const Interval(0.52, 0.88, curve: Curves.easeOut),
    );
    _pill2 = CurvedAnimation(
      parent: _moreCtrl,
      curve: const Interval(0.64, 1.00, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _moreCtrl.dispose();
    _compactCtrl.dispose();
    super.dispose();
  }

  void _toggleMore() {
    if (_moreCtrl.isCompleted) {
      _closeMore();
    } else {
      _moreCtrl.forward();
      ref.read(navDialOpenProvider.notifier).state = true;
    }
  }

  void _closeMore() {
    if (!_moreCtrl.isDismissed) {
      _moreCtrl.reverse();
      ref.read(navDialOpenProvider.notifier).state = false;
    }
  }

  void _navigate(String route) {
    ref.read(navDialOpenProvider.notifier).state = false;
    _moreCtrl.reverse().then((_) {
      if (!mounted) return;
      context.go(route);
    });
  }

  // Dois toques para restaurar: primeiro toque = feedback dourado,
  // segundo toque = expande de volta.
  void _handleCompactTap() {
    if (!_awaitingExpand) {
      setState(() => _awaitingExpand = true);
    } else {
      setState(() => _awaitingExpand = false);
      ref.read(navBarModeProvider.notifier).state = NavBarMode.expanded;
    }
  }

  bool _isMoreSelected(String location) =>
      _kMoreTabs.any((t) => location.startsWith(t.route));

  int _activeMainIndex(String location) {
    final idx = _kMainTabs.indexWhere((t) => location.startsWith(t.route));
    return idx == -1 ? 1 : idx;
  }

  @override
  Widget build(BuildContext context) {
    // Fecha speed-dial quando barrier externo seta false.
    ref.listen<bool>(navDialOpenProvider, (_, next) {
      if (!next && !_moreCtrl.isDismissed) _moreCtrl.reverse();
    });

    // Reage a mudanças de modo: compact → anima conteúdo; expanded → reverte.
    ref.listen<NavBarMode>(navBarModeProvider, (_, next) {
      if (next == NavBarMode.compact) {
        _closeMore(); // fecha speed-dial se aberto
        _compactCtrl.forward();
      } else {
        _compactCtrl.reverse();
        if (_awaitingExpand) setState(() => _awaitingExpand = false);
      }
    });

    final mode = ref.watch(navBarModeProvider);
    final mq = MediaQuery.of(context);
    final kbOpen = mq.viewInsets.bottom > 0;
    // Compact: teclado cobre o círculo naturalmente (ScaffoldWithNav não redimensiona).
    // Expanded: oculta com AnimatedSlide quando teclado abre.
    final isVisible = mode == NavBarMode.compact || !kbOpen;
    final bottomPad = mq.viewPadding.bottom;
    final location = widget.location;
    final moreSelected = _isMoreSelected(location);
    final activeMainIndex = _activeMainIndex(location);

    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      offset: isVisible ? Offset.zero : const Offset(0, 1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: AnimatedBuilder(
          animation: Listenable.merge([_moreCtrl, _compactCtrl]),
          builder: (context, _) {
            final ct = _compactCtrl.value; // 0=expanded, 1=compact
            final isDialOpen = !_moreCtrl.isDismissed;
            return Padding(
              padding: EdgeInsets.only(
                // Margens laterais são controladas pelo ScaffoldWithNav via Positioned.
                bottom: _kBarMargin + bottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speed-dial pills — só no modo expandido
                  if (isDialOpen && ct < 0.25) ...[
                    _SpeedDialPill(
                      tab: _kMoreTabs[0],
                      animation: _pill0,
                      onTap: () => _navigate(_kMoreTabs[0].route),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SpeedDialPill(
                      tab: _kMoreTabs[1],
                      animation: _pill1,
                      onTap: () => _navigate(_kMoreTabs[1].route),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SpeedDialPill(
                      tab: _kMoreTabs[2],
                      animation: _pill2,
                      onTap: () => _navigate(_kMoreTabs[2].route),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  _GlassPill(
                    activeMainIndex: activeMainIndex,
                    moreSelected: moreSelected,
                    moreOpen: _moreCtrl.isCompleted,
                    moreAnimValue: _moreCtrl.value,
                    compactT: ct,
                    awaitingExpand: _awaitingExpand,
                    onTabTap: (route) => context.go(route),
                    onMoreTap: _toggleMore,
                    onCompactTap: _handleCompactTap,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Pílula de vidro principal ──────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.activeMainIndex,
    required this.moreSelected,
    required this.moreOpen,
    required this.moreAnimValue,
    required this.compactT,
    required this.awaitingExpand,
    required this.onTabTap,
    required this.onMoreTap,
    required this.onCompactTap,
  });

  final int activeMainIndex;
  final bool moreSelected;
  final bool moreOpen;
  final double moreAnimValue;
  final double compactT;
  final bool awaitingExpand;
  final void Function(String) onTabTap;
  final VoidCallback onMoreTap;
  final VoidCallback onCompactTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_kBarHeight / 2);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kGlassFrostSigma,
          sigmaY: kGlassFrostSigma,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _kBarHeight,
          decoration: BoxDecoration(
            // Dourado quando aguardando segundo toque para expandir.
            color: awaitingExpand
                ? AppColors.accent.withValues(alpha: 0.88)
                : AppColors.backgroundCard.withValues(alpha: 0.18),
            borderRadius: radius,
            border: Border.all(
              color: AppColors.accent.withValues(
                alpha: awaitingExpand ? 1.0 : kGlassTrimOpacity,
              ),
              width: kGlassTrimStroke,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Conteúdo expandido (nav items) ────────────────────────────
              IgnorePointer(
                ignoring: compactT >= 0.5,
                child: Opacity(
                  opacity: (1.0 - compactT).clamp(0.0, 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < _kMainTabs.length; i++)
                        _NavItem(
                          tab: _kMainTabs[i],
                          selected: !moreSelected && i == activeMainIndex,
                          onTap: () => onTabTap(_kMainTabs[i].route),
                        ),
                      _MoreButton(
                        selected: moreSelected,
                        open: moreOpen,
                        animValue: moreAnimValue,
                        onTap: onMoreTap,
                      ),
                    ],
                  ),
                ),
              ),
              // ── Conteúdo compacto (ícone de restore) ──────────────────────
              IgnorePointer(
                ignoring: compactT < 0.5,
                child: Opacity(
                  opacity: compactT.clamp(0.0, 1.0),
                  child: GestureDetector(
                    onTap: onCompactTap,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedScale(
                      scale: awaitingExpand ? 1.18 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.elasticOut,
                      child: Center(
                        child: Icon(
                          Icons.apps,
                          size: 28,
                          color: awaitingExpand
                              ? AppColors.background
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item de navegação ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textMuted;
    return Semantics(
      label: tab.label,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 80,
          height: _kBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? tab.selectedIcon : tab.icon,
                color: color,
                size: 26,
              ),
              const SizedBox(height: 3),
              Text(
                tab.label,
                style: (selected
                        ? AppTextStyles.navLabelSelected
                        : AppTextStyles.navLabelUnselected)
                    .copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Botão "mais" ───────────────────────────────────────────────────────────────

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.selected,
    required this.open,
    required this.animValue,
    required this.onTap,
  });

  final bool selected;
  final bool open;
  final double animValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = (selected || open) ? AppColors.accent : AppColors.textMuted;
    return Semantics(
      label: open ? 'Fechar menu' : 'Mais opções',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 80,
          height: _kBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: animValue * 0.5 * 3.14159,
                child: Icon(
                  open ? Icons.close : Icons.more_horiz,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Mais',
                style: AppTextStyles.navLabelUnselected.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pílula do speed-dial ───────────────────────────────────────────────────────

class _SpeedDialPill extends StatelessWidget {
  const _SpeedDialPill({
    required this.tab,
    required this.animation,
    required this.onTap,
  });

  final _Tab tab;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: Semantics(
          label: tab.label,
          button: true,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: ClipRRect(
              borderRadius: AppRadius.chip,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: kGlassFrostSigma,
                  sigmaY: kGlassFrostSigma,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard
                        .withValues(alpha: 0.18),
                    borderRadius: AppRadius.chip,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: kGlassTrimOpacity),
                      width: kGlassTrimStroke,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab.icon, color: AppColors.textPrimary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        tab.label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab descriptor ─────────────────────────────────────────────────────────────

class _Tab {
  const _Tab(this.route, this.icon, this.selectedIcon, this.label);
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
