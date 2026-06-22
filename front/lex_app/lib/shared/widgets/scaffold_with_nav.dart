import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../providers/nav_bar_provider.dart';
import 'lex_glass_nav_bar.dart';

class ScaffoldWithNav extends ConsumerWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final mode = ref.watch(navBarModeProvider);

    // Com teclado aberto a nav bar some (expanded) ou o botão fica no canto
    // (compact) — em ambos os casos o clearance no fundo não é necessário e
    // causaria o ChatInputBar ficar alto acima do teclado.
    final kbOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final targetClearance =
        (mode == NavBarMode.expanded && !kbOpen) ? LexGlassNavBar.clearance : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: targetClearance),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
            builder: (context, clearance, _) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  padding: mq.padding
                      .copyWith(bottom: mq.padding.bottom + clearance),
                  viewPadding: mq.viewPadding
                      .copyWith(bottom: mq.viewPadding.bottom + clearance),
                ),
                child: child,
              );
            },
          ),
          // Positioned.fill: LexGlassNavBar always has full-screen layout bounds.
          // Pills and barrier are positioned absolutely within this space,
          // eliminating bounding-box constraints that prevented hit-testing.
          Positioned.fill(
            child: LexGlassNavBar(location: location),
          ),
        ],
      ),
    );
  }
}
