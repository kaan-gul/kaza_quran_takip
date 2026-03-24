import 'package:flutter/material.dart';

import '../../src/features/kaza/domain/entities/prayer_time.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF8F9FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color sabah = Color(0xFFF4C95D);
  static const Color ogle = Color(0xFF7CC9E8);
  static const Color ikindi = Color(0xFFE8A86D);
  static const Color aksam = Color(0xFFD97A7A);
  static const Color yatsi = Color(0xFF6D83C6);
  static const Color vitir = Color(0xFFAD88D3);

  static const Color quranEmerald = Color(0xFF4BAF8A);
  static const Color success = Color(0xFF16A34A);

  static Color prayerColor(PrayerTime prayerTime) {
    return switch (prayerTime) {
      PrayerTime.sabah => sabah,
      PrayerTime.ogle => ogle,
      PrayerTime.ikindi => ikindi,
      PrayerTime.aksam => aksam,
      PrayerTime.yatsi => yatsi,
      PrayerTime.vitir => vitir,
    };
  }
}
