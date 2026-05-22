import 'package:cinch/components/calendar_date.dart';
import 'package:cinch/components/calendar_date_transactions.dart';
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

  Future<void> _pickMonth(BuildContext context) async {
    final calendar = context.read<CalendarProvider>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: calendar.selectedDate,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !context.mounted) return;
    _jumpToMonth(picked.year, picked.month);
    calendar.selectDate(picked);
  }

  void _jumpToMonth(int year, int month) {
    final monthDiff = (year - _visibleMonth.year) * 12 +
        (month - _visibleMonth.month);
    if (monthDiff == 0) return;
    final newPage = _currentPage + monthDiff;
    _pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendar = context.read<CalendarProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        const pageHorizontalInset = 8.0;
        final contentWidth = constraints.maxWidth.clamp(0.0, double.infinity);
        final gridWidth =
            (contentWidth - pageHorizontalInset * 2).clamp(0.0, double.infinity);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: _CalendarMonthHeader(
                monthName: _monthName(_visibleMonth.month),
                year: _visibleMonth.year,
                onTap: () => _pickMonth(context),
              ),
            ),
            SizedBox(
              height: _pageHeight(
                gridWidth,
                calendar,
                _visibleMonth.year,
                _visibleMonth.month,
              ),
              child: PageView.builder(
                controller: _pageController,
                allowImplicitScrolling: true,
                onPageChanged: (page) {
                  final monthOffset = page - _currentPage;
                  if (monthOffset == 0) return;
                  _currentPage = page;
                  setState(() {
                    _visibleMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + monthOffset,
                    );
                  });
                  calendar.moveMonths(monthOffset);
                },
                itemBuilder: (context, page) {
                  final monthDate = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + page - _currentPage,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: pageHorizontalInset,
                    ),
                    child: _MonthPage(
                      year: monthDate.year,
                      month: monthDate.month,
                      weekdays: calendar.weekdays,
                      days: calendar.visibleDaySkeletonFor(
                        monthDate.year,
                        monthDate.month,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CalendarDateTransactions(),
              ),
            ),
          ],
        );
      },
    );
  }

  double _pageHeight(
    double width,
    CalendarProvider calendar,
    int year,
    int month,
  ) {
    final weekdayHeight = width / 7 / 1.8;
    final dayHeight = width / 7 / 0.7;
    final days = calendar.visibleDaySkeletonFor(year, month);
    final rowCount = days.isEmpty ? 6 : days.length ~/ 7;
    return weekdayHeight + 8 + dayHeight * rowCount;
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

class _CalendarMonthHeader extends StatelessWidget {
  const _CalendarMonthHeader({
    required this.monthName,
    required this.year,
    required this.onTap,
  });

  final String monthName;
  final int year;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
                children: [
                  TextSpan(text: monthName),
                  TextSpan(
                    text: ' $year',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPage extends StatelessWidget {
  const _MonthPage({
    required this.year,
    required this.month,
    required this.weekdays,
    required this.days,
  });

  final int year;
  final int month;
  final List<String> weekdays;
  final List<int?> days;

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarProvider>();
    final selectedDate = calendar.selectedDate;
    final transactionStorage = context.watch<TransactionStorageService>();
    final transactions = transactionStorage.loadAll();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              childAspectRatio: 0.7,
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
                  key: ValueKey(
                    '$year-$month-$index-${transactionStorage.dataRevision}-${selectedDate.millisecondsSinceEpoch}',
                  ),
                  create: (_) => CalendarDateProvider(
                    day: days[index],
                    year: year,
                    month: month,
                    transactions: transactions,
                    selectedDate: selectedDate,
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
