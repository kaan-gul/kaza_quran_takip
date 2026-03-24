import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'statistics_screen.dart';
import 'streak_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  static const _titles = <String>[
    'Ana Sayfa',
    'İstatistikler',
    'Seriler',
  ];

  late final List<Widget> _pages = const <Widget>[
    DashboardScreen(),
    StatisticsScreen(),
    StreakScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final showTopBar = _currentIndex != 2;

    return Scaffold(
      appBar: showTopBar
          ? AppBar(
              title: Text(_titles[_currentIndex]),
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'İstatistikler',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Seriler',
          ),
        ],
      ),
    );
  }
}
