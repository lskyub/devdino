import 'package:flutter/material.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/models/day_schedule_data.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/screen/input/schedule_detail_screen.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:country_icons/country_icons.dart';

/**
 * TravelDayCard
 * 
 * 여행 일정의 날짜별 카드를 표시하는 컴포넌트
 * - 날짜별 일정 정보 표시
 * - 드래그 앤 드롭 기능 지원
 * - 일정 삭제 기능 제공
 * - 날짜 카드 클릭 시 상세 일정 화면으로 이동
 */
class TravelDayCard extends ConsumerWidget {
  final DayScheduleData daySchedule;
  final Function(Map<String, dynamic>) onAccept;
  final VoidCallback onDeletePressed;
  final String Function(DateTime) formatDate;
  final bool isDraggable;

  const TravelDayCard({
    Key? key,
    required this.daySchedule,
    required this.onAccept,
    required this.onDeletePressed,
    required this.formatDate,
    this.isDraggable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 여행 정보 가져오기
    final travelInfo = ref.watch(currentTravelProvider);

    // 날짜 키 생성
    final dateKey = formatDate(daySchedule.date);

    // 최신 dayData 정보 가져오기
    final latestDayData = travelInfo?.dayDataMap[dateKey];

    // 최신 국가 정보 (없으면 daySchedule의 기본값 사용)
    final countryName = latestDayData?.countryName ?? daySchedule.countryName;
    final countryCode = latestDayData?.countryCode ?? daySchedule.countryCode;

    // 디버그 로그
    print(
        'TravelDayCard - build: 날짜=$dateKey, 국가=$countryName, 코드=$countryCode');

    // 드래그 가능 여부에 따라 다른 컨텐츠 반환
    return isDraggable
        ? _buildDraggableContent(context, ref, countryName, countryCode)
        : _buildStaticContent(context, countryName, countryCode);
  }

  Widget _buildDraggableContent(BuildContext context, WidgetRef ref,
      String countryName, String countryCode) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<Map<String, dynamic>>(
          data: {
            'scheduleIds': daySchedule.schedules.map((s) => s.id).toList(),
            'date': daySchedule.date,
            'dayNumber': daySchedule.dayNumber,
            'country': countryName,
            'countryCode': countryCode,
          },
          feedback: _buildCardFeedback(context, countryName, countryCode),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildCardContent(context, ref, countryName, countryCode,
                isAccepting: false),
          ),
          child: _buildCardContent(
            context,
            ref,
            countryName,
            countryCode,
            isAccepting: candidateData.isNotEmpty,
          ),
        );
      },
    );
  }

  Widget _buildStaticContent(
      BuildContext context, String countryName, String countryCode) {
    // 상위 빌드 메서드에서 ref를 받아오기 때문에 WidgetRef를 파라미터로 전달할 수 없음
    // Consumer 위젯으로 감싸서 ref에 접근
    return Consumer(
      builder: (context, ref, child) {
        return _buildCardContent(context, ref, countryName, countryCode,
            isAccepting: false);
      },
    );
  }

  Widget _buildCardFeedback(
      BuildContext context, String countryName, String countryCode) {
    return Opacity(
      opacity: 0.8,
      child: Material(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          // 여기서도 ref가 필요하지만 실제로는 사용하지 않으므로 피드백에서는 일부 기능 제한
          child: Consumer(
            builder: (context, ref, child) {
              return _buildCardContent(context, ref, countryName, countryCode,
                  isAccepting: false);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, WidgetRef ref,
      String countryName, String countryCode,
      {required bool isAccepting}) {
    return GestureDetector(
      onTap: () async {
        // 현재 여행 ID 가져오기
        final travelId = ref.read(currentTravelIdProvider);
        if (travelId.isEmpty) return;

        // 스케줄 상세 화면으로 이동
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleDetailScreen(
              date: daySchedule.date,
              dayNumber: daySchedule.dayNumber,
            ),
          ),
        );

        // 결과 확인 및 로깅
        if (result != null && result is Map<String, dynamic>) {
          print('TravelDayCard - ScheduleDetailScreen 결과: $result');

          // 다음 키들이 있는지 확인
          final updatedCountry = result.containsKey('country')
              ? result['country'] as String?
              : null;
          final updatedCode = result.containsKey('countryCode')
              ? result['countryCode'] as String?
              : null;
          final updatedFlag =
              result.containsKey('flag') ? result['flag'] as String? : null;

          if (updatedCountry != null) {
            print(
                'TravelDayCard - 국가 정보 업데이트: $updatedCountry ${updatedCode ?? "코드 없음"} ${updatedFlag ?? "플래그 없음"}');
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAccepting
              ? $b2bToken.color.primary.resolve(context).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccepting
                ? $b2bToken.color.primary.resolve(context)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: $b2bToken.color.gray100.resolve(context),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: $b2bToken.color.gray100.resolve(context),
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: CountryIcons.getSvgFlag(countryCode),
                            ),
                          ),
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        B2bText.bold(
                          type: B2bTextType.body1,
                          text: 'D${daySchedule.dayNumber}',
                          color: $b2bToken.color.white.resolve(context),
                        )
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        B2bText.regular(
                          type: B2bTextType.caption1,
                          text: countryName,
                          color: $b2bToken.color.labelNomal.resolve(context),
                        ),
                        B2bText.medium(
                          type: B2bTextType.body2,
                          text: formatDate(daySchedule.date),
                          color: $b2bToken.color.labelNomal.resolve(context),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: $b2bToken.color.primary.resolve(context),
                    size: 20,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: onDeletePressed,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // if (countryName.isNotEmpty)
            //   Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //     decoration: BoxDecoration(
            //       color: $b2bToken.color.gray100.resolve(context),
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child:,
            //   ),
            // const SizedBox(height: 16),
            if (daySchedule.schedules.isEmpty) ...[
              B2bText.regular(
                type: B2bTextType.body4,
                text: '아직 일정이 없습니다. 탭하여 일정을 추가하세요.',
                color: $b2bToken.color.gray400.resolve(context),
              ),
            ] else ...[
              ...daySchedule.schedules
                  .map((schedule) => _buildScheduleItem(context, schedule))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, Schedule schedule) {
    // 시간 포맷
    final timeStr =
        '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: $b2bToken.color.gray100.resolve(context),
              borderRadius: BorderRadius.circular(15),
            ),
            child: B2bText.medium(
              type: B2bTextType.body3,
              text: timeStr,
              color: $b2bToken.color.labelNomal.resolve(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: B2bText.regular(
              type: B2bTextType.body3,
              text: schedule.location,
              color: $b2bToken.color.labelNomal.resolve(context),
            ),
          ),
        ],
      ),
    );
  }
}
