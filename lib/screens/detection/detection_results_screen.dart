import 'dart:io';

import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/detection_result.dart';
import 'package:cinch/providers/detection.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class DetectionResultsScreen extends StatelessWidget {
  const DetectionResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detected Transactions')),
      body: SafeArea(
        child: Consumer<DetectionProvider>(
          builder: (context, provider, _) => switch (provider.state) {
            Initial() => const Center(child: Text('Starting detection...')),
            Loading(:final data) => _LoadingView(data: data),
            Error(:final message) => _ErrorView(message: message),
            Success(:final data) => _ResultsView(data: data),
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.data});

  final DetectionState? data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = data?.totalPhotos ?? 0;
    final processed = data?.processedPhotos ?? 0;
    final progress = total > 0 ? processed / total : 0.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: total > 0 ? progress : null,
                strokeWidth: 6,
                color: cs.primary,
              ),
            ),
            Text(
              total > 0
                  ? 'Scanning $processed / $total photos...'
                  : 'Loading photos...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.data});

  final DetectionState data;

  @override
  Widget build(BuildContext context) {
    if (data.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              Text(
                data.totalPhotos == 0
                    ? 'No photos found for today'
                    : 'No transactions detected in ${data.totalPhotos} photos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${data.results.length} transaction${data.results.length == 1 ? '' : 's'} detected from ${data.totalPhotos} photos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _DetectionCard(
              result: data.results[index],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetectionCard extends StatelessWidget {
  const _DetectionCard({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final confidence = (result.confidence * 100).toStringAsFixed(1);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: _AssetImage(asset: result.asset),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.receipt_long, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Confidence: $confidence%',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                Text(
                  _formatTime(result.asset.createDateTime),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _AssetImage extends StatefulWidget {
  const _AssetImage({required this.asset});

  final AssetEntity asset;

  @override
  State<_AssetImage> createState() => _AssetImageState();
}

class _AssetImageState extends State<_AssetImage> {
  File? _file;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    final file = await widget.asset.file;
    if (mounted && file != null) {
      setState(() => _file = file);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Image.file(
      _file!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
