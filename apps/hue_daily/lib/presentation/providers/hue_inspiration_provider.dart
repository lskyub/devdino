import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/hue_inspiration_local_datasource.dart';
import '../../data/repositories/hue_inspiration_repository_impl.dart';
import '../../domain/entities/hue_inspiration.dart';
import '../../domain/repositories/hue_inspiration_repository.dart';
import '../../domain/usecases/get_daily_inspiration.dart';

/// HueInspirationLocalDataSource Provider
final hueInspirationLocalDataSourceProvider = Provider<HueInspirationLocalDataSource>((ref) {
  return HueInspirationLocalDataSource();
});

/// HueInspirationRepository Provider
final hueInspirationRepositoryProvider = Provider<HueInspirationRepository>((ref) {
  final localDataSource = ref.watch(hueInspirationLocalDataSourceProvider);
  return HueInspirationRepositoryImpl(localDataSource: localDataSource);
});

/// GetDailyInspiration UseCase Provider
final getDailyInspirationProvider = Provider<GetDailyInspiration>((ref) {
  final repository = ref.watch(hueInspirationRepositoryProvider);
  return GetDailyInspiration(repository);
});

/// 오늘의 영감 상태를 관리하는 Provider
final dailyInspirationProvider = FutureProvider<HueInspiration>((ref) async {
  final getDailyInspiration = ref.watch(getDailyInspirationProvider);
  return getDailyInspiration();
});

/// 모든 영감 목록을 관리하는 Provider
final inspirationsProvider = FutureProvider<List<HueInspiration>>((ref) async {
  final repository = ref.watch(hueInspirationRepositoryProvider);
  return repository.getInspirations();
}); 