import 'package:flutter/material.dart';
import 'package:navigation_bar_m3e/navigation_bar_m3e.dart';

import 'package:cinch/screens/add_transaction/add_transaction_screen.dart';
import 'package:cinch/screens/calendar/calendar_screen.dart';
import 'package:cinch/screens/settings/settings_screen.dart';
import 'package:cinch/screens/transactions/transactions_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  static const int _calendarNavIndex = 0;
  static const int _transactionsNavIndex = 1;
  static const int _addNavIndex = 2;
  static const int _settingsNavIndex = 3;

  int _currentNavIndex = _calendarNavIndex;

  static const List<Widget> _screens = <Widget>[
    CalendarScreen(),
    TransactionsScreen(),
    SettingsScreen(),
  ];

  int get _screenIndex => switch (_currentNavIndex) {
        _calendarNavIndex => 0,
        _transactionsNavIndex => 1,
        _settingsNavIndex => 2,
        _ => 0,
      };

  Future<void> _onDestinationSelected(int index) async {
    if (index == _addNavIndex) {
      await openAddTransactionScreen(context);
      return;
    }
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
  }

  Future<void> _onAddLongPress() async {
    await openAddTransactionScreen(context, takePhoto: true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final addIcon = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: _onAddLongPress,
      child: Icon(Icons.add_circle, color: cs.primaryContainer, size: 32),
    );

    final destinations = <NavigationDestinationM3E>[
      const NavigationDestinationM3E(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Calendar',
      ),
      const NavigationDestinationM3E(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Transactions',
      ),
      NavigationDestinationM3E(
        icon: addIcon,
        selectedIcon: addIcon,
        label: 'Add',
        semanticLabel: 'Add transaction',
      ),
      const NavigationDestinationM3E(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _screenIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarM3E(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: destinations,
        labelBehavior: NavBarM3ELabelBehavior.alwaysShow,
        indicatorStyle: NavBarM3EIndicatorStyle.pill,
        size: NavBarM3ESize.medium,
        shapeFamily: NavBarM3EShapeFamily.round,
      ),
    );
  }
}
