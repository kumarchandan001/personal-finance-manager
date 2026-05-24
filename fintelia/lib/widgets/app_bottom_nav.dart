/// ============================================
/// FINTELIA — Bottom Navigation Bar
/// Animated bottom nav with ShellRoute
/// ============================================
library;

import 'package:fintelia/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom bottom navigation bar for the main app shell.
///
/// Integrates with GoRouter's [ShellRoute] to provide persistent
/// navigation across the five main tabs.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.child});

  final Widget child;

  /// Determine the current tab index from the route location.
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.dashboard)) return 0;
    if (location.startsWith(RoutePaths.transactions)) return 1;
    if (location.startsWith(RoutePaths.analytics)) return 2;
    if (location.startsWith(RoutePaths.budgets)) return 3;
    if (location.startsWith(RoutePaths.aiAssistant)) return 4;
    if (location.startsWith(RoutePaths.behavioral)) return 5;
    return 0;
  }

  /// Navigate to the tab at [index].
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RoutePaths.dashboard);
      case 1:
        context.go(RoutePaths.transactions);
      case 2:
        context.go(RoutePaths.analytics);
      case 3:
        context.go(RoutePaths.budgets);
      case 4:
        context.go(RoutePaths.aiAssistant);
      case 5:
        context.go(RoutePaths.behavioral);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology_rounded),
            label: 'Behavioral',
          ),
        ],
      ),
    );
  }
}
