class QuranLogModel {
  const QuranLogModel({
    this.id,
    required this.date,
    required this.pages,
    this.createdAt,
  });

  final int? id;
  final DateTime date;
  final int pages;
  final DateTime? createdAt;

  QuranLogModel copyWith({
    int? id,
    DateTime? date,
    int? pages,
    DateTime? createdAt,
  }) {
    return QuranLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'date': _dateOnly(date),
      'pages': pages,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory QuranLogModel.fromMap(Map<String, dynamic> map) {
    return QuranLogModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      pages: (map['pages'] as num?)?.toInt() ?? 0,
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
