import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:flutter/material.dart';

class CalendarDateState {
  final int? day;
  final int month;
  final bool isRealDate;
  final List<Transaction> dateTransactions;

  CalendarDateState({
    required this.day,
    required this.month,
    required this.isRealDate,
    required this.dateTransactions,
  });
}

class CalendarDateProvider extends ChangeNotifier {
  UIState<CalendarDateState> _state = Initial();
  UIState<CalendarDateState> get state => _state;

  CalendarDateProvider({
    required int? day,
    required int year,
    required int month,
    required List<Transaction> transactions,
  }) {
    final dateTransactions =
        _get_date_transactions(day, month, year, transactions);
    _state = Success(
      CalendarDateState(
        day: day,
        month: month,
        isRealDate: day != null,
        dateTransactions: dateTransactions,
      ),
    );
  }

  List<Transaction> _get_date_transactions(
    int? day,
    int month,
    int year,
    List<Transaction> transactions,
  ) {
    if (day == null) return const [];
    return transactions.where((transaction) {
      final time = transaction.time;
      return time.year == year && time.month == month && time.day == day;
    }).toList();
  }
}
