import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/kaza/domain/entities/prayer_time.dart';
import 'database_provider.dart';

class StreakDayData {
  const StreakDayData({
    required this.date,
    required this.kazaCounts,
    required this.quranPages,
  });

  final DateTime date;
  final Map<PrayerTime, int> kazaCounts;
  final int quranPages;

  bool get hasKaza => kazaCounts.values.any((value) => value > 0);
  bool get hasQuran => quranPages > 0;
}

class StreakData {
  const StreakData({required this.days});

  final List<StreakDayData> days;

  int get kazaCurrentStreak => _computeCurrentStreak(
        days.map((item) => item.hasKaza).toList(growable: false),
      );

  int get quranCurrentStreak => _computeCurrentStreak(
        days.map((item) => item.hasQuran).toList(growable: false),
      );

  static int _computeCurrentStreak(List<bool> values) {
    var streak = 0;
    for (var i = values.length - 1; i >= 0; i--) {
      if (!values[i]) {
        break;
      }
      streak++;
    }
    return streak;
  }
}

final streakProvider = FutureProvider<StreakData>((ref) async {
  final db = ref.watch(databaseProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 59));

  final kazaRows = await db.getDailyKazaStrips(start: start, end: end);
  final quranRows = await db.getDailyQuranPages(start: start, end: end);

  final kazaMap = <String, Map<PrayerTime, int>>{};
  for (final row in kazaRows) {
    final date = row['date'] as String;
    final prayer = PrayerTime.fromValue(row['prayer_time'] as String);
    final count = (row['total_count'] as num?)?.toInt() ?? 0;

    final current = kazaMap.putIfAbsent(
      date,
      () => <PrayerTime, int>{
        for (final value in PrayerTime.values) value: 0,
      },
    );
    current[prayer] = count;
  }

  final quranMap = <String, int>{};
  for (final row in quranRows) {
    final date = row['date'] as String;
    quranMap[date] = (row['total_pages'] as num?)?.toInt() ?? 0;
  }

  final days = <StreakDayData>[];
  for (var i = 0; i < 60; i++) {
    final current = DateTime(start.year, start.month, start.day + i);
    final key = _dateOnly(current);

    days.add(
      StreakDayData(
        date: current,
        kazaCounts: kazaMap[key] ?? <PrayerTime, int>{},
        quranPages: quranMap[key] ?? 0,
      ),
    );
  }

  return StreakData(days: days);
});

String _dateOnly(DateTime value) {
  final normalized = DateTime(value.year, value.month, value.day);
  return normalized.toIso8601String().split('T').first;
}
