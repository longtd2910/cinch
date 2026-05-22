import 'package:cinch/core/common/ui_state.dart';
import 'package:flutter/material.dart';

class CalendarState {
  final int selectedMonth;
  final int selectedYear;
  final DateTime selectedDate;

  CalendarState({
    required this.selectedMonth,
    required this.selectedYear,
    required this.selectedDate,
  });
}

class CalendarProvider extends ChangeNotifier {
  UIState<CalendarState> _state = Initial();
  UIState<CalendarState> get state => _state;

  final List<String> _weekdays = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> get weekdays => List.unmodifiable(_weekdays);

  final List<int?> _visibleDaySkeleton = [];
  List<int?> get visibleDaySkeleton => List.unmodifiable(_visibleDaySkeleton);

  DateTime _selectedDate = DateTime.now();

  CalendarProvider() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _setMonthYear(now.year, now.month);
  }

  DateTime get selectedDate => _selectedDate;

  void selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (_selectedDate == normalized) return;
    _selectedDate = normalized;
    final currentState = _state;
    if (currentState is Success<CalendarState>) {
      _state = Success(
        CalendarState(
          selectedMonth: currentState.data.selectedMonth,
          selectedYear: currentState.data.selectedYear,
          selectedDate: normalized,
        ),
      );
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  void previousMonth() {
    moveMonths(-1);
  }

  void nextMonth() {
    moveMonths(1);
  }

  void moveMonths(int monthOffset) {
    final currentState = _state;
    if (currentState is! Success<CalendarState>) return;
    if (monthOffset == 0) return;
    final selectedDate = DateTime(
      currentState.data.selectedYear,
      currentState.data.selectedMonth + monthOffset,
    );
    _setMonthYear(selectedDate.year, selectedDate.month);
  }

  List<int?> visibleDaySkeletonFor(int year, int month) {
    return _buildVisibleDaySkeleton(year, month);
  }

  void _setMonthYear(int year, int month) {
    _visibleDaySkeleton
      ..clear()
      ..addAll(_buildVisibleDaySkeleton(year, month));
    _state = Success(
      CalendarState(
        selectedMonth: month,
        selectedYear: year,
        selectedDate: _selectedDate,
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
