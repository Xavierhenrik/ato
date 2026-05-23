import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _NavTab(route: '/tutor',     icon: Icons.smart_toy_outlined,  label: 'Tutor'),
    _NavTab(route: '/anotacoes', icon: Icons.bookmark_outline,    label: 'Anotações'),
    _NavTab(route: '/dashboard', icon: Icons.home_outlined,       label: 'Início'),
    _NavTab(route: '/perfil',    icon: Icons.person_outline,      label: 'Perfil'),
  ];

  int _activeIndex(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.route));
    return idx == -1 ? 2 : idx; // default: Início
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _activeIndex(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: (i) => context.go(_tabs[i].route),
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.route,
    required this.icon,
    required this.label,
  });
  final String route;
  final IconData icon;
  final String label;
}
