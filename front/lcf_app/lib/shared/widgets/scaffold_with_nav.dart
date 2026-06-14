import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../providers/nav_bar_provider.dart';
import 'lcf_glass_nav_bar.dart';

class ScaffoldWithNav extends ConsumerStatefulWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends ConsumerState<ScaffoldWithNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _compactCtrl;

  @override
  void initState() {
    super.initState();
    _compactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _compactCtrl.dispose();
    super.dispose();
  }

  /// Constrói o Positioned da barra interpolando entre pílula expandida e
  /// meio-círculo flutuante na borda direita.
  ///
  /// t = 0  →  pílula completa centralizada na base
  /// t = 1  →  círculo de diâmetro [barHeight] posicionado meio a fio na direita
  Widget _buildNavPositioned(
    double t,
    double screenWidth,
    String location,
  ) {
    const bh = LcfGlassNavBar.barHeight; // 68
    const bm = LcfGlassNavBar.barMargin; // 8

    final expandedWidth = screenWidth - 2 * bm;

    // right: começa em bm (margem esquerda de [bm] contabilizada pelo Positioned),
    //        vai até -bh/2 (metade do círculo fora da tela).
    final right = lerpDouble(bm, -bh / 2, t)!;

    // width: encolhe da pílula até o diâmetro do círculo.
    final width = lerpDouble(expandedWidth, bh, t)!;

    return Positioned(
      right: right,
      bottom: 0,
      width: width,
      child: LcfGlassNavBar(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final dialOpen = ref.watch(navDialOpenProvider);

    ref.listen<NavBarMode>(navBarModeProvider, (_, next) {
      if (next == NavBarMode.compact) {
        _compactCtrl.forward();
      } else {
        _compactCtrl.reverse();
      }
    });

    return Scaffold(
      // false: impede que o Scaffold redimensione quando o teclado abre.
      // O meio-círculo compacto fica fixo na borda direita, sem flutuar sobre
      // o teclado. As telas filhas gerenciam seu próprio inset independentemente.
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          return AnimatedBuilder(
            animation: _compactCtrl,
            builder: (context, _) {
              final t = CurvedAnimation(
                parent: _compactCtrl,
                curve: Curves.easeInOutCubic,
              ).value;

              return Stack(
                // Permite que o meio-círculo compacto pinte além da borda
                // direita da tela (right = -bh/2).
                clipBehavior: Clip.none,
                children: [
                  child,
                  // Barrier fecha speed-dial ao tocar fora da nav bar.
                  if (dialOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () =>
                            ref.read(navDialOpenProvider.notifier).state =
                                false,
                      ),
                    ),
                  _buildNavPositioned(t, screenWidth, location),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget get child => widget.child;
}
