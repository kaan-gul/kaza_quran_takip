class DhikrLogModel {
  const DhikrLogModel({
    this.id,
    required this.dhikrId,
    required this.date,
    required this.completedCount,
    this.createdAt,
  });

  final int? id;
  final int dhikrId;
  final DateTime date;
  final int completedCount;
  final DateTime? createdAt;

  DhikrLogModel copyWith({
    int? id,
    int? dhikrId,
    DateTime? date,
    int? completedCount,
    DateTime? createdAt,
  }) {
    return DhikrLogModel(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      date: date ?? this.date,
      completedCount: completedCount ?? this.completedCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'dhikr_id': dhikrId,
      'date': _dateOnly(date),
      'completed_count': completedCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory DhikrLogModel.fromMap(Map<String, dynamic> map) {
    return DhikrLogModel(
      id: map['id'] as int?,
      dhikrId: map['dhikr_id'] as int? ?? 0,
      date: DateTime.parse(map['date'] as String),
      completedCount: map['completed_count'] as int? ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
    );
  }

  String _dateOnly(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.toIso8601String().split('T').first;
  }
}
