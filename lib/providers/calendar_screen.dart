import 'package:cinch/core/common/ui_state.dart';
import 'package:flutter/material.dart';

class CalendarScreenState {}

class CalendarScreenProvider extends ChangeNotifier {
  UIState<CalendarScreenState> _state = Initial();
  UIState<CalendarScreenState> get state => _state;
}
