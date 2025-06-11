import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/hue_inspiration_provider.dart';
import '../widgets/color_preview.dart';
import '../widgets/inspiration_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyInspirationAsync = ref.watch(dailyInspirationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 색감'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push('/inspirations'),
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => context.push('/palettes'),
          ),
        ],
      ),
      body: dailyInspirationAsync.when(
        data: (inspiration) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColorPreview(color: Color(inspiration.mainColor)),
                const SizedBox(height: 16),
                InspirationCard(inspiration: inspiration),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.push('/create-palette'),
                  child: const Text('이 색감으로 팔레트 만들기'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
  }
} 