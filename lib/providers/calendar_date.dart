import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:flutter/material.dart';

class CalendarDateState {
  final int? day;
  final int year;
  final int month;
  final bool isRealDate;
  final bool isToday;
  final bool isSelected;
  final List<Transaction> dateTransactions;
  final int netAmount;

  CalendarDateState({
    required this.day,
    required this.year,
    required this.month,
    required this.isRealDate,
    required this.isToday,
    required this.isSelected,
    required this.dateTransactions,
    required this.netAmount,
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
    required DateTime selectedDate,
  }) {
    final dateTransactions =
        _get_date_transactions(day, month, year, transactions);
    final now = DateTime.now();
    final isToday = day != null &&
        year == now.year &&
        month == now.month &&
        day == now.day;
    final isSelected = day != null &&
        year == selectedDate.year &&
        month == selectedDate.month &&
        day == selectedDate.day;
    _state = Success(
      CalendarDateState(
        day: day,
        year: year,
        month: month,
        isRealDate: day != null,
        isToday: isToday,
        isSelected: isSelected,
        dateTransactions: dateTransactions,
        netAmount: _netAmount(dateTransactions),
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

  int _netAmount(List<Transaction> transactions) {
    var net = 0;
    for (final transaction in transactions) {
      net += transaction.type ? transaction.amount : -transaction.amount;
    }
    return net;
  }
}
