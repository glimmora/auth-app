import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account.dart';
import '../../../shared/widgets/otp_progress_ring.dart';

/// Account tile widget - displays OTP code with countdown ring
class AccountTile extends ConsumerStatefulWidget {
  final Account account;

  const AccountTile({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<AccountTile> {
  bool _isRevealed = false;
  String _currentCode = '------';
  String _nextCode = '------';
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _updateCode();
  }

  void _updateCode() {
    // In production, this would use the TOTP engine
    // For now, show placeholder
    setState(() {
      _remainingSeconds = 30 - (DateTime.now().second % 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              _buildIcon(),
              
              const SizedBox(width: 16),
              
              // Account info and code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Issuer and label
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.account.issuer,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (widget.account.favorite)
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      widget.account.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Code and progress
                    Row(
                      children: [
                        // OTP Code
                        Text(
                          _isRevealed ? _currentCode : '• • •   • • •',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFamily: 'JetBrainsMono',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),
                        
                        const Spacer(),
                        
                        // Progress ring
                        OTPProgressRing(
                          progress: _remainingSeconds / 30,
                          remainingSeconds: _remainingSeconds,
                        ),
                      ],
                    ),
                    
                    // Next code preview
                    if (_isRevealed) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Next: $_nextCode',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.account.iconCustom != null) {
      // Custom icon
      return CircleAvatar(
        radius: 24,
        child: ClipOval(
          child: Image.memory(
            widget.account.iconCustom!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (widget.account.iconName != null) {
      // Built-in icon
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue[700],
        child: Icon(
          _getIconData(widget.account.iconName!),
          color: Colors.white,
        ),
      );
    } else {
      // Default icon
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[700],
        child: Text(
          widget.account.issuer[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    // In production, use a proper icon library
    return Icons.security;
  }

  void _handleTap() {
    if (widget.account.tapToReveal) {
      setState(() {
        _isRevealed = !_isRevealed;
      });
    } else {
      // Copy code to clipboard
      _copyCodeToClipboard();
    }
  }

  void _handleLongPress() {
    // Show context menu
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Show QR'),
              onTap: () {
                Navigator.pop(context);
                // Show QR code
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Move to Group'),
              onTap: () {
                Navigator.pop(context);
                // Move to group
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // Delete account
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentCode));
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Auto-clear clipboard after N seconds
    Future.delayed(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }
}
