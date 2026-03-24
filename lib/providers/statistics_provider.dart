import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/kaza/domain/entities/prayer_time.dart';
import 'database_provider.dart';

enum StatisticsPeriod { weekly, monthly }

class DebtItem {
  const DebtItem({
    required this.prayerTime,
    required this.initial,
    required this.completed,
    required this.remaining,
  });

  final PrayerTime prayerTime;
  final int initial;
  final int completed;
  final int remaining;
}

class StatisticsData {
  const StatisticsData({required this.debts, required this.chartTotals});

  final List<DebtItem> debts;
  final Map<PrayerTime, int> chartTotals;

  int get totalRemaining =>
      debts.fold<int>(0, (sum, item) => sum + item.remaining);
}

final statisticsProvider =
    FutureProvider.family<StatisticsData, StatisticsPeriod>(
        (ref, period) async {
  final db = ref.watch(databaseProvider);
  final profile = await db.getUserProfile();

  if (profile == null) {
    return StatisticsData(
      debts: const <DebtItem>[],
      chartTotals: <PrayerTime, int>{
        for (final prayer in PrayerTime.values) prayer: 0,
      },
    );
  }

  final debts = <DebtItem>[
    DebtItem(
      prayerTime: PrayerTime.sabah,
      initial: profile.initialSabah,
      completed: profile.completedSabah,
      remaining: (profile.initialSabah - profile.completedSabah)
          .clamp(0, profile.initialSabah)
          .toInt(),
    ),
    DebtItem(
      prayerTime: PrayerTime.ogle,
      initial: profile.initialOgle,
      completed: profile.completedOgle,
      remaining: (profile.initialOgle - profile.completedOgle)
          .clamp(0, profile.initialOgle)
          .toInt(),
    ),
    DebtItem(
      prayerTime: PrayerTime.ikindi,
      initial: profile.initialIkindi,
      completed: profile.completedIkindi,
      remaining: (profile.initialIkindi - profile.completedIkindi)
          .clamp(0, profile.initialIkindi)
          .toInt(),
    ),
    DebtItem(
      prayerTime: PrayerTime.aksam,
      initial: profile.initialAksam,
      completed: profile.completedAksam,
      remaining: (profile.initialAksam - profile.completedAksam)
          .clamp(0, profile.initialAksam)
          .toInt(),
    ),
    DebtItem(
      prayerTime: PrayerTime.yatsi,
      initial: profile.initialYatsi,
      completed: profile.completedYatsi,
      remaining: (profile.initialYatsi - profile.completedYatsi)
          .clamp(0, profile.initialYatsi)
          .toInt(),
    ),
    DebtItem(
      prayerTime: PrayerTime.vitir,
      initial: profile.initialVitir,
      completed: profile.completedVitir,
      remaining: (profile.initialVitir - profile.completedVitir)
          .clamp(0, profile.initialVitir)
          .toInt(),
    ),
  ];

  final rawRows = period == StatisticsPeriod.weekly
      ? await db.getWeeklyKazaSummary(days: 7)
      : await db.getMonthlyKazaSummary();

  final chartTotals = <PrayerTime, int>{
    for (final prayer in PrayerTime.values) prayer: 0,
  };

  for (final row in rawRows) {
    final prayer = PrayerTime.fromValue(row['prayer_time'] as String);
    final count = (row['total_count'] as num?)?.toInt() ?? 0;
    chartTotals[prayer] = (chartTotals[prayer] ?? 0) + count;
  }

  return StatisticsData(debts: debts, chartTotals: chartTotals);
});
