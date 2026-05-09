import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinch/components/calendar.dart';
import 'package:cinch/providers/calendar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (_) => CalendarProvider(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            spacing: 16,
            children: [
              Text('Calendar'),
              Calendar(),
            ],
          ),
        ),
      ),
    );
  }
}
