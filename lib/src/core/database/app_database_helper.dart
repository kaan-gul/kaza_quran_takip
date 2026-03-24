import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/kaza/data/models/kaza_log_model.dart';
import '../../features/kaza/domain/entities/prayer_time.dart';
import '../../features/profile/data/models/user_profile_model.dart';
import '../../features/quran/data/models/quran_log_model.dart';

class AppDatabaseHelper {
  AppDatabaseHelper._internal();

  static final AppDatabaseHelper instance = AppDatabaseHelper._internal();

  static const String _databaseName = 'kaza_quran_takip.db';
  static const int _databaseVersion = 1;

  static const String userProfileTable = 'user_profile';
  static const String kazaLogsTable = 'kaza_logs';
  static const String quranLogsTable = 'quran_logs';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _databaseName);

    return openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userProfileTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        initial_sabah INTEGER NOT NULL,
        initial_ogle INTEGER NOT NULL,
        initial_ikindi INTEGER NOT NULL,
        initial_aksam INTEGER NOT NULL,
        initial_yatsi INTEGER NOT NULL,
        initial_vitir INTEGER NOT NULL,
        completed_sabah INTEGER NOT NULL DEFAULT 0,
        completed_ogle INTEGER NOT NULL DEFAULT 0,
        completed_ikindi INTEGER NOT NULL DEFAULT 0,
        completed_aksam INTEGER NOT NULL DEFAULT 0,
        completed_yatsi INTEGER NOT NULL DEFAULT 0,
        completed_vitir INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        motivation_points INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $kazaLogsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayer_time TEXT NOT NULL,
        count INTEGER NOT NULL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $quranLogsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        pages INTEGER NOT NULL,
        created_at TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_kaza_date_time ON $kazaLogsTable (date, prayer_time)',
    );
    await db.execute(
      'CREATE INDEX idx_quran_date ON $quranLogsTable (date)',
    );
  }

  Future<int> upsertUserProfile(UserProfileModel profile) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await db.query(userProfileTable, limit: 1);
    if (existing.isEmpty) {
      return db.insert(
        userProfileTable,
        profile
            .copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now())
            .toMap(),
      );
    }

    final id = (existing.first['id'] as num).toInt();
    final data =
        profile.copyWith(id: id, updatedAt: DateTime.parse(now)).toMap();

    await db.update(
      userProfileTable,
      data,
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
    return id;
  }

  Future<UserProfileModel?> getUserProfile() async {
    final db = await database;
    final maps = await db.query(userProfileTable, limit: 1);
    if (maps.isEmpty) {
      return null;
    }
    return UserProfileModel.fromMap(maps.first);
  }

  Future<int> insertKazaLog(KazaLogModel log) async {
    final db = await database;

    return db.transaction<int>((txn) async {
      final id = await txn.insert(
        kazaLogsTable,
        log.copyWith(createdAt: DateTime.now()).toMap(),
      );

      await _increaseCompletedAndMotivation(
        txn: txn,
        prayerTime: log.prayerTime,
        incrementBy: log.count,
      );

      return id;
    });
  }

  Future<int> undoTodayKaza({
    required PrayerTime prayerTime,
    int decrementBy = 1,
  }) async {
    if (decrementBy <= 0) {
      return 0;
    }

    final db = await database;
    final today = _dateOnly(DateTime.now());

    return db.transaction<int>((txn) async {
      final rows = await txn.query(
        kazaLogsTable,
        where: 'date = ? AND prayer_time = ?',
        whereArgs: <Object>[today, prayerTime.name],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (rows.isEmpty) {
        return 0;
      }

      final row = rows.first;
      final id = (row['id'] as num).toInt();
      final currentCount = (row['count'] as num?)?.toInt() ?? 0;
      if (currentCount <= 0) {
        return 0;
      }

      final removed = currentCount >= decrementBy ? decrementBy : currentCount;
      final nextCount = currentCount - removed;

      if (nextCount > 0) {
        await txn.update(
          kazaLogsTable,
          <String, Object>{'count': nextCount},
          where: 'id = ?',
          whereArgs: <Object>[id],
        );
      } else {
        await txn.delete(
          kazaLogsTable,
          where: 'id = ?',
          whereArgs: <Object>[id],
        );
      }

      await _decreaseCompletedAndMotivation(
        txn: txn,
        prayerTime: prayerTime,
        decrementBy: removed,
      );

      return removed;
    });
  }

  Future<void> _increaseCompletedAndMotivation({
    required Transaction txn,
    required PrayerTime prayerTime,
    required int incrementBy,
  }) async {
    final profileRows = await txn.query(userProfileTable, limit: 1);
    if (profileRows.isEmpty) {
      return;
    }

    final profile = UserProfileModel.fromMap(profileRows.first);
    final column = switch (prayerTime) {
      PrayerTime.sabah => 'completed_sabah',
      PrayerTime.ogle => 'completed_ogle',
      PrayerTime.ikindi => 'completed_ikindi',
      PrayerTime.aksam => 'completed_aksam',
      PrayerTime.yatsi => 'completed_yatsi',
      PrayerTime.vitir => 'completed_vitir',
    };

    final currentCompleted = (profileRows.first[column] as num?)?.toInt() ?? 0;
    final newCompleted = currentCompleted + incrementBy;

    final pointsAfter = profile.motivationPoints + (incrementBy * 70);
    final levelAfter = _calculateLevelFromPoints(pointsAfter);

    await txn.update(
      userProfileTable,
      <String, Object>{
        column: newCompleted,
        'motivation_points': pointsAfter,
        'level': levelAfter,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[profile.id ?? 1],
    );
  }

  Future<void> _decreaseCompletedAndMotivation({
    required Transaction txn,
    required PrayerTime prayerTime,
    required int decrementBy,
  }) async {
    if (decrementBy <= 0) {
      return;
    }

    final profileRows = await txn.query(userProfileTable, limit: 1);
    if (profileRows.isEmpty) {
      return;
    }

    final profile = UserProfileModel.fromMap(profileRows.first);
    final column = switch (prayerTime) {
      PrayerTime.sabah => 'completed_sabah',
      PrayerTime.ogle => 'completed_ogle',
      PrayerTime.ikindi => 'completed_ikindi',
      PrayerTime.aksam => 'completed_aksam',
      PrayerTime.yatsi => 'completed_yatsi',
      PrayerTime.vitir => 'completed_vitir',
    };

    final currentCompleted = (profileRows.first[column] as num?)?.toInt() ?? 0;
    final newCompleted =
        (currentCompleted - decrementBy).clamp(0, currentCompleted);

    final pointsAfter = (profile.motivationPoints - (decrementBy * 70))
        .clamp(0, profile.motivationPoints);
    final levelAfter = _calculateLevelFromPoints(pointsAfter);

    await txn.update(
      userProfileTable,
      <String, Object>{
        column: newCompleted,
        'motivation_points': pointsAfter,
        'level': levelAfter,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[profile.id ?? 1],
    );
  }

  Future<int> insertOrMergeTodayQuranLog(QuranLogModel log) async {
    final db = await database;
    final day = _dateOnly(log.date);

    return db.transaction<int>((txn) async {
      final existing = await txn.query(
        quranLogsTable,
        where: 'date = ?',
        whereArgs: <Object>[day],
        limit: 1,
      );

      if (existing.isEmpty) {
        final insertedId = await txn.insert(
          quranLogsTable,
          log.copyWith(createdAt: DateTime.now()).toMap(),
        );

        await _increaseMotivationFromQuran(txn: txn, pages: log.pages);
        return insertedId;
      }

      final row = existing.first;
      final currentPages = (row['pages'] as num?)?.toInt() ?? 0;
      final newPages = currentPages + log.pages;
      final id = (row['id'] as num).toInt();

      await txn.update(
        quranLogsTable,
        <String, Object>{
          'pages': newPages,
          'created_at': row['created_at'] ?? DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: <Object>[id],
      );

      await _increaseMotivationFromQuran(txn: txn, pages: log.pages);
      return id;
    });
  }

  Future<int> removeTodayQuranPages({int pagesToRemove = 1}) async {
    if (pagesToRemove <= 0) {
      return 0;
    }

    final db = await database;
    final today = _dateOnly(DateTime.now());

    return db.transaction<int>((txn) async {
      final rows = await txn.query(
        quranLogsTable,
        where: 'date = ?',
        whereArgs: <Object>[today],
        limit: 1,
      );

      if (rows.isEmpty) {
        return 0;
      }

      final row = rows.first;
      final id = (row['id'] as num).toInt();
      final currentPages = (row['pages'] as num?)?.toInt() ?? 0;
      if (currentPages <= 0) {
        return 0;
      }

      final removed =
          currentPages >= pagesToRemove ? pagesToRemove : currentPages;
      final nextPages = currentPages - removed;

      if (nextPages > 0) {
        await txn.update(
          quranLogsTable,
          <String, Object>{'pages': nextPages},
          where: 'id = ?',
          whereArgs: <Object>[id],
        );
      } else {
        await txn.delete(
          quranLogsTable,
          where: 'id = ?',
          whereArgs: <Object>[id],
        );
      }

      await _decreaseMotivationFromQuran(txn: txn, pages: removed);
      return removed;
    });
  }

  Future<void> _increaseMotivationFromQuran({
    required Transaction txn,
    required int pages,
  }) async {
    final profileRows = await txn.query(userProfileTable, limit: 1);
    if (profileRows.isEmpty) {
      return;
    }

    final profile = UserProfileModel.fromMap(profileRows.first);
    final gainedPoints = pages * 70;
    final pointsAfter = profile.motivationPoints + gainedPoints;
    final levelAfter = _calculateLevelFromPoints(pointsAfter);

    await txn.update(
      userProfileTable,
      <String, Object>{
        'motivation_points': pointsAfter,
        'level': levelAfter,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[profile.id ?? 1],
    );
  }

  Future<void> _decreaseMotivationFromQuran({
    required Transaction txn,
    required int pages,
  }) async {
    if (pages <= 0) {
      return;
    }

    final profileRows = await txn.query(userProfileTable, limit: 1);
    if (profileRows.isEmpty) {
      return;
    }

    final profile = UserProfileModel.fromMap(profileRows.first);
    final pointsAfter = (profile.motivationPoints - (pages * 70))
        .clamp(0, profile.motivationPoints);
    final levelAfter = _calculateLevelFromPoints(pointsAfter);

    await txn.update(
      userProfileTable,
      <String, Object>{
        'motivation_points': pointsAfter,
        'level': levelAfter,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[profile.id ?? 1],
    );
  }

  Future<List<KazaLogModel>> getKazaLogs({
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await database;

    final whereParts = <String>[];
    final whereArgs = <Object>[];

    if (start != null) {
      whereParts.add('date >= ?');
      whereArgs.add(_dateOnly(start));
    }
    if (end != null) {
      whereParts.add('date <= ?');
      whereArgs.add(_dateOnly(end));
    }

    final maps = await db.query(
      kazaLogsTable,
      where: whereParts.isEmpty ? null : whereParts.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map(KazaLogModel.fromMap).toList();
  }

  Future<List<KazaLogModel>> getLogsByPrayerTime(String vakit) async {
    final db = await database;
    final prayerKey = _normalizePrayerKey(vakit);
    if (prayerKey == null) {
      return const <KazaLogModel>[];
    }

    final maps = await db.query(
      kazaLogsTable,
      where: 'prayer_time = ?',
      whereArgs: <Object>[prayerKey],
      orderBy: 'date DESC, id DESC',
    );

    return maps.map(KazaLogModel.fromMap).toList();
  }

  Future<List<QuranLogModel>> getQuranLogs({
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await database;

    final whereParts = <String>[];
    final whereArgs = <Object>[];

    if (start != null) {
      whereParts.add('date >= ?');
      whereArgs.add(_dateOnly(start));
    }
    if (end != null) {
      whereParts.add('date <= ?');
      whereArgs.add(_dateOnly(end));
    }

    final maps = await db.query(
      quranLogsTable,
      where: whereParts.isEmpty ? null : whereParts.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map(QuranLogModel.fromMap).toList();
  }

  Future<Map<PrayerTime, int>> getTotalKazaByPrayerTime() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT prayer_time, SUM(count) AS total
      FROM $kazaLogsTable
      GROUP BY prayer_time
    ''');

    final result = <PrayerTime, int>{
      for (final value in PrayerTime.values) value: 0,
    };

    for (final row in rows) {
      final time = PrayerTime.fromValue(row['prayer_time'] as String);
      result[time] = (row['total'] as num?)?.toInt() ?? 0;
    }

    return result;
  }

  Future<Map<PrayerTime, int>> getRemainingDebts() async {
    final profile = await getUserProfile();
    if (profile == null) {
      return <PrayerTime, int>{
        for (final value in PrayerTime.values) value: 0,
      };
    }

    return <PrayerTime, int>{
      PrayerTime.sabah: profile.remainingDebts['sabah'] ?? 0,
      PrayerTime.ogle: profile.remainingDebts['ogle'] ?? 0,
      PrayerTime.ikindi: profile.remainingDebts['ikindi'] ?? 0,
      PrayerTime.aksam: profile.remainingDebts['aksam'] ?? 0,
      PrayerTime.yatsi: profile.remainingDebts['yatsi'] ?? 0,
      PrayerTime.vitir: profile.remainingDebts['vitir'] ?? 0,
    };
  }

  Future<List<Map<String, Object?>>> getWeeklyKazaSummary(
      {int days = 7}) async {
    final db = await database;
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));

    return db.rawQuery(
      '''
      SELECT date, prayer_time, SUM(count) AS total_count
      FROM $kazaLogsTable
      WHERE date BETWEEN ? AND ?
      GROUP BY date, prayer_time
      ORDER BY date ASC
      ''',
      <Object>[_dateOnly(start), _dateOnly(end)],
    );
  }

  Future<List<Map<String, Object?>>> getMonthlyKazaSummary({
    DateTime? month,
  }) async {
    final db = await database;
    final target = month ?? DateTime.now();
    final monthKey =
        '${target.year.toString().padLeft(4, '0')}-${target.month.toString().padLeft(2, '0')}';

    return db.rawQuery(
      '''
      SELECT strftime('%Y-%m-%d', date) AS day, prayer_time, SUM(count) AS total_count
      FROM $kazaLogsTable
      WHERE strftime('%Y-%m', date) = ?
      GROUP BY day, prayer_time
      ORDER BY day ASC
      ''',
      <Object>[monthKey],
    );
  }

  Future<List<Map<String, Object?>>> getDailyKazaStrips({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;

    return db.rawQuery(
      '''
      SELECT date, prayer_time, SUM(count) AS total_count
      FROM $kazaLogsTable
      WHERE date BETWEEN ? AND ?
      GROUP BY date, prayer_time
      ORDER BY date ASC
      ''',
      <Object>[_dateOnly(start), _dateOnly(end)],
    );
  }

  Future<List<Map<String, Object?>>> getDailyQuranPages({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;

    return db.rawQuery(
      '''
      SELECT date, SUM(pages) AS total_pages
      FROM $quranLogsTable
      WHERE date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date ASC
      ''',
      <Object>[_dateOnly(start), _dateOnly(end)],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(kazaLogsTable);
      await txn.delete(quranLogsTable);
      await txn.delete(userProfileTable);
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  String _dateOnly(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.toIso8601String().split('T').first;
  }

  String? _normalizePrayerKey(String vakit) {
    final value = vakit.trim().toLowerCase();
    switch (value) {
      case 'sabah':
        return PrayerTime.sabah.name;
      case 'öğle':
      case 'ogle':
        return PrayerTime.ogle.name;
      case 'ikindi':
        return PrayerTime.ikindi.name;
      case 'akşam':
      case 'aksam':
        return PrayerTime.aksam.name;
      case 'yatsı':
      case 'yatsi':
        return PrayerTime.yatsi.name;
      case 'vitir':
        return PrayerTime.vitir.name;
      default:
        return null;
    }
  }

  int _calculateLevelFromPoints(int totalPoints) {
    int level = 1;
    while (true) {
      final nextThreshold = _getLevelThreshold(level + 1);
      if (totalPoints < nextThreshold) {
        break;
      }
      level++;
    }
    return level;
  }

  int _getLevelThreshold(int level) {
    if (level <= 1) {
      return 0;
    } else if (level == 2) {
      return 700;
    } else {
      return 700 + (level - 2) * 140;
    }
  }
}
