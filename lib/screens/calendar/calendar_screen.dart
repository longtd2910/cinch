import 'package:cinch/core/services/image_storage_service.dart';
import 'package:cinch/core/services/location_storage_service.dart';
import 'package:cinch/core/services/money_source_storage_service.dart';
import 'package:cinch/core/services/tag_storage_service.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import 'package:cinch/screens/add_transaction/add_transaction_screen.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ImageStorageService()),
        Provider(create: (_) => LocationStorageService()),
        Provider(create: (_) => MoneySourceStorageService()),
        Provider(create: (_) => TagStorageService()),
        Provider(
          create: (_) => TransactionStorageService(
            Hive.box<Map>(TransactionStorageService.boxName),
          ),
        ),
      ],
      builder: (context, child) => Scaffold(
        floatingActionButton: GestureDetector(
          onLongPress: () => openAddTransactionScreen(context, takePhoto: true),
          child: FloatingActionButton.large(
            onPressed: () => openAddTransactionScreen(context),
          ),
        ),
        body: SafeArea(child: Column(children: [Text('data')])),
      ),
    );
  }
}
