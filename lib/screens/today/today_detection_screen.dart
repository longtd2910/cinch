import 'dart:io';

import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/detection_result.dart';
import 'package:cinch/providers/detection.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class TodayDetectionScreen extends StatefulWidget {
  const TodayDetectionScreen({super.key});

  @override
  State<TodayDetectionScreen> createState() => _TodayDetectionScreenState();
}

class _TodayDetectionScreenState extends State<TodayDetectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetectionProvider>().startOrResume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<DetectionProvider>(
        builder: (context, provider, _) => switch (provider.state) {
          Initial() => _IdleView(onStart: provider.startOrResume),
          Loading(:final data) => _ScanningView(data: data, provider: provider),
          Error(:final message) => _ErrorView(
              message: message,
              onRetry: provider.startOrResume,
            ),
          Success(:final data) => _ScanningView(data: data, provider: provider),
        },
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: cs.primary),
          Text(
            'Tap to scan today\'s photos',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          FilledButton.tonal(
            onPressed: onStart,
            child: const Text('Start Detection'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(message, textAlign: TextAlign.center),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanningView extends StatelessWidget {
  const _ScanningView({required this.data, required this.provider});

  final DetectionState? data;
  final DetectionProvider provider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final results = data?.results ?? [];
    final total = data?.totalPhotos ?? 0;
    final processed = data?.processedPhotos ?? 0;
    final isComplete = data?.isComplete ?? false;
    final progress = total > 0 ? processed / total : 0.0;

    return Column(
      children: [
        _Header(
          total: total,
          processed: processed,
          found: results.length,
          progress: progress,
          isComplete: isComplete,
        ),
        if (!isComplete)
          LinearProgressIndicator(
            value: total > 0 ? progress : null,
            minHeight: 3,
            color: cs.primary,
            backgroundColor: cs.surfaceContainerHigh,
          ),
        Expanded(
          child: results.isEmpty
              ? _EmptyState(isComplete: isComplete, total: total)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) => _DetectionTile(
                    result: results[index],
                    onApprove: () => _onApprove(context, index),
                    onDismiss: () => provider.dismissResult(index),
                  ),
                ),
        ),
      ],
    );
  }

  void _onApprove(BuildContext context, int index) {
    provider.removeResult(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction approved'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.processed,
    required this.found,
    required this.progress,
    required this.isComplete,
  });

  final int total;
  final int processed;
  final int found;
  final double progress;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text('Today', style: tt.headlineMedium),
          const Spacer(),
          if (!isComplete && total > 0)
            Text(
              '$processed/$total',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          if (isComplete && found > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$found found',
                style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          if (isComplete && found == 0)
            Text(
              'No transactions',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isComplete, required this.total});

  final bool isComplete;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(
            isComplete ? Icons.check_circle_outline : Icons.search,
            size: 40,
            color: cs.onSurfaceVariant,
          ),
          Text(
            isComplete
                ? (total == 0
                    ? 'No photos today'
                    : 'All clear — no transactions found')
                : 'Scanning photos...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetectionTile extends StatelessWidget {
  const _DetectionTile({
    required this.result,
    required this.onApprove,
    required this.onDismiss,
  });

  final DetectionResult result;
  final VoidCallback onApprove;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final time = result.asset.createDateTime;
    final confidence = (result.confidence * 100).toInt();

    return Dismissible(
      key: ValueKey(result.asset.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.close, color: cs.error),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _AssetThumbnail(asset: result.asset),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$confidence%',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDate(time),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onApprove,
              icon: Icon(Icons.check_circle, color: cs.primary),
              iconSize: 28,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _AssetThumbnail extends StatefulWidget {
  const _AssetThumbnail({required this.asset});

  final AssetEntity asset;

  @override
  State<_AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<_AssetThumbnail> {
  File? _file;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final file = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(200, 200),
    );
    if (!mounted || file == null) return;
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/cinch_thumb_${widget.asset.id.hashCode}.jpg',
    );
    await tempFile.writeAsBytes(file);
    if (mounted) setState(() => _file = tempFile);
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) {
      return Container(color: Theme.of(context).colorScheme.surfaceContainerHigh);
    }
    return Image.file(_file!, fit: BoxFit.cover);
  }
}
