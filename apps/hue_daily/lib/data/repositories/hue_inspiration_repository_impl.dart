import '../../domain/entities/hue_inspiration.dart';
import '../../domain/repositories/hue_inspiration_repository.dart';
import '../datasources/local/hue_inspiration_local_datasource.dart';

/// HueInspirationRepository 구현체
class HueInspirationRepositoryImpl implements HueInspirationRepository {
  final HueInspirationLocalDataSource _localDataSource;

  HueInspirationRepositoryImpl({
    required HueInspirationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<HueInspiration>> getInspirations() {
    return _localDataSource.getInspirations();
  }

  @override
  Future<HueInspiration?> getInspiration(String id) {
    return _localDataSource.getInspiration(id);
  }

  @override
  Future<void> createInspiration(HueInspiration inspiration) {
    return _localDataSource.createInspiration(inspiration);
  }

  @override
  Future<void> updateInspiration(HueInspiration inspiration) {
    return _localDataSource.updateInspiration(inspiration);
  }

  @override
  Future<void> deleteInspiration(String id) {
    return _localDataSource.deleteInspiration(id);
  }

  @override
  Future<void> syncToCloud() async {
    final unsyncedInspirations = await _localDataSource.getUnsyncedInspirations();
    
    // TODO: Supabase에 동기화 로직 구현
    for (final inspiration in unsyncedInspirations) {
      // 클라우드에 저장 후
      await _localDataSource.markAsSynced(inspiration.id);
    }
  }
} 