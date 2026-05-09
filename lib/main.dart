import 'package:cinch/core/services/image_storage_service.dart';
import 'package:cinch/core/services/location_storage_service.dart';
import 'package:cinch/core/services/money_source_storage_service.dart';
import 'package:cinch/core/services/mock_transaction_service.dart';
import 'package:cinch/core/services/tag_storage_service.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:cinch/providers/app_state.dart';
import 'package:cinch/screens/main_tabs/main_tabs_screen.dart';
import 'package:cinch/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>(TransactionStorageService.boxName);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        Provider<ImageStorageService>(create: (_) => ImageStorageService()),
        Provider<LocationStorageService>(
          create: (_) => LocationStorageService(),
        ),
        Provider<MoneySourceStorageService>(
          create: (_) => MoneySourceStorageService(),
        ),
        Provider<TagStorageService>(create: (_) => TagStorageService()),
        Provider<TransactionStorageService>(
          create: (_) => TransactionStorageService(
            Hive.box<Map>(TransactionStorageService.boxName),
          ),
        ),
        Provider<MockTransactionService>(
          create: (context) => MockTransactionService(
            context.read<TransactionStorageService>(),
            context.read<ImageStorageService>(),
          ),
        ),
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
      home: const MainTabsScreen(),
    );
  }
}
