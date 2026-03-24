import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/kaza_logs_provider.dart';
import '../../providers/quran_logs_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/user_profile_provider.dart';
import 'dashboard_screen.dart';
import 'statistics_screen.dart';
import 'streak_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;
  bool _isGenerating = false;

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

  Future<void> _generateMockData() async {
    if (_isGenerating) {
      return;
    }
    setState(() => _isGenerating = true);

    try {
      final db = ref.read(databaseProvider);
      final ok = await db.generateMockDataForLastDays(days: 60);

      ref.invalidate(userProfileProvider);
      ref.invalidate(kazaLogsProvider);
      ref.invalidate(quranLogsProvider);
      ref.invalidate(statisticsProvider(StatisticsPeriod.weekly));
      ref.invalidate(statisticsProvider(StatisticsPeriod.monthly));
      ref.invalidate(streakProvider);

      if (!mounted) {
        return;
      }

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Son 60 gün için test verisi üretildi.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Önce profil oluşturulmalıdır.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (kDebugMode && (_currentIndex == 1 || _currentIndex == 2))
            IconButton(
              onPressed: _isGenerating ? null : _generateMockData,
              tooltip: 'Test Verisi Üret',
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_fix_high_rounded),
            ),
        ],
      ),
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
