import 'package:cinch/components/calendar_date.dart';
import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/providers/calendar.dart';
import 'package:cinch/providers/calendar_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const _initialPage = 12000;

  late final PageController _pageController;
  late DateTime _visibleMonth;
  var _currentPage = _initialPage;
  var _hasVisibleMonth = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasVisibleMonth) return;
    final state = context.read<CalendarProvider>().state;
    _visibleMonth = switch (state) {
      Success(:final data) => DateTime(data.selectedYear, data.selectedMonth),
      _ => DateTime.now(),
    };
    _hasVisibleMonth = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendar = context.read<CalendarProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        const pageHorizontalInset = 8.0;
        final contentWidth = constraints.maxWidth.clamp(0.0, double.infinity);
        final gridWidth = (contentWidth - pageHorizontalInset * 2).clamp(0.0, double.infinity);
        return SizedBox(
          height: _pageHeight(gridWidth),
          child: PageView.builder(
            controller: _pageController,
            allowImplicitScrolling: true,
            onPageChanged: (page) {
              final monthOffset = page - _currentPage;
              if (monthOffset == 0) return;
              _currentPage = page;
              _visibleMonth = DateTime(
                _visibleMonth.year,
                _visibleMonth.month + monthOffset,
              );
              calendar.moveMonths(monthOffset);
            },
            itemBuilder: (context, page) {
              final monthDate = DateTime(
                _visibleMonth.year,
                _visibleMonth.month + page - _currentPage,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: pageHorizontalInset),
                child: _MonthPage(
                  year: monthDate.year,
                  month: monthDate.month,
                  monthName: _monthName(monthDate.month),
                  weekdays: calendar.weekdays,
                  days: calendar.visibleDaySkeletonFor(
                    monthDate.year,
                    monthDate.month,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _pageHeight(double width) {
    final weekdayHeight = width / 7 / 1.8;
    final dayHeight = width / 7 / 0.6;
    return 48 + weekdayHeight + 8 + dayHeight * 6;
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

class _MonthPage extends StatelessWidget {
  const _MonthPage({
    required this.year,
    required this.month,
    required this.monthName,
    required this.weekdays,
    required this.days,
  });

  final int year;
  final int month;
  final String monthName;
  final List<String> weekdays;
  final List<int?> days;

  @override
  Widget build(BuildContext context) {
    final transactions = context.read<TransactionStorageService>().loadAll();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '$monthName $year',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weekdays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                weekdays[index],
                style: Theme.of(context).textTheme.labelMedium,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              final isLastColumn = (index + 1) % 7 == 0;
              final isLastRow = index >= days.length - 7;
              final borderSide = BorderSide(
                color: Theme.of(context).colorScheme.primaryContainer,
              );
              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: isLastColumn ? BorderSide.none : borderSide,
                    bottom: isLastRow ? BorderSide.none : borderSide,
                  ),
                ),
                child: ChangeNotifierProvider(
                  key: ValueKey('$year-$month-$index'),
                  create: (_) => CalendarDateProvider(
                    day: days[index],
                    year: year,
                    month: month,
                    transactions: transactions,
                  ),
                  child: const CalendarDate(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
