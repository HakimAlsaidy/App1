import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course_receipt.dart';

class DatabaseHelper {
  static const String _databaseName = 'hall_records_v2.db';
  static const String _tableName = 'person_records';
  static const int _databaseVersion = 2;

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        name TEXT NOT NULL,
        residence TEXT DEFAULT '',
        amount REAL NOT NULL DEFAULT 0.0,
        year1444 REAL,
        year1444Status TEXT,
        year1445 REAL,
        year1445Status TEXT,
        year1446 REAL,
        year1446Status TEXT,
        notes TEXT DEFAULT '',
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_name ON $_tableName (name)');
    await db.execute('CREATE INDEX idx_number ON $_tableName (number)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration: add createdAt and updatedAt
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN createdAt TEXT');
        await db.execute('ALTER TABLE $_tableName ADD COLUMN updatedAt TEXT');
      } catch (e) {
        // Columns may already exist
      }
    }
  }

  Future<int> insertPersonRecord(PersonRecord record) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final map = record.toMap();
    map['createdAt'] = now;
    map['updatedAt'] = now;
    map.remove('id');
    return await db.insert(_tableName, map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PersonRecord>> getAllPersonRecords({String? orderBy}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: orderBy ?? 'number ASC',
    );
    return maps.map((m) => PersonRecord.fromMap(m)).toList();
  }

  Future<PersonRecord?> getPersonRecordById(int id) async {
    final db = await database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? PersonRecord.fromMap(maps.first) : null;
  }

  Future<int> updatePersonRecord(PersonRecord record) async {
    final db = await database;
    final map = record.toMap();
    map['updatedAt'] = DateTime.now().toIso8601String();
    return await db.update(_tableName, map, where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deletePersonRecord(int id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PersonRecord>> searchPersonRecords(String query) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR residence LIKE ? OR number LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'number ASC',
    );
    return maps.map((m) => PersonRecord.fromMap(m)).toList();
  }

  Future<List<PersonRecord>> getPersonRecordsByYear(String year) async {
    final db = await database;
    final whereClause = year == '1444' ? 'year1444 IS NOT NULL'
        : year == '1445' ? 'year1445 IS NOT NULL'
        : year == '1446' ? 'year1446 IS NOT NULL'
        : null;
    if (whereClause == null) return getAllPersonRecords();
    final maps = await db.query(_tableName, where: whereClause, orderBy: 'number ASC');
    return maps.map((m) => PersonRecord.fromMap(m)).toList();
  }

  Future<List<PersonRecord>> getRecordsByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'year1444Status = ? OR year1445Status = ? OR year1446Status = ?',
      whereArgs: [status, status, status],
    );
    return maps.map((m) => PersonRecord.fromMap(m)).toList();
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    final all = await db.query(_tableName);
    final records = all.map((m) => PersonRecord.fromMap(m)).toList();

    double totalAmount = 0;
    double totalReceived = 0;
    int year1444Count = 0, year1445Count = 0, year1446Count = 0;
    double year1444Total = 0, year1445Total = 0, year1446Total = 0;
    int muslimCount = 0, nonMuslimCount = 0;

    for (final r in records) {
      totalAmount += r.amount;
      totalReceived += r.totalReceivedAmount;
      if (r.year1444 != null) { year1444Count++; year1444Total += r.year1444!; }
      if (r.year1445 != null) { year1445Count++; year1445Total += r.year1445!; }
      if (r.year1446 != null) { year1446Count++; year1446Total += r.year1446!; }
      if (r.year1444Status == 'مسلم' || r.year1445Status == 'مسلم' || r.year1446Status == 'مسلم') {
        muslimCount++;
      }
      if (r.year1444Status == 'غير مسلم' || r.year1445Status == 'غير مسلم' || r.year1446Status == 'غير مسلم') {
        nonMuslimCount++;
      }
    }

    return {
      'totalRecords': records.length,
      'totalAmount': totalAmount,
      'totalReceived': totalReceived,
      'totalRemaining': totalAmount - totalReceived,
      'year1444Count': year1444Count,
      'year1445Count': year1445Count,
      'year1446Count': year1446Count,
      'year1444Total': year1444Total,
      'year1445Total': year1445Total,
      'year1446Total': year1446Total,
      'muslimCount': muslimCount,
      'nonMuslimCount': nonMuslimCount,
      'completedCount': records.where((r) => r.isFullyPaid).length,
    };
  }

  Future<void> closeDatabase() async {
    if (_database != null) await _database!.close();
  }
}
