import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/database_provider.dart';
import '../../../../../providers/selected_date_provider.dart';
import '../../data/models/dhikr_log_model.dart';

final dhikrLogsProvider = FutureProvider<List<DhikrLogModel>>((ref) async {
  final db = ref.watch(databaseProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return db.getDhikrLogsByDate(selectedDate);
});
