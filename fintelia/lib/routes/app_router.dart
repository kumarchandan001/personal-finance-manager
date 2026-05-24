/// ============================================
/// FINTELIA — GoRouter Configuration
/// Navigation with working auth guards
/// ============================================
library;

import 'package:fintelia/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:fintelia/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:fintelia/features/auth/presentation/screens/login_screen.dart';
import 'package:fintelia/features/auth/presentation/screens/register_screen.dart';
// ---- Auth Screens ----
import 'package:fintelia/features/auth/presentation/screens/splash_screen.dart';
import 'package:fintelia/features/behavioral/presentation/screens/behavioral_screen.dart';
import 'package:fintelia/features/budgets/presentation/screens/budgets_screen.dart';
// ---- Main Feature Screens ----
import 'package:fintelia/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fintelia/features/goals/presentation/screens/goals_screen.dart';
import 'package:fintelia/features/profile/presentation/screens/profile_screen.dart';
import 'package:fintelia/features/settings/presentation/screens/settings_screen.dart';
import 'package:fintelia/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:fintelia/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:fintelia/routes/route_names.dart';
import 'package:fintelia/shared/models/transaction_model.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:fintelia/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Global navigator keys for shell route navigation.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Auth routes that don't require authentication.
const _publicRoutes = {
  RoutePaths.splash,
  RoutePaths.login,
  RoutePaths.register,
};

/// GoRouter provider for Riverpod integration.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.login,
    debugLogDiagnostics: true,

    // ---- Auth Redirect Guard ----
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final currentPath = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(currentPath);

      // Don't redirect during initial/loading state (splash handles it)
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      // Not authenticated → force to login (unless already on public route)
      if (!authState.isAuthenticated && !isPublicRoute) {
        return RoutePaths.login;
      }

      // Authenticated → redirect away from auth screens
      if (authState.isAuthenticated && isPublicRoute && currentPath != RoutePaths.splash) {
        return RoutePaths.dashboard;
      }

      return null;
    },

    routes: [
      // ---- Auth Routes (no bottom nav) ----
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ---- Main App Shell (with bottom nav) ----
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppBottomNav(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.transactions,
            name: RouteNames.transactions,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionsScreen(),
            ),
            routes: [
              GoRoute(
                path: RoutePaths.addTransaction,
                name: RouteNames.addTransaction,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  // Support edit mode via extra
                  final transaction = state.extra as TransactionModel?;
                  return AddTransactionScreen(transaction: transaction);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.analytics,
            name: RouteNames.analytics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.budgets,
            name: RouteNames.budgets,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.aiAssistant,
            name: RouteNames.aiAssistant,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiAssistantScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.behavioral,
            name: RouteNames.behavioral,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BehavioralScreen(),
            ),
          ),
        ],
      ),

      // ---- Full-Screen Routes (no bottom nav) ----
      GoRoute(
        path: RoutePaths.goals,
        name: RouteNames.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // ---- Error Page ----
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'The requested page does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
});
