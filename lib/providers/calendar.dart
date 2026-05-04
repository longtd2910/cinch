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

  
}
