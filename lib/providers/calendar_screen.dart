import 'package:flutter/material.dart';

enum CalendarLayoutMode { calendar, day }

class CalendarScreenProvider extends ChangeNotifier {
  CalendarLayoutMode _layoutMode = CalendarLayoutMode.calendar;
  CalendarLayoutMode get layoutMode => _layoutMode;

  void setLayoutMode(CalendarLayoutMode mode) {
    if (_layoutMode == mode) return;
    _layoutMode = mode;
    notifyListeners();
  }
}
