import 'dart:io';

import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/core/utils/money_format.dart';
import 'package:cinch/providers/calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarDateTransactions extends StatelessWidget {
  const CalendarDateTransactions({super.key});

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

  static String _dateLabel(DateTime date) {
    return '${_monthName(date.month)} ${date.day}';
  }

  static int _netAmount(List<Transaction> transactions) {
    var net = 0;
    for (final transaction in transactions) {
      net += transaction.type ? transaction.amount : -transaction.amount;
    }
    return net;
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = context.watch<CalendarProvider>().state;
    final transactionStorage = context.watch<TransactionStorageService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedDate = switch (calendarState) {
      Success(:final data) => data.selectedDate,
      _ => DateTime.now(),
    };

    final dayTransactions = transactionStorage
        .loadAll()
        .where(
          (t) =>
              t.time.year == selectedDate.year &&
              t.time.month == selectedDate.month &&
              t.time.day == selectedDate.day,
        )
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    final net = _netAmount(dayTransactions);
    final isPositive = net > 0;
    final isNegative = net < 0;
    final netColor = isPositive
        ? const Color(0xFF22C55E)
        : isNegative
            ? const Color(0xFFEF4444)
            : colorScheme.onSurfaceVariant;
    final netPrefix = isPositive ? '+' : isNegative ? '-' : '';
    final netBackground = isPositive
        ? const Color(0xFF22C55E).withValues(alpha: 0.12)
        : isNegative
            ? const Color(0xFFEF4444).withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHigh;
    final netBorder = isPositive
        ? const Color(0xFF22C55E).withValues(alpha: 0.35)
        : isNegative
            ? const Color(0xFFEF4444).withValues(alpha: 0.35)
            : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text.rich(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    TextSpan(
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(
                          text: '${_weekdayName(selectedDate.weekday)}, ',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: _dateLabel(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: netBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: netBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$netPrefix${formatMoneyWithCommas(net.abs().toString())}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: netColor,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: dayTransactions.isEmpty
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'No transactions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: dayTransactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tx = dayTransactions[index];
              final amount = tx.type ? tx.amount : -tx.amount;
              final isTxPositive = amount > 0;
              final isTxNegative = amount < 0;
              final amountColor = isTxPositive
                  ? const Color(0xFF22C55E)
                  : isTxNegative
                      ? const Color(0xFFEF4444)
                      : colorScheme.onSurface;
              final amountPrefix =
                  isTxPositive ? '+' : isTxNegative ? '-' : '';
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(tx.imageUrl),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 52,
                        height: 52,
                        color: colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.note.isNotEmpty ? tx.note : tx.source,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          MaterialLocalizations.of(context).formatTimeOfDay(
                            TimeOfDay.fromDateTime(tx.time),
                            alwaysUse24HourFormat: false,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$amountPrefix${formatMoneyWithCommas(amount.abs().toString())}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
