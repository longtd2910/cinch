import 'package:cinch/core/services/mock_transaction_service.dart';
import 'package:cinch/core/services/scan_schedule_service.dart';
import 'package:cinch/core/services/transaction_classifier.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/providers/detection.dart';
import 'package:cinch/screens/detection/detection_results_screen.dart';
import 'package:cinch/screens/detection/photo_permission_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
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
  bool _isDetecting = false;
  DateTime _detectionDate = DateTime.now();

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

  Future<void> _pickDetectionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _detectionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _detectionDate = picked);
    }
  }

  Future<bool> _ensurePhotoPermission() async {
    final ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    if (ps.isAuth) return true;

    if (!mounted) return false;
    final granted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PhotoPermissionScreen(),
      ),
    );
    return granted == true;
  }

  Future<void> _detectTransactions() async {
    if (_isDetecting) return;

    setState(() => _isDetecting = true);

    final hasPermission = await _ensurePhotoPermission();
    if (!hasPermission) {
      if (mounted) setState(() => _isDetecting = false);
      return;
    }

    final classifier = TransactionClassifier();
    final provider = DetectionProvider(classifier);
    provider.scanForDate(_detectionDate);

    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const DetectionResultsScreen(),
        ),
      ),
    );

    if (mounted) setState(() => _isDetecting = false);
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
            Row(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _isDetecting ? null : _pickDetectionDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    '${_detectionDate.day}/${_detectionDate.month}/${_detectionDate.year}',
                  ),
                ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _isDetecting ? null : _detectTransactions,
                    child: Text(
                      _isDetecting ? 'Detecting...' : 'Detect transactions',
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Daily scan',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Consumer<ScanScheduleService>(
              builder: (context, schedule, _) => Column(
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Auto-detect transactions daily',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: schedule.enabled,
                        onChanged: (v) => schedule.setEnabled(v),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Scan time',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: schedule.scheduledTime,
                          );
                          if (picked != null) {
                            schedule.setTime(picked);
                          }
                        },
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(schedule.scheduledTime.format(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
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
