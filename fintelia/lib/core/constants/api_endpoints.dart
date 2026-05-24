/// ============================================
/// FINTELIA — API Endpoint Constants
/// All backend API paths in one place
/// ============================================
library;

/// Centralized API endpoint paths for the FINTELIA backend.
///
/// All paths are relative to the base URL configured in [AppConstants].
class ApiEndpoints {
  ApiEndpoints._();

  // ---- Authentication ----
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // ---- Transactions ----
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';
  static const String transactionsSummary = '/transactions/summary';
  static const String transactionsCategories = '/transactions/categories';

  // ---- Budgets ----
  static const String budgets = '/budgets';
  static String budgetById(String id) => '/budgets/$id';
  static const String budgetsOverview = '/budgets/overview';

  // ---- Goals ----
  static const String goals = '/goals';
  static String goalById(String id) => '/goals/$id';
  static String goalProgress(String id) => '/goals/$id/progress';

  // ---- Analytics ----
  static const String analyticsSpending = '/analytics/spending';
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsBehavioral = '/analytics/behavioral';
  static const String analyticsCategories = '/analytics/categories';

  // ---- AI Assistant ----
  static const String aiChat = '/ai/chat';
  static const String aiInsights = '/ai/insights';
  static const String aiAnalyze = '/ai/analyze';
  static const String aiTips = '/ai/tips';

  // ---- Notifications ----
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationPreferences = '/notifications/preferences';

  // ---- User Profile ----
  static const String userProfile = '/users/profile';
  static const String userSettings = '/users/settings';
}
