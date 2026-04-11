import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/quran/data/models/quran_log_model.dart';
import 'database_provider.dart';
import 'streak_provider.dart';
import 'user_profile_provider.dart';

class QuranLogsNotifier extends AsyncNotifier<List<QuranLogModel>> {
  @override
  Future<List<QuranLogModel>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getQuranLogs();
  }

  Future<void> addTodayPages(int pages, {required DateTime date}) async {
    if (pages <= 0) {
      return;
    }

    final db = ref.read(databaseProvider);
    await db.insertOrMergeTodayQuranLog(
      QuranLogModel(date: date, pages: pages),
    );

    ref.invalidate(userProfileProvider);
    ref.invalidate(streakProvider);
    ref.invalidateSelf();
  }

  Future<int> removeTodayPages(int pages, {required DateTime date}) async {
    if (pages <= 0) {
      return 0;
    }

    final db = ref.read(databaseProvider);
    final removed = await db.removeTodayQuranPages(
      pagesToRemove: pages,
      date: date,
    );

    if (removed <= 0) {
      return 0;
    }

    ref.invalidate(userProfileProvider);
    ref.invalidate(streakProvider);
    ref.invalidateSelf();
    return removed;
  }

  Future<int> getTodayPages({DateTime? date}) async {
    final db = ref.read(databaseProvider);
    final todayLogs = await db.getQuranLogs(
      start: date ?? DateTime.now(),
      end: date ?? DateTime.now(),
    );

    return todayLogs.fold<int>(0, (sum, item) => sum + item.pages);
  }
}

final quranLogsProvider =
    AsyncNotifierProvider<QuranLogsNotifier, List<QuranLogModel>>(
  QuranLogsNotifier.new,
);
