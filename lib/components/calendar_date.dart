import 'dart:io';

import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/providers/calendar_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarDate extends StatelessWidget {
  const CalendarDate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarDateProvider>(
      builder: (context, value, child) {
        return switch (value.state) {
          Loading() => const SizedBox.shrink(),
          Initial() => const SizedBox.shrink(),
          Error() => const SizedBox.shrink(),
          Success(:final data) =>
            data.day == null
                ? const SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: BoxBorder.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.primary.withAlpha(100)
                      )
                    ),
                    child: Stack(
                      children: [
                        if (data.dateTransactions.isNotEmpty)
                          Positioned(
                            top: 4,
                            left: 4,
                            right: 4,
                            bottom: 16,
                            child: _TransactionImageFan(
                              transactions: data.dateTransactions,
                            ),
                          ),
                        Positioned(
                          right: 6,
                          bottom: 4,
                          child: Text(
                            '${data.day}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
        };
      },
    );
  }
}

class _TransactionImageFan extends StatelessWidget {
  final List<Transaction> transactions;

  const _TransactionImageFan({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final visible = transactions.take(3).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.6;
        final cardHeight = constraints.maxHeight * 0.85;
        final lateralOffset = cardWidth * 0.35;
        final overflowCount = transactions.length - visible.length;
        const tiltAngle = 0.22;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (visible.length >= 3)
              Transform.translate(
                offset: Offset(lateralOffset, 0),
                child: Transform.rotate(
                  angle: tiltAngle,
                  child: _ImageCard(
                    path: visible[2].imageUrl,
                    width: cardWidth * 0.7,
                    height: cardHeight * 0.7,
                  ),
                ),
              ),
            if (visible.length >= 2)
              Transform.translate(
                offset: Offset(-lateralOffset, 0),
                child: Transform.rotate(
                  angle: -tiltAngle,
                  child: _ImageCard(
                    path: visible[1].imageUrl,
                    width: cardWidth * 0.7,
                    height: cardHeight * 0.7,
                  ),
                ),
              ),
            _ImageCard(
              path: visible[0].imageUrl,
              width: cardWidth,
              height: cardHeight,
            ),
            if (overflowCount > 0)
              Positioned(
                right: 0,
                bottom: 0,
                child: _OverflowBadge(count: overflowCount),
              ),
          ],
        );
      },
    );
  }
}

class _OverflowBadge extends StatelessWidget {
  final int count;

  const _OverflowBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const _ImageCard({
    required this.path,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(6);
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: colorScheme.surfaceContainerHigh),
        ),
      ),
    );
  }
}
