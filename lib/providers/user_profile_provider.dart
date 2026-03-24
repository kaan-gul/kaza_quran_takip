import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/features/kaza/domain/entities/prayer_time.dart';
import '../src/features/profile/data/models/user_profile_model.dart';
import 'database_provider.dart';

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
    final remainder = profile.motivationPoints % 10;
    return 10 - remainder;
  }

  double get levelProgress {
    return (profile.motivationPoints % 10) / 10;
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
    ref.invalidateSelf();
    await future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileViewData?>(
  UserProfileNotifier.new,
);
