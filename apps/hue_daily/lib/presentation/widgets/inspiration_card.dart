import 'package:flutter/material.dart';

import '../../domain/entities/hue_inspiration.dart';

/// 영감 정보를 카드 형태로 보여주는 위젯
class InspirationCard extends StatelessWidget {
  final HueInspiration inspiration;

  const InspirationCard({
    super.key,
    required this.inspiration,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Color(inspiration.mainColor);
    final isDark = color.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inspiration.quote,
              style: textTheme.titleLarge?.copyWith(
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '- ${inspiration.author}',
              style: textTheme.titleMedium?.copyWith(
                color: textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildChip(
                  label: inspiration.category ?? '기타',
                  icon: Icons.category,
                  textColor: textColor,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: inspiration.mood ?? '일반',
                  icon: Icons.mood,
                  textColor: textColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color textColor,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: textColor),
      label: Text(
        label,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: textColor.withOpacity(0.1),
    );
  }
} 