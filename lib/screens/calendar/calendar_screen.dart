import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinch/components/calendar.dart';
import 'package:cinch/components/calendar_day_timeline.dart';
import 'package:cinch/providers/calendar.dart';
import 'package:cinch/providers/calendar_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CalendarScreenProvider()),
          ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Consumer<CalendarScreenProvider>(
                builder: (context, layout, _) {
                  return Row(
                    children: [
                      Text(
                        'Calendar',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      SegmentedButton<CalendarLayoutMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment<CalendarLayoutMode>(
                            value: CalendarLayoutMode.calendar,
                            label: Text('Calendar'),
                            icon: Icon(Icons.calendar_view_month, size: 18),
                          ),
                          ButtonSegment<CalendarLayoutMode>(
                            value: CalendarLayoutMode.day,
                            label: Text('Day'),
                            icon: Icon(Icons.photo_library_outlined, size: 18),
                          ),
                        ],
                        selected: {layout.layoutMode},
                        onSelectionChanged: (Set<CalendarLayoutMode> next) {
                          layout.setLayoutMode(next.first);
                        },
                      ),
                    ],
                  );
                },
              ),
              Expanded(
                child: Consumer<CalendarScreenProvider>(
                  builder: (context, layout, _) {
                    return switch (layout.layoutMode) {
                      CalendarLayoutMode.calendar => const SingleChildScrollView(
                          child: Calendar(),
                        ),
                      CalendarLayoutMode.day => const CalendarDayTimeline(),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
