import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/quran/data/models/quran_log_model.dart';
import 'database_provider.dart';
import 'streak_provider.dart';
import 'user_profile_provider.dart';

class QuranLogsNotifier extends AsyncNotifier<List<QuranLogModel>> {
  @override
  Future<List<QuranLogModel>> build() async {
    final db = ref.watch(databaseProvider);
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 29));
    return db.getQuranLogs(start: start, end: now);
  }

  Future<void> addTodayPages(int pages) async {
    if (pages <= 0) {
      return;
    }

    final db = ref.read(databaseProvider);
    await db.insertOrMergeTodayQuranLog(
      QuranLogModel(date: DateTime.now(), pages: pages),
    );

    ref.invalidate(userProfileProvider);
    ref.invalidate(streakProvider);
    ref.invalidateSelf();
  }

  Future<int> getTodayPages() async {
    final db = ref.read(databaseProvider);
    final todayLogs = await db.getQuranLogs(
      start: DateTime.now(),
      end: DateTime.now(),
    );

    return todayLogs.fold<int>(0, (sum, item) => sum + item.pages);
  }
}

final quranLogsProvider =
    AsyncNotifierProvider<QuranLogsNotifier, List<QuranLogModel>>(
  QuranLogsNotifier.new,
);
