import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:design_systems/dino/foundations/token.typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/providers/travel_state_provider.dart';
import 'package:travelee/router.dart';
import 'package:travelee/gen/app_localizations.dart';

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
    // 오늘 날짜가 여행 시작일과 종료일에 포함되는지 확인
    bool isTodayInRange = false;
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime start = DateTime(travel.startDate!.year, travel.startDate!.month,
          travel.startDate!.day);
      DateTime end = DateTime(
          travel.endDate!.year, travel.endDate!.month, travel.endDate!.day);
      isTodayInRange = !today.isBefore(start) && !today.isAfter(end);
    } catch (e) {
      print('error: $e');
    }
    // 오늘 날짜가 여행 종료일이 지났는지 확인
    bool isEnded = false;
    try {
      final now = DateTime.now();
      final end = travel.endDate!;
      isEnded = now.isAfter(end) && !now.isAtSameMomentAs(end);
    } catch (e) {
      print('error: $e');
    }

    BoxDecoration decoration;

    if (isTodayInRange) {
      decoration = BoxDecoration(
        color: $dinoToken.color.brandBlingPurple50.resolve(context),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5E9DEA),
            Color(0xFFF189E0),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      );
    } else if (isEnded) {
      decoration = BoxDecoration(
        border:
            Border.all(color: $dinoToken.color.blingGray200.resolve(context)),
        color: $dinoToken.color.blingGray75.resolve(context),
        borderRadius: BorderRadius.circular(20),
      );
    } else {
      decoration = BoxDecoration(
        border:
            Border.all(color: $dinoToken.color.blingGray300.resolve(context)),
        color: $dinoToken.color.white.resolve(context),
        borderRadius: BorderRadius.circular(20),
      );
    }
    return GestureDetector(
      onTap: () {
        ref.read(currentTravelIdProvider.notifier).state = travel.id;
        ref.read(routerProvider).push('/travel_detail/${travel.id}');
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: $dinoToken.color.blingGray100.resolve(context),
                    width: 0.5,
                  ),
                  color: $dinoToken.color.white.resolve(context),
                ),
                child: ClipOval(
                  child: Text(
                    travel.countryInfos.isEmpty
                        ? ''
                        : travel.countryInfos.first.flagEmoji,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DinoText.custom(
                    text: travel.destination.join(', '),
                    fontSize: DinoTextSizeToken.text300,
                    fontWeight: FontWeight.w700,
                    color: isTodayInRange
                        ? $dinoToken.color.white
                        : isEnded
                            ? $dinoToken.color.blingGray400
                            : $dinoToken.color.blingGray700,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      DinoText.custom(
                        text: isTodayInRange
                            ? AppLocalizations.of(context)!.travelStatusOngoing
                            : isEnded
                                ? AppLocalizations.of(context)!
                                    .travelStatusCompleted
                                : AppLocalizations.of(context)!
                                    .travelStatusUpcoming,
                        fontSize: DinoTextSizeToken.text75,
                        fontWeight: FontWeight.w500,
                        color: isTodayInRange
                            ? $dinoToken.color.white
                            : isEnded
                                ? $dinoToken.color.blingGray400
                                : $dinoToken.color.brandBlingCyan600,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: DinoText.custom(
                          text: '|',
                          fontSize: DinoTextSizeToken.text75,
                          fontWeight: FontWeight.w500,
                          color: $dinoToken.color.blingGray200,
                        ),
                      ),
                      DinoText.custom(
                        text:
                            '${formatDate(travel.startDate)} ~ ${formatDate(travel.endDate)}',
                        fontSize: DinoTextSizeToken.text75,
                        fontWeight: FontWeight.w500,
                        color: isTodayInRange
                            ? $dinoToken.color.white
                            : isEnded
                                ? $dinoToken.color.blingGray400
                                : $dinoToken.color.blingGray700,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/icons/ar_right.svg',
                colorFilter: ColorFilter.mode(
                  isTodayInRange
                      ? $dinoToken.color.white.resolve(context)
                      : $dinoToken.color.blingGray400.resolve(context),
                  BlendMode.srcIn,
                ),
              ),
              // IconButton(
              //   padding: EdgeInsets.zero,
              //   constraints: const BoxConstraints(),
              //   onPressed: () {
              //     showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         title: const Text('여행 삭제'),
              //         content:
              //             const Text('이 여행을 삭제하시겠습니까?\n삭제된 여행은 복구할 수 없습니다.'),
              //         actions: [
              //           TextButton(
              //             onPressed: () {},
              //             child: const Text('취소'),
              //           ),
              //           TextButton(
              //             onPressed: () {
              //               ref
              //                   .read(travelsProvider.notifier)
              //                   .removeTravel(travel.id);
              //             },
              //             style: TextButton.styleFrom(
              //               foregroundColor: Colors.red,
              //             ),
              //             child: const Text('삭제'),
              //           ),
              //         ],
              //       ),
              //     );
              //   },
              //   icon: Icon(
              //     Icons.delete_outline,
              //     size: 18,
              //     color: $dinoToken.color.blingGray400.resolve(context),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
