import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/providers/providers.dart';
import '../../../shared/widgets/otp_progress_ring.dart';

/// Main accounts screen - displays list of TOTP/HOTP accounts with live OTP codes
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final otpCodesAsync = ref.watch(otpCodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: _showFavoritesOnly ? Colors.amber : null,
            ),
            onPressed: _toggleFavorites,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'backup', child: Text('Backup')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchQuery.isNotEmpty || _showFavoritesOnly) _buildFilterBar(),

          // Accounts list
          Expanded(
            child: otpCodesAsync.when(
              data: (otpCodes) => _buildAccountsList(accounts, otpCodes),
              loading: () => _buildShimmerList(),
              error: (error, stack) => _buildErrorList(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/account/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (_searchQuery.isNotEmpty)
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search accounts...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _searchQuery = ''),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
                autofocus: true,
              ),
            ),
          if (_showFavoritesOnly)
            Chip(
              avatar: const Icon(Icons.star, size: 18),
              label: const Text('Favorites'),
              onDeleted: () => setState(() => _showFavoritesOnly = false),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(List accounts, Map<String, String> otpCodes) {
    if (accounts.isEmpty) {
      return _buildEmptyState();
    }

    var filteredAccounts = accounts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredAccounts = accounts.where((account) {
        final issuer = account.issuer.toLowerCase();
        final label = account.label.toLowerCase();
        return issuer.contains(_searchQuery.toLowerCase()) ||
            label.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply favorites filter
    if (_showFavoritesOnly) {
      filteredAccounts =
          accounts.where((account) => account.favorite).toList();
    }

    if (filteredAccounts.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredAccounts.length,
      itemBuilder: (context, index) {
        final account = filteredAccounts[index];
        final otpCode = otpCodes[account.uuid] ?? '------';
        final timeRemaining = ref
            .read(accountsProvider.notifier)
            .getTimeRemaining(account);

        return _buildAccountTile(account, otpCode, timeRemaining);
      },
    );
  }

  Widget _buildAccountTile(account, String otpCode, int timeRemaining) {
    final settings = ref.watch(settingsProvider);
    var isRevealed = !settings.tapToReveal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          if (settings.tapToReveal) {
            setState(() {
              isRevealed = !isRevealed;
            });
          }
        },
        onLongPress: () => _copyCode(otpCode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              CircleAvatar(
                backgroundColor: Colors.blue[800],
                radius: 24,
                child: Text(
                  account.issuer.isNotEmpty
                      ? account.issuer[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
                ),
              ),

              const SizedBox(width: 16),

              // Account info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          account.issuer,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (account.favorite) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                        ],
                      ],
                    ),
                    Text(
                      account.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              // OTP Code with progress ring
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _copyCode(otpCode),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: 1.0 - (timeRemaining / account.period),
                            strokeWidth: 3,
                            backgroundColor: Colors.grey[700],
                            color: timeRemaining > 15
                                ? Colors.green[400]
                                : timeRemaining > 5
                                    ? Colors.orange[400]
                                    : Colors.red[400],
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '$timeRemaining',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: timeRemaining > 15
                                ? Colors.green[400]
                                : timeRemaining > 5
                                    ? Colors.orange[400]
                                    : Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // OTP Code
                  GestureDetector(
                    onTap: () => _copyCode(otpCode),
                    onLongPress: () => _copyCode(otpCode),
                    child: Text(
                      isRevealed ? otpCode : '••••••',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isRevealed ? Colors.green[400] : Colors.grey[400],
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Copy button
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyCode(otpCode),
                    tooltip: 'Copy code',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 32,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 24),
          Text(
            'No accounts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first account',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/account/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Account'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _searchQuery = ' ';
      } else {
        _searchQuery = '';
      }
    });
  }
    });
  }

  void _toggleFavorites() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        context.push('/settings');
        break;
      case 'backup':
        context.push('/backup');
        break;
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code copied: $code'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
