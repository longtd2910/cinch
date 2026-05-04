import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:cinch/providers/app_state.dart';
import 'package:cinch/screens/calendar/calendar_screen.dart';
import 'package:cinch/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>(TransactionStorageService.boxName);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.obsidian,
      themeMode: ThemeMode.dark,
      home: const CalendarScreen(),
    );
  }
}
