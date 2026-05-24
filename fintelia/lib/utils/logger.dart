/// ============================================
/// FINTELIA — Logger Configuration
/// App-wide logging with the logger package
/// ============================================
library;

import 'package:logger/logger.dart';

/// App-wide logger instance.
///
/// Use `appLogger.d()`, `appLogger.i()`, `appLogger.w()`, `appLogger.e()`
/// for debug, info, warning, and error logging respectively.
final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug,
);

/// Minimal logger for production (no method traces).
final Logger prodLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 3,
    lineLength: 80,
    colors: false,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.warning,
);
