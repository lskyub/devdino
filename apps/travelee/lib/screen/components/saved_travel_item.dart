import 'package:design_systems/dino/foundations/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/dino/components/text/text.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/router.dart';
import 'dart:math' as Math;

class SavedTravelItem extends ConsumerWidget {
  final TravelModel travel;
  final String Function(DateTime?) formatDate;

  const SavedTravelItem({
    super.key,
    required this.travel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: $dinoToken.color.blingGray200.resolve(context),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(currentTravelIdProvider.notifier).state = travel.id;
              ref.read(routerProvider).push('/travel_detail/${travel.id}');
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: $dinoToken.color.primary.resolve(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DinoText(
                          type: DinoTextType.bodyM,
                          text: travel.destination.join(', '),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('여행 삭제'),
                              content: const Text(
                                  '이 여행을 삭제하시겠습니까?\n삭제된 여행은 복구할 수 없습니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(travelsProvider.notifier)
                                        .removeTravel(travel.id);
                                    context.pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: $dinoToken.color.blingGray400.resolve(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: $dinoToken.color.primary.resolve(context),
                      ),
                      const SizedBox(width: 6),
                      DinoText(
                        type: DinoTextType.bodyS,
                        text:
                            '${formatDate(travel.startDate)} ~ ${formatDate(travel.endDate)}',
                        color: $dinoToken.color.blingGray500.resolve(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: $dinoToken.color.blingGray400.resolve(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DinoText(
                          type: DinoTextType.detailS,
                          text:
                              'ID: ${travel.id.substring(0, Math.min(travel.id.length, 16))}...',
                          color: $dinoToken.color.blingGray400.resolve(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 