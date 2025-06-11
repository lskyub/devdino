import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite 데이터베이스 관리를 위한 헬퍼 클래스
class DatabaseHelper {
  static const _databaseName = "hue_daily.db";
  static const _databaseVersion = 1;

  // 싱글톤 패턴
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// 데이터베이스 인스턴스를 가져옵니다.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스를 초기화합니다.
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// 데이터베이스 테이블을 생성합니다.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hue_inspirations (
        id TEXT PRIMARY KEY,
        quote TEXT NOT NULL,
        author TEXT,
        main_color INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        category TEXT,
        mood TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  /// 데이터베이스를 닫습니다.
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 