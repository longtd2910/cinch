import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/providers/calendar_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarDate extends StatelessWidget {
  const CalendarDate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarDateProvider>(
      builder:(context, value, child) {
        return Container(
          child: switch (value.state) {
            Loading() => Container(),
            Initial() => Container(),
            Error() => Container(),
            Success(:final data) => Column(
              children: [
                Text(data.time.day.toString()),
              ],
            ),
          },
        );
      },
    );
  }
}