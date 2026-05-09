import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/providers/calendar.dart';
import 'package:cinch/components/calendar_date.dart';
import 'package:cinch/providers/calendar_date.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, value, child) {
        return switch (value.state) {
          Loading() => const SizedBox.shrink(),
          Initial() => const SizedBox.shrink(),
          Error() => const SizedBox.shrink(),
          Success(:final data) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: value.previousMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        '${_monthName(data.selectedMonth)} ${data.selectedYear}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: value.nextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: value.weekdays.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.8,
                  ),
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        value.weekdays[index],
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: value.visibleDaySkeleton.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final transactions =
                        context.read<TransactionStorageService>().loadAll();
                    return ChangeNotifierProvider(
                      key: ValueKey('${data.selectedYear}-${data.selectedMonth}-$index'),
                      create: (_) => CalendarDateProvider(
                        day: value.visibleDaySkeleton[index],
                        year: data.selectedYear,
                        month: data.selectedMonth,
                        transactions: transactions,
                      ),
                      child: const CalendarDate(),
                    );
                  },
                ),
              ],
            ),
        };
      },
    );
  }

  String _monthName(int month) {
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
}