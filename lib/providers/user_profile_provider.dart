import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/kaza/domain/entities/prayer_time.dart';
import '../src/features/profile/data/models/user_profile_model.dart';
import 'database_provider.dart';
import 'statistics_provider.dart';
import 'streak_provider.dart';

class UserProfileViewData {
  const UserProfileViewData({required this.profile});

  final UserProfileModel profile;

  Map<PrayerTime, int> get completedByPrayer {
    return <PrayerTime, int>{
      PrayerTime.sabah: profile.completedSabah,
      PrayerTime.ogle: profile.completedOgle,
      PrayerTime.ikindi: profile.completedIkindi,
      PrayerTime.aksam: profile.completedAksam,
      PrayerTime.yatsi: profile.completedYatsi,
      PrayerTime.vitir: profile.completedVitir,
    };
  }

  int get pointsToNextLevel {
    final currentThreshold = _getLevelThreshold(profile.level);
    final nextThreshold = _getLevelThreshold(profile.level + 1);
    final pointsInLevel = profile.motivationPoints - currentThreshold;
    final pointsNeeded = nextThreshold - currentThreshold;
    return (pointsNeeded - pointsInLevel).clamp(0, pointsNeeded);
  }

  double get levelProgress {
    final currentThreshold = _getLevelThreshold(profile.level);
    final nextThreshold = _getLevelThreshold(profile.level + 1);
    final pointsInLevel = profile.motivationPoints - currentThreshold;
    final pointsNeeded = nextThreshold - currentThreshold;
    if (pointsNeeded <= 0) return 0;
    return (pointsInLevel / pointsNeeded).clamp(0, 1);
  }

  static int _getLevelThreshold(int level) {
    if (level <= 1) {
      return 0;
    } else if (level == 2) {
      return 700;
    } else {
      return 700 + (level - 2) * 140;
    }
  }
}

class UserProfileNotifier extends AsyncNotifier<UserProfileViewData?> {
  @override
  Future<UserProfileViewData?> build() async {
    final db = ref.watch(databaseProvider);
    final profile = await db.getUserProfile();
    if (profile == null) {
      return null;
    }
    return UserProfileViewData(profile: profile);
  }

  Future<void> saveInitialProfile({
    required int sabah,
    required int ogle,
    required int ikindi,
    required int aksam,
    required int yatsi,
    required int vitir,
  }) async {
    final db = ref.read(databaseProvider);

    final model = UserProfileModel(
      initialSabah: sabah,
      initialOgle: ogle,
      initialIkindi: ikindi,
      initialAksam: aksam,
      initialYatsi: yatsi,
      initialVitir: vitir,
      level: 1,
      motivationPoints: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.upsertUserProfile(model);
    ref.invalidate(isOnboardingRequiredProvider);
    ref.invalidate(statisticsProvider(StatisticsPeriod.weekly));
    ref.invalidate(statisticsProvider(StatisticsPeriod.monthly));
    ref.invalidate(streakProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateInitialDebts({
    required int sabah,
    required int ogle,
    required int ikindi,
    required int aksam,
    required int yatsi,
    required int vitir,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getUserProfile();
    if (existing == null) {
      return;
    }

    final updated = existing.copyWith(
      initialSabah: sabah,
      initialOgle: ogle,
      initialIkindi: ikindi,
      initialAksam: aksam,
      initialYatsi: yatsi,
      initialVitir: vitir,
      updatedAt: DateTime.now(),
    );

    await db.upsertUserProfile(updated);
    ref.invalidate(statisticsProvider(StatisticsPeriod.weekly));
    ref.invalidate(statisticsProvider(StatisticsPeriod.monthly));
    ref.invalidateSelf();
    await future;
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileViewData?>(
  UserProfileNotifier.new,
);
