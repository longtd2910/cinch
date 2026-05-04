import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:flutter/material.dart';

class CalendarDateState {
  final bool isSelected;
  final DateTime time;
  final List<Transaction> transactions;

  CalendarDateState({required this.isSelected, required this.transactions, required this.time});
}

class CalendarDateProvider extends ChangeNotifier {
  UIState<CalendarDateState> _state = Initial();
  UIState<CalendarDateState> get state => _state;

  
}
