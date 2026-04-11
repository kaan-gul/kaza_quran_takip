import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/database_provider.dart';
import '../../../../../providers/streak_provider.dart';
import '../../../../../providers/user_profile_provider.dart';
import '../../data/models/dhikr_log_model.dart';
import '../../data/models/dhikr_type_model.dart';
import 'dhikr_logs_provider.dart';

class DhikrActionResult {
  const DhikrActionResult({
    required this.totalCount,
    required this.bonusAwarded,
  });

  final int totalCount;
  final bool bonusAwarded;
}

class DhikrTypesNotifier extends AsyncNotifier<List<DhikrTypeModel>> {
  @override
  Future<List<DhikrTypeModel>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getUserDhikrs();
  }

  Future<int> addDhikrType(
      {required String name, required int targetCount}) async {
    final db = ref.read(databaseProvider);
    final id = await db.insertUserDhikr(
      DhikrTypeModel(name: name, targetCount: targetCount),
    );
    ref.invalidateSelf();
    ref.invalidate(streakProvider);
    return id;
  }

  Future<int> deleteDhikrType(int id) async {
    final db = ref.read(databaseProvider);
    final deleted = await db.deleteUserDhikr(id);
    if (deleted > 0) {
      ref.invalidateSelf();
      ref.invalidate(streakProvider);
      ref.invalidate(dhikrLogsProvider);
      ref.invalidate(userProfileProvider);
    }
    return deleted;
  }

  Future<DhikrActionResult> addDhikrCount({
    required DhikrTypeModel dhikr,
    required int count,
    required DateTime date,
  }) async {
    final db = ref.read(databaseProvider);
    final existingLogs = await db.getDhikrLogsByDate(date);
    final currentCount = existingLogs
        .where((log) => log.dhikrId == (dhikr.id ?? 0))
        .fold<int>(0, (sum, log) => sum + log.completedCount);

    await db.insertOrUpdateDhikrLog(
      log: DhikrLogModel(
        dhikrId: dhikr.id ?? 0,
        date: date,
        completedCount: count,
      ),
      targetCount: dhikr.targetCount,
    );

    ref.invalidate(dhikrLogsProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidateSelf();

    final updatedCount = currentCount + count;
    return DhikrActionResult(
      totalCount: updatedCount,
      bonusAwarded:
          currentCount < dhikr.targetCount && updatedCount >= dhikr.targetCount,
    );
  }
}

final dhikrTypesProvider =
    AsyncNotifierProvider<DhikrTypesNotifier, List<DhikrTypeModel>>(
  DhikrTypesNotifier.new,
);
