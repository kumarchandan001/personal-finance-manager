/// ============================================
/// FINTELIA — Application Entry Point
/// ============================================
library;

import 'package:fintelia/core/constants/app_constants.dart';
import 'package:fintelia/firebase_options.dart';
import 'package:fintelia/routes/app_router.dart';
import 'package:fintelia/shared/providers/theme_provider.dart';
import 'package:fintelia/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether Firebase was successfully initialized.
/// Used to conditionally enable Firebase-dependent features.
bool firebaseInitialized = false;

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for Android-first experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase (optional — app works without it)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    firebaseInitialized = false;
    debugPrint('⚠️ Firebase init skipped: $e');
    debugPrint('   App will use API-only authentication');
  }

  runApp(
    const ProviderScope(
      child: FINTELIAApp(),
    ),
  );
}

/// Root application widget.
class FINTELIAApp extends ConsumerWidget {
  const FINTELIAApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
