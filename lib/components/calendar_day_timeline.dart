import 'dart:io';

import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/core/utils/money_format.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarDayTimeline extends StatelessWidget {
  const CalendarDayTimeline({super.key});

  static List<MapEntry<DateTime, List<Transaction>>> _groupByDay(
    List<Transaction> transactions,
  ) {
    final map = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final d = DateTime(t.time.year, t.time.month, t.time.day);
      map.putIfAbsent(d, () => []).add(t);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.time.compareTo(a.time));
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries;
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  static String _monthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  static String _dayHeader(DateTime date) {
    return '${_weekdayName(date.weekday)}, ${_monthName(date.month)} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final transactions = context.read<TransactionStorageService>().loadAll();
    final groups = _groupByDay(transactions);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (groups.isEmpty) {
      return Center(
        child: Text(
          'No transactions yet',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final entry = groups[index];
        final date = entry.key;
        final dayTx = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 0 : 20,
                bottom: 10,
              ),
              child: Text(
                _dayHeader(date),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1,
              ),
              itemCount: dayTx.length,
              itemBuilder: (context, i) {
                final tx = dayTx[i];
                final path = tx.imageUrl;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: colorScheme.surfaceContainerHigh,
                        ),
                      ),
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            formatMoneyWithCommas(tx.amount.toString()),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
