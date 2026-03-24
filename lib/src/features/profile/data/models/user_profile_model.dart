class UserProfileModel {
  const UserProfileModel({
    this.id,
    required this.initialSabah,
    required this.initialOgle,
    required this.initialIkindi,
    required this.initialAksam,
    required this.initialYatsi,
    required this.initialVitir,
    this.completedSabah = 0,
    this.completedOgle = 0,
    this.completedIkindi = 0,
    this.completedAksam = 0,
    this.completedYatsi = 0,
    this.completedVitir = 0,
    this.level = 1,
    this.motivationPoints = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int initialSabah;
  final int initialOgle;
  final int initialIkindi;
  final int initialAksam;
  final int initialYatsi;
  final int initialVitir;
  final int completedSabah;
  final int completedOgle;
  final int completedIkindi;
  final int completedAksam;
  final int completedYatsi;
  final int completedVitir;
  final int level;
  final int motivationPoints;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel copyWith({
    int? id,
    int? initialSabah,
    int? initialOgle,
    int? initialIkindi,
    int? initialAksam,
    int? initialYatsi,
    int? initialVitir,
    int? completedSabah,
    int? completedOgle,
    int? completedIkindi,
    int? completedAksam,
    int? completedYatsi,
    int? completedVitir,
    int? level,
    int? motivationPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      initialSabah: initialSabah ?? this.initialSabah,
      initialOgle: initialOgle ?? this.initialOgle,
      initialIkindi: initialIkindi ?? this.initialIkindi,
      initialAksam: initialAksam ?? this.initialAksam,
      initialYatsi: initialYatsi ?? this.initialYatsi,
      initialVitir: initialVitir ?? this.initialVitir,
      completedSabah: completedSabah ?? this.completedSabah,
      completedOgle: completedOgle ?? this.completedOgle,
      completedIkindi: completedIkindi ?? this.completedIkindi,
      completedAksam: completedAksam ?? this.completedAksam,
      completedYatsi: completedYatsi ?? this.completedYatsi,
      completedVitir: completedVitir ?? this.completedVitir,
      level: level ?? this.level,
      motivationPoints: motivationPoints ?? this.motivationPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'initial_sabah': initialSabah,
      'initial_ogle': initialOgle,
      'initial_ikindi': initialIkindi,
      'initial_aksam': initialAksam,
      'initial_yatsi': initialYatsi,
      'initial_vitir': initialVitir,
      'completed_sabah': completedSabah,
      'completed_ogle': completedOgle,
      'completed_ikindi': completedIkindi,
      'completed_aksam': completedAksam,
      'completed_yatsi': completedYatsi,
      'completed_vitir': completedVitir,
      'level': level,
      'motivation_points': motivationPoints,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as int?,
      initialSabah: (map['initial_sabah'] as num?)?.toInt() ?? 0,
      initialOgle: (map['initial_ogle'] as num?)?.toInt() ?? 0,
      initialIkindi: (map['initial_ikindi'] as num?)?.toInt() ?? 0,
      initialAksam: (map['initial_aksam'] as num?)?.toInt() ?? 0,
      initialYatsi: (map['initial_yatsi'] as num?)?.toInt() ?? 0,
      initialVitir: (map['initial_vitir'] as num?)?.toInt() ?? 0,
      completedSabah: (map['completed_sabah'] as num?)?.toInt() ?? 0,
      completedOgle: (map['completed_ogle'] as num?)?.toInt() ?? 0,
      completedIkindi: (map['completed_ikindi'] as num?)?.toInt() ?? 0,
      completedAksam: (map['completed_aksam'] as num?)?.toInt() ?? 0,
      completedYatsi: (map['completed_yatsi'] as num?)?.toInt() ?? 0,
      completedVitir: (map['completed_vitir'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      motivationPoints: (map['motivation_points'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, int> get initialDebts {
    return <String, int>{
      'sabah': initialSabah,
      'ogle': initialOgle,
      'ikindi': initialIkindi,
      'aksam': initialAksam,
      'yatsi': initialYatsi,
      'vitir': initialVitir,
    };
  }

  Map<String, int> get completedCounts {
    return <String, int>{
      'sabah': completedSabah,
      'ogle': completedOgle,
      'ikindi': completedIkindi,
      'aksam': completedAksam,
      'yatsi': completedYatsi,
      'vitir': completedVitir,
    };
  }

  Map<String, int> get remainingDebts {
    return <String, int>{
      'sabah': (initialSabah - completedSabah).clamp(0, initialSabah).toInt(),
      'ogle': (initialOgle - completedOgle).clamp(0, initialOgle).toInt(),
      'ikindi':
          (initialIkindi - completedIkindi).clamp(0, initialIkindi).toInt(),
      'aksam': (initialAksam - completedAksam).clamp(0, initialAksam).toInt(),
      'yatsi': (initialYatsi - completedYatsi).clamp(0, initialYatsi).toInt(),
      'vitir': (initialVitir - completedVitir).clamp(0, initialVitir).toInt(),
    };
  }
}
