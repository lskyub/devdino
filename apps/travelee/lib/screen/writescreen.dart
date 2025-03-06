import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WriteScreen extends ConsumerWidget {
  static const routeName = 'write';
  static const routePath = '/write';

  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 여행 만들기'),
      ),
      body: const Center(
        child: Text('여행 작성 화면'),
      ),
    );
  }
}
