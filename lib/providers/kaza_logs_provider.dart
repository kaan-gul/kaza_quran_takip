import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/kaza/data/models/kaza_log_model.dart';
import '../src/features/kaza/domain/entities/prayer_time.dart';
import 'database_provider.dart';
import 'statistics_provider.dart';
import 'streak_provider.dart';
import 'user_profile_provider.dart';

class KazaActionResult {
  const KazaActionResult({required this.levelUp, required this.newLevel});

  final bool levelUp;
  final int newLevel;
}

class KazaLogsNotifier extends AsyncNotifier<List<KazaLogModel>> {
  @override
  Future<List<KazaLogModel>> build() async {
    final db = ref.watch(databaseProvider);
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));

    return db.getKazaLogs(start: start, end: now);
  }

  Future<KazaActionResult> addKaza({
    required PrayerTime prayerTime,
    int count = 1,
  }) async {
    final db = ref.read(databaseProvider);
    final profileBefore = await db.getUserProfile();

    await db.insertKazaLog(
      KazaLogModel(
        date: DateTime.now(),
        prayerTime: prayerTime,
        count: count,
      ),
    );

    final profileAfter = await db.getUserProfile();

    ref.invalidate(userProfileProvider);
    ref.invalidate(statisticsProvider(StatisticsPeriod.weekly));
    ref.invalidate(statisticsProvider(StatisticsPeriod.monthly));
    ref.invalidate(streakProvider);
    ref.invalidateSelf();

    final oldLevel = profileBefore?.level ?? 1;
    final newLevel = profileAfter?.level ?? oldLevel;

    return KazaActionResult(levelUp: newLevel > oldLevel, newLevel: newLevel);
  }

  Future<List<Map<String, Object?>>> getWeeklySummary({int days = 7}) async {
    final db = ref.read(databaseProvider);
    return db.getWeeklyKazaSummary(days: days);
  }
}

final kazaLogsProvider =
    AsyncNotifierProvider<KazaLogsNotifier, List<KazaLogModel>>(
  KazaLogsNotifier.new,
);
