/// ============================================
/// FINTELIA — Asset Path Constants
/// ============================================
library;

/// Centralized asset path references for images, icons, and animations.
class AssetPaths {
  AssetPaths._();

  // ---- Base Paths ----
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // ---- App Branding ----
  static const String appLogo = '$_images/app_logo.png';
  static const String appLogoLight = '$_images/app_logo_light.png';
  static const String appLogoDark = '$_images/app_logo_dark.png';

  // ---- Onboarding ----
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  // ---- Placeholder / Empty States ----
  static const String emptyTransactions = '$_images/empty_transactions.png';
  static const String emptyBudgets = '$_images/empty_budgets.png';
  static const String emptyGoals = '$_images/empty_goals.png';
  static const String emptyNotifications = '$_images/empty_notifications.png';

  // ---- Category Icons ----
  static const String iconFood = '$_icons/food.svg';
  static const String iconTransport = '$_icons/transport.svg';
  static const String iconShopping = '$_icons/shopping.svg';
  static const String iconBills = '$_icons/bills.svg';
  static const String iconHealth = '$_icons/health.svg';
  static const String iconEntertainment = '$_icons/entertainment.svg';
  static const String iconEducation = '$_icons/education.svg';
  static const String iconSalary = '$_icons/salary.svg';

  // ---- Animations ----
  static const String animLoading = '$_animations/loading.json';
  static const String animSuccess = '$_animations/success.json';
  static const String animError = '$_animations/error.json';
  static const String animEmpty = '$_animations/empty.json';
}
