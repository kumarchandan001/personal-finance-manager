/// ============================================
/// FINTELIA — Connectivity Provider
/// Network connectivity state management
/// ============================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity status.
enum ConnectivityStatus { connected, disconnected, unknown }

/// Monitors network connectivity state.
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.unknown) {
    _init();
  }

  void _init() {
    // TODO(phase1): Use connectivity_plus package to monitor real connectivity
    // For now, assume connected
    state = ConnectivityStatus.connected;
  }

  /// Whether the device is currently online.
  bool get isConnected => state == ConnectivityStatus.connected;

  /// Update connectivity state (called by platform listener).
  void updateStatus(ConnectivityStatus status) => state = status;
}

/// Global connectivity provider.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});
