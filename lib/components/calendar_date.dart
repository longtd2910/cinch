import 'dart:io';
import 'dart:math' as math;

import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/core/utils/money_format.dart';
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
                : DecoratedBox(
                    decoration: data.isToday
                        ? BoxDecoration(
                            color: const Color(0xAAD9BC84),
                            border: Border.all(
                              color: const Color(0xFFD9BC84),
                              width: 2,
                            ),
                          )
                        : const BoxDecoration(),
                    child: Stack(
                      children: [
                        if (data.dateTransactions.isNotEmpty)
                          Positioned(
                            top: 4,
                            left: 4,
                            right: 4,
                            bottom: 22,
                            child: _TransactionImageFan(
                              transactions: data.dateTransactions,
                            ),
                          ),
                        if (data.dateTransactions.isNotEmpty)
                          Positioned(
                            left: 4,
                            bottom: 4,
                            child: _DayTotalBadge(amount: data.netAmount),
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

class _DayTotalBadge extends StatelessWidget {
  final int amount;

  const _DayTotalBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = amount > 0;
    final isNegative = amount < 0;
    final foreground = isPositive
        ? const Color(0xFF22C55E)
        : isNegative
            ? const Color(0xFFEF4444)
            : colorScheme.onSurfaceVariant;
    final prefix = isPositive ? '+' : isNegative ? '-' : '';
    return Text(
      '$prefix${formatMoneyCompact(amount)}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
            fontSize: 9,
            height: 1.1,
          ),
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
        final cardWidth = math.min(
          constraints.maxWidth * 0.7,
          40.0,
        ).clamp(22.0, constraints.maxWidth);
        final cardHeight = math.min(
          constraints.maxHeight * 0.8,
          54.0,
        ).clamp(30.0, constraints.maxHeight);
        final lateralOffset = cardWidth * 0.35;
        final overflowCount = transactions.length - visible.length;
        const tiltAngle = 0.22;
        final fanWidth = visible.length >= 2
            ? (cardWidth + 2 * lateralOffset).clamp(cardWidth, constraints.maxWidth)
            : cardWidth;
        final fanHeight = (cardHeight * 1.12).clamp(cardHeight, constraints.maxHeight);

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: fanWidth,
            height: fanHeight,
            child: Stack(
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
            ),
          ),
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
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        elevation: 1,
        color: const Color(0xFFE9E2D8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: colorScheme.surfaceContainerHigh),
            ),
          ),
        ),
      ),
    );
  }
}
