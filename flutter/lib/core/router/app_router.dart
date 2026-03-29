import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/accounts/presentation/add_account_screen.dart';
import '../../features/accounts/presentation/scan_qr_screen.dart';
import '../../features/accounts/presentation/manual_entry_screen.dart';
import '../../features/auth_lock/presentation/lock_screen.dart';
import '../../features/auth_lock/presentation/pin_setup_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/time_offset_screen.dart';
import '../../features/backup/presentation/backup_screen.dart';

/// Creates the app router with all routes configured
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/lock',
    debugLogDiagnostics: false,
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Lock screen
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),

      // PIN setup
      GoRoute(
        path: '/lock/setup',
        builder: (context, state) => const PinSetupScreen(),
      ),

      // Main accounts screen
      GoRoute(
        path: '/home',
        builder: (context, state) => const AccountsScreen(),
      ),

      // Add account
      GoRoute(
        path: '/account/add',
        builder: (context, state) => const AddAccountScreen(),
      ),

      // Scan QR
      GoRoute(
        path: '/account/add/scan',
        builder: (context, state) => const ScanQRScreen(),
      ),

      // Manual entry
      GoRoute(
        path: '/account/add/manual',
        builder: (context, state) => const ManualEntryScreen(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Time offset
      GoRoute(
        path: '/settings/time-offset',
        builder: (context, state) => const TimeOffsetScreen(),
      ),

      // Backup
      GoRoute(
        path: '/backup',
        builder: (context, state) => const BackupScreen(),
      ),
    ],
  );
}

/// Splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
