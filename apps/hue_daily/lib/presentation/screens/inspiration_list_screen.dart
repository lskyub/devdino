import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/hue_inspiration_provider.dart';
import '../widgets/inspiration_card.dart';

class InspirationListScreen extends ConsumerWidget {
  const InspirationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspirationsAsync = ref.watch(inspirationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('영감 목록'),
      ),
      body: inspirationsAsync.when(
        data: (inspirations) {
          if (inspirations.isEmpty) {
            return const Center(
              child: Text('저장된 영감이 없습니다.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inspirations.length,
            itemBuilder: (context, index) {
              final inspiration = inspirations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InspirationCard(inspiration: inspiration),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
  }
} 