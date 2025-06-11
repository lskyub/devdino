import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/hue_inspiration.dart';
import '../../models/hue_inspiration_model.dart';
import 'database_helper.dart';

/// 로컬 데이터베이스에서 영감 컬러 데이터를 관리하는 데이터 소스
class HueInspirationLocalDataSource {
  final DatabaseHelper _databaseHelper;

  HueInspirationLocalDataSource({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// 모든 영감 컬러 목록을 가져옵니다.
  Future<List<HueInspiration>> getInspirations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('hue_inspirations');
    
    return maps.map((map) => HueInspirationModel.fromMap(map)).toList();
  }

  /// 특정 ID의 영감 컬러를 가져옵니다.
  Future<HueInspiration?> getInspiration(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hue_inspirations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return HueInspirationModel.fromMap(maps.first);
  }

  /// 새로운 영감 컬러를 생성합니다.
  Future<void> createInspiration(HueInspiration inspiration) async {
    final db = await _databaseHelper.database;
    final model = HueInspirationModel.fromEntity(inspiration);
    
    await db.insert(
      'hue_inspirations',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 기존 영감 컬러를 업데이트합니다.
  Future<void> updateInspiration(HueInspiration inspiration) async {
    final db = await _databaseHelper.database;
    final model = HueInspirationModel.fromEntity(inspiration);
    
    await db.update(
      'hue_inspirations',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [inspiration.id],
    );
  }

  /// 특정 ID의 영감 컬러를 삭제합니다.
  Future<void> deleteInspiration(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'hue_inspirations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 동기화되지 않은 영감 컬러 목록을 가져옵니다.
  Future<List<HueInspiration>> getUnsyncedInspirations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hue_inspirations',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    
    return maps.map((map) => HueInspirationModel.fromMap(map)).toList();
  }

  /// 영감 컬러의 동기화 상태를 업데이트합니다.
  Future<void> markAsSynced(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'hue_inspirations',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 