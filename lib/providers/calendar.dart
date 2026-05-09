import 'package:cinch/core/common/ui_state.dart';
import 'package:flutter/material.dart';

class CalendarState {
  final int selectedMonth;
  final int selectedYear;

  CalendarState({required this.selectedMonth, required this.selectedYear});
}

class CalendarProvider extends ChangeNotifier {
  UIState<CalendarState> _state = Initial();
  UIState<CalendarState> get state => _state;

  final List<String> _weekdays = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> get weekdays => List.unmodifiable(_weekdays);

  final List<int?> _visibleDaySkeleton = [];
  List<int?> get visibleDaySkeleton => List.unmodifiable(_visibleDaySkeleton);

  CalendarProvider() {
    final now = DateTime.now();
    _setMonthYear(now.year, now.month);
  }

  void previousMonth() {
    final currentState = _state;
    if (currentState is! Success<CalendarState>) return;
    final currentYear = currentState.data.selectedYear;
    final currentMonth = currentState.data.selectedMonth;
    if (currentMonth == 1) {
      _setMonthYear(currentYear - 1, 12);
      return;
    }
    _setMonthYear(currentYear, currentMonth - 1);
  }

  void nextMonth() {
    final currentState = _state;
    if (currentState is! Success<CalendarState>) return;
    final currentYear = currentState.data.selectedYear;
    final currentMonth = currentState.data.selectedMonth;
    if (currentMonth == 12) {
      _setMonthYear(currentYear + 1, 1);
      return;
    }
    _setMonthYear(currentYear, currentMonth + 1);
  }

  void _setMonthYear(int year, int month) {
    _visibleDaySkeleton
      ..clear()
      ..addAll(_buildVisibleDaySkeleton(year, month));
    _state = Success(
      CalendarState(
        selectedMonth: month,
        selectedYear: year,
      ),
    );
    notifyListeners();
  }

  List<int?> _buildVisibleDaySkeleton(int year, int month) {
    final cells = List<int?>.filled(42, null);
    final firstDay = DateTime(year, month, 1);
    final firstWeekdayIndex = firstDay.weekday - 1;
    final totalDays = DateTime(year, month + 1, 0).day;

    for (var day = 1; day <= totalDays; day++) {
      final cellIndex = firstWeekdayIndex + day - 1;
      if (cellIndex >= 42) break;
      cells[cellIndex] = day;
    }

    final rows = <List<int?>>[];
    for (var rowStart = 0; rowStart < cells.length; rowStart += 7) {
      final row = cells.sublist(rowStart, rowStart + 7);
      if (row.any((day) => day != null)) {
        rows.add(row);
      }
    }
    return rows.expand((row) => row).toList();
  }
}
