class DhikrTypeModel {
  const DhikrTypeModel({
    this.id,
    required this.name,
    required this.targetCount,
    this.createdAt,
  });

  final int? id;
  final String name;
  final int targetCount;
  final DateTime? createdAt;

  DhikrTypeModel copyWith({
    int? id,
    String? name,
    int? targetCount,
    DateTime? createdAt,
  }) {
    return DhikrTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetCount: targetCount ?? this.targetCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'target_count': targetCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory DhikrTypeModel.fromMap(Map<String, dynamic> map) {
    return DhikrTypeModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      targetCount: map['target_count'] as int? ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
    );
  }
}
