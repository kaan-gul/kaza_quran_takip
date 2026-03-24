enum PrayerTime {
  sabah,
  ogle,
  ikindi,
  aksam,
  yatsi,
  vitir;

  static PrayerTime fromValue(String value) {
    return PrayerTime.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PrayerTime.sabah,
    );
  }
}
