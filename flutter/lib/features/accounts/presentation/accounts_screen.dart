import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../domain/account.dart';
import '../presentation/account_tile.dart';

/// Main accounts screen - displays list of TOTP/HOTP accounts
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _toggleFavorites,
            color: _showFavoritesOnly ? Colors.amber : null,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'backup', child: Text('Backup')),
              const PopupMenuItem(value: 'audit', child: Text('Audit Log')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_searchQuery.isNotEmpty || _showFavoritesOnly)
            _buildFilterBar(),
          
          // Accounts list
          Expanded(
            child: _buildAccountsList(),
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

  Widget _buildAccountsList() {
    // In production, this would use a Riverpod provider to watch accounts
    // For now, show placeholder with shimmer loading
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 5,
        itemBuilder: (context, index) => const ListTile(
          title: Text('Account Name'),
          subtitle: Text('issuer@example.com'),
        ),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _searchQuery = _searchQuery.isEmpty ? '' : _searchQuery;
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
      case 'audit':
        // Navigate to audit log
        break;
    }
  }
}
