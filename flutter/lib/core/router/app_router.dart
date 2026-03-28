import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/accounts/presentation/accounts_screen.dart';
import '../features/accounts/presentation/add_account_screen.dart';
import '../features/accounts/presentation/scan_qr_screen.dart';
import '../features/accounts/presentation/manual_entry_screen.dart';
import '../features/auth_lock/presentation/lock_screen.dart';
import '../features/auth_lock/presentation/pin_setup_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/time_offset_screen.dart';
import '../features/backup/presentation/backup_screen.dart';

/// Creates the app router with all routes configured
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/lock',
    debugLogDiagnostics: (String message) => false,
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
      
      // Edit account
      GoRoute(
        path: '/account/:id/edit',
        builder: (context, state) {
          final accountId = state.pathParameters['id']!;
          return EditAccountScreen(accountId: accountId);
        },
      ),
      
      // Account details
      GoRoute(
        path: '/account/:id/detail',
        builder: (context, state) {
          final accountId = state.pathParameters['id']!;
          return AccountDetailScreen(accountId: accountId);
        },
      ),
      
      // Settings
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Time offset settings
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

/// Simple splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'AuthVault',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screens
class EditAccountScreen extends StatelessWidget {
  final String accountId;
  const EditAccountScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Account')),
      body: Center(child: Text('Edit Account: $accountId')),
    );
  }
}

class AccountDetailScreen extends StatelessWidget {
  final String accountId;
  const AccountDetailScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Details')),
      body: Center(child: Text('Account Details: $accountId')),
    );
  }
}
