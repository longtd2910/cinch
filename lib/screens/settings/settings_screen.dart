import 'package:cinch/core/services/mock_transaction_service.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _mockDays = 30;

  bool _isCreatingMockTransactions = false;
  bool _isDeletingTransactions = false;

  Future<void> _createMockTransactions() async {
    if (_isCreatingMockTransactions || _isDeletingTransactions) return;

    setState(() {
      _isCreatingMockTransactions = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    var message = 'Failed to create mock transactions';
    try {
      final createdCount = await context
          .read<MockTransactionService>()
          .createForEmptyPastDays(_mockDays);
      message = 'Created $createdCount mock transactions';
    } catch (_) {
      message = 'Failed to create mock transactions';
    }

    if (!mounted) return;
    setState(() {
      _isCreatingMockTransactions = false;
    });

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteAllTransactions() async {
    if (_isCreatingMockTransactions || _isDeletingTransactions) return;

    setState(() {
      _isDeletingTransactions = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    var message = 'Failed to delete transactions';
    try {
      final deletedCount = await context
          .read<TransactionStorageService>()
          .clear();
      message = 'Deleted $deletedCount transactions';
    } catch (_) {
      message = 'Failed to delete transactions';
    }

    if (!mounted) return;
    setState(() {
      _isDeletingTransactions = false;
    });

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            FilledButton(
              onPressed: _isCreatingMockTransactions || _isDeletingTransactions
                  ? null
                  : _createMockTransactions,
              child: Text(
                _isCreatingMockTransactions
                    ? 'Creating mock transactions...'
                    : 'Create mock transactions for past $_mockDays days',
              ),
            ),
            Align(
              child: TextButton(
                onPressed:
                    _isCreatingMockTransactions || _isDeletingTransactions
                    ? null
                    : _deleteAllTransactions,
                child: Text(
                  _isDeletingTransactions
                      ? 'Deleting transactions...'
                      : 'Delete all transactions',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
