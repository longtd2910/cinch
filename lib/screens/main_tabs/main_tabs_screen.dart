import 'package:flutter/material.dart';

import 'package:cinch/screens/add_transaction/add_transaction_screen.dart';
import 'package:cinch/screens/calendar/calendar_day_screen.dart';
import 'package:cinch/screens/calendar/calendar_screen.dart';
import 'package:cinch/screens/settings/settings_screen.dart';
import 'package:cinch/screens/transactions/transactions_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  static const _addNavIndex = 2;

  int _currentNavIndex = 0;

  static const List<Widget> _screens = <Widget>[
    CalendarScreen(),
    TransactionsScreen(),
    CalendarDayScreen(),
    SettingsScreen(),
  ];

  int get _screenIndex => switch (_currentNavIndex) {
    0 => 0,
    1 => 1,
    3 => 2,
    4 => 3,
    _ => 0,
  };

  Future<void> _onNavTap(int index) async {
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
    return Scaffold(
      body: IndexedStack(index: _screenIndex, children: _screens),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        onCenterLongPress: _onAddLongPress,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onCenterLongPress,
  });

  static const _addIndex = 2;

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavIcon(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavIcon(
              icon: Icons.bar_chart_rounded,
              selectedIcon: Icons.bar_chart_rounded,
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _CenterButton(
              onTap: () => onTap(_addIndex),
              onLongPress: onCenterLongPress,
            ),
            _NavIcon(
              icon: Icons.photo_library_outlined,
              selectedIcon: Icons.photo_library,
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({
    required this.onTap,
    required this.onLongPress,
  });

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.onSurfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          color: cs.surface,
          size: 22,
        ),
      ),
    );
  }
}
