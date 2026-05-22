import 'package:cinch/components/calendar.dart';
import 'package:cinch/providers/calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (_) => CalendarProvider(),
        child: const Calendar(),
      ),
    );
  }
}
