import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/models/db/travel_db_model.dart';
import 'package:travelee/models/db/schedule_db_model.dart';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// DatabaseHelper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travelee.db');

    dev.log('데이터베이스 경로: $path');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    dev.log('데이터베이스 생성 시작');
    
    await db.execute('''
      CREATE TABLE travels(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        destination TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        country_infos,
        day_data_map,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules(
        id TEXT PRIMARY KEY,
        travel_id TEXT NOT NULL,
        date TEXT NOT NULL,
        time_hour INTEGER NOT NULL,
        time_minute INTEGER NOT NULL,
        location TEXT NOT NULL,
        memo TEXT,
        day_number INTEGER NOT NULL,
        latitude REAL,
        longitude REAL,
        FOREIGN KEY (travel_id) REFERENCES travels (id) ON DELETE CASCADE
      )
    ''');

    dev.log('데이터베이스 테이블 생성 완료');
  }

  // 데이터베이스 업그레이드 핸들러
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    dev.log('데이터베이스 업그레이드: $oldVersion -> $newVersion');
    
    if (oldVersion < 2) {
      // schedules 테이블에 latitude와 longitude 컬럼 추가
      await db.execute('''
        ALTER TABLE schedules
        ADD COLUMN latitude REAL
      ''');
      
      await db.execute('''
        ALTER TABLE schedules
        ADD COLUMN longitude REAL
      ''');
      
      dev.log('schedules 테이블 업그레이드 완료');
    }
  }

  // 여행 저장
  Future<bool> saveTravel(TravelModel travel) async {
    try {
      final db = await database;
      
      // UI 모델을 DB 모델로 변환
      final travelDBModel = TravelDBModel.fromTravelModel(travel);
      final travelData = travelDBModel.toMap();
      
      // 스케줄 DB 모델 리스트
      final scheduleDBModels = travel.schedules.map((s) => 
        ScheduleDBModel.fromSchedule(s)
      ).toList();
      
      // 트랜잭션 시작
      await db.transaction((txn) async {
        // 기존 여행 삭제 (일정도 CASCADE로 함께 삭제됨)
        await txn.delete(
          'travels',
          where: 'id = ?',
          whereArgs: [travel.id],
        );
        
        // 여행 데이터 저장
        await txn.insert(
          'travels',
          travelData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        // 일정 데이터 저장
        for (final scheduleDB in scheduleDBModels) {
          await txn.insert(
            'schedules',
            scheduleDB.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      
      dev.log('여행 저장 성공: ${travel.id}, 일정 ${travel.schedules.length}개');
      return true;
    } catch (e) {
      dev.log('여행 저장 오류: $e', error: e);
      return false;
    }
  }

  // 여행 삭제
  Future<bool> deleteTravel(String travelId) async {
    try {
      final db = await database;
      
      // 트랜잭션 시작
      await db.transaction((txn) async {
        // 여행 삭제 (일정도 CASCADE로 함께 삭제됨)
        await txn.delete(
          'travels',
          where: 'id = ?',
          whereArgs: [travelId],
        );
      });
      
      dev.log('여행 삭제 성공: $travelId');
      return true;
    } catch (e) {
      dev.log('여행 삭제 오류: $e', error: e);
      return false;
    }
  }

  // 모든 여행 로드
  Future<List<TravelModel>> loadAllTravels() async {
    try {
      final db = await database;
      
      // 여행 데이터 로드
      final travelMaps = await db.query('travels');
      
      if (travelMaps.isEmpty) {
        dev.log('저장된 여행 없음');
        return [];
      }
      
      final travels = <TravelModel>[];
      
      // 각 여행 데이터에 대해 일정 로드하여 완전한 여행 모델 생성
      for (final travelMap in travelMaps) {
        final travelId = travelMap['id'] as String;
        
        // 해당 여행의 일정 로드
        final scheduleMaps = await db.query(
          'schedules',
          where: 'travel_id = ?',
          whereArgs: [travelId],
        );
        
        // DB 모델 생성
        final travelDBModel = TravelDBModel.fromMap(travelMap);
        final scheduleDBModels = scheduleMaps.map((map) => 
          ScheduleDBModel.fromMap(map)
        ).toList();
        
        // 최종 DB 모델 (스케줄 포함)
        final completeTravelDBModel = TravelDBModel(
          id: travelDBModel.id,
          title: travelDBModel.title,
          destination: travelDBModel.destination,
          startDate: travelDBModel.startDate,
          endDate: travelDBModel.endDate,
          countryInfos: travelDBModel.countryInfos,
          dayDataMap: travelDBModel.dayDataMap,
          createdAt: travelDBModel.createdAt,
          updatedAt: travelDBModel.updatedAt,
          schedules: scheduleDBModels,
        );
        
        // UI 모델로 변환
        final travelUIModel = completeTravelDBModel.toTravelModel();
        travels.add(travelUIModel);
      }
      
      dev.log('여행 로드 성공: ${travels.length}개');
      return travels;
    } catch (e) {
      dev.log('여행 로드 오류: $e', error: e);
      return [];
    }
  }

  // 특정 여행 로드
  Future<TravelModel?> loadTravel(String travelId) async {
    try {
      final db = await database;
      
      // 여행 데이터 로드
      final travelMaps = await db.query(
        'travels',
        where: 'id = ?',
        whereArgs: [travelId],
      );
      
      if (travelMaps.isEmpty) {
        dev.log('여행을 찾을 수 없음: $travelId');
        return null;
      }
      
      final travelMap = travelMaps.first;
      
      // 해당 여행의 일정 로드
      final scheduleMaps = await db.query(
        'schedules',
        where: 'travel_id = ?',
        whereArgs: [travelId],
      );
      
      // DB 모델 생성
      final travelDBModel = TravelDBModel.fromMap(travelMap);
      final scheduleDBModels = scheduleMaps.map((map) => 
        ScheduleDBModel.fromMap(map)
      ).toList();
      
      // 최종 DB 모델 (스케줄 포함)
      final completeTravelDBModel = TravelDBModel(
        id: travelDBModel.id,
        title: travelDBModel.title,
        destination: travelDBModel.destination,
        startDate: travelDBModel.startDate,
        endDate: travelDBModel.endDate,
        countryInfos: travelDBModel.countryInfos,
        dayDataMap: travelDBModel.dayDataMap,
        createdAt: travelDBModel.createdAt,
        updatedAt: travelDBModel.updatedAt,
        schedules: scheduleDBModels,
      );
      
      // UI 모델로 변환
      final travelUIModel = completeTravelDBModel.toTravelModel();
      
      dev.log('여행 로드 성공: $travelId, 일정 ${scheduleDBModels.length}개');
      return travelUIModel;
    } catch (e) {
      dev.log('여행 로드 오류: $e', error: e);
      return null;
    }
  }

  // 데이터베이스 상태 체크 (디버깅용)
  Future<Map<String, dynamic>> testDatabaseStatus() async {
    try {
      final db = await database;
      
      final tableNames = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableList = tableNames.map((map) => map['name'] as String).toList();
      
      final travelCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM travels')) ?? 0;
      final scheduleCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM schedules')) ?? 0;
      
      return {
        'status': 'success',
        'tables': tableList,
        'travel_count': travelCount,
        'schedule_count': scheduleCount,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
} 