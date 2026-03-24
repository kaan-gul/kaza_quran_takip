import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/core/database/app_database_helper.dart';

final databaseProvider = Provider<AppDatabaseHelper>((ref) {
  return AppDatabaseHelper.instance;
});

final isOnboardingRequiredProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final profile = await db.getUserProfile();
  return profile == null;
});
