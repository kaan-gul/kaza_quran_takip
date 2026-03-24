import '../../domain/entities/prayer_time.dart';

class KazaLogModel {
  const KazaLogModel({
    this.id,
    required this.date,
    required this.prayerTime,
    required this.count,
    this.createdAt,
  });

  final int? id;
  final DateTime date;
  final PrayerTime prayerTime;
  final int count;
  final DateTime? createdAt;

  KazaLogModel copyWith({
    int? id,
    DateTime? date,
    PrayerTime? prayerTime,
    int? count,
    DateTime? createdAt,
  }) {
    return KazaLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      prayerTime: prayerTime ?? this.prayerTime,
      count: count ?? this.count,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'date': _dateOnly(date),
      'prayer_time': prayerTime.name,
      'count': count,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory KazaLogModel.fromMap(Map<String, dynamic> map) {
    return KazaLogModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      prayerTime: PrayerTime.fromValue(map['prayer_time'] as String),
      count: (map['count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
    );
  }

  static String _dateOnly(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.toIso8601String().split('T').first;
  }
}
