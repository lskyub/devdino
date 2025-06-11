import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'data/datasources/local/database_helper.dart';
import 'presentation/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 초기화
  await DatabaseHelper.instance.database;

  runApp(
    const ProviderScope(
      child: HueDailyApp(),
    ),
  );
}

class HueDailyApp extends ConsumerWidget {
  const HueDailyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Hue Daily',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
