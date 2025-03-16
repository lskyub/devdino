import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:travelee/models/day_schedule_data.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/models/schedule.dart';
import 'dart:developer' as dev;

// 일정 탭 콜백 정의
typedef ScheduleTapCallback = void Function(DateTime date, int dayNumber);

// 현재 선택된 인덱스 저장용 Provider
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class DaySchedulesList extends ConsumerStatefulWidget {
  final TravelModel travelInfo;
  final List<DayScheduleData> daySchedules;
  final ScheduleTapCallback? onScheduleTap;

  const DaySchedulesList({
    Key? key,
    required this.travelInfo,
    required this.daySchedules,
    this.onScheduleTap,
  }) : super(key: key);

  @override
  ConsumerState<DaySchedulesList> createState() => _DaySchedulesListState();
}

class _DaySchedulesListState extends ConsumerState<DaySchedulesList> {
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    
    // 일정이 비어있는 경우 처리
    if (widget.daySchedules.isEmpty) {
      return const Center(
        child: Text('표시할 일정이 없습니다.'),
      );
    }
    
    // 선택된 인덱스가 범위를 벗어나는 경우 처리
    final validIndex = selectedIndex < widget.daySchedules.length 
        ? selectedIndex 
        : 0;
    
    return Column(
      children: [
        // 날짜 탭 바
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.daySchedules.length,
            itemBuilder: (context, index) {
              final day = widget.daySchedules[index];
              return _buildDayTab(context, index, day, validIndex);
            },
          ),
        ),
        
        // 날짜별 일정 페이지
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.daySchedules.length,
            onPageChanged: (index) {
              ref.read(selectedIndexProvider.notifier).state = index;
            },
            itemBuilder: (context, index) {
              final dayData = widget.daySchedules[index];
              return _buildDayContent(context, dayData);
            },
          ),
        ),
      ],
    );
  }
  
  // 날짜 탭 위젯 구성
  Widget _buildDayTab(BuildContext context, int index, DayScheduleData day, int selectedIndex) {
    final isSelected = index == selectedIndex;
    
    return GestureDetector(
      onTap: () {
        ref.read(selectedIndexProvider.notifier).state = index;
        _pageController.animateToPage(
          index, 
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? $b2bToken.color.primary.resolve(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? $b2bToken.color.primary.resolve(context)
                : $b2bToken.color.gray300.resolve(context),
          ),
        ),
        child: Row(
          children: [
            Text(
              day.flagEmoji ?? '🏳️',  // null 체크 및 기본값 제공
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(
              'Day ${day.dayNumber}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 날짜별 일정 내용 위젯 구성
  Widget _buildDayContent(BuildContext context, DayScheduleData day) {
    return Column(
      children: [
        // 날짜 정보 및 일정 추가 버튼
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(day.date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          day.flagEmoji ?? '🏳️',  // null 체크 및 기본값 제공
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          day.countryName ?? '국가 미지정',  // null 체크 및 기본값 제공
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.onScheduleTap != null) {
                    dev.log('DaySchedulesList - 일정으로 이동: ${day.date}, Day ${day.dayNumber}');
                    widget.onScheduleTap!(day.date, day.dayNumber);
                  }
                },
                icon: const Icon(Icons.edit_calendar, size: 16),
                label: const Text('일정 관리'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: $b2bToken.color.primary.resolve(context),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // 일정 목록
        Expanded(
          child: day.schedules.isEmpty
              ? _buildEmptyState(context, day)
              : _buildScheduleList(context, day),
        ),
      ],
    );
  }
  
  // 일정이 없을 때 표시할 위젯
  Widget _buildEmptyState(BuildContext context, DayScheduleData day) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 48,
            color: $b2bToken.color.gray300.resolve(context),
          ),
          const SizedBox(height: 12),
          Text(
            '등록된 일정이 없습니다',
            style: TextStyle(
              color: $b2bToken.color.gray400.resolve(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (widget.onScheduleTap != null) {
                widget.onScheduleTap!(day.date, day.dayNumber);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: $b2bToken.color.primary.resolve(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('일정 추가하기'),
          ),
        ],
      ),
    );
  }
  
  // 일정 목록 위젯
  Widget _buildScheduleList(BuildContext context, DayScheduleData day) {
    if (day.schedules.isEmpty) {
      return _buildEmptyState(context, day);
    }
    
    // 시간 순으로 일정 정렬
    final schedules = List<Schedule>.from(day.schedules)
      ..sort((a, b) {
        // null 체크 후 시간 비교
        final aTime = a.time != null ? a.time!.hour * 60 + a.time!.minute : 0;
        final bTime = b.time != null ? b.time!.hour * 60 + b.time!.minute : 0;
        return aTime.compareTo(bTime);
      });
      
    return ListView.builder(
      itemCount: schedules.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        
        // null 체크 추가
        if (schedule == null) {
          return const SizedBox.shrink();
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (widget.onScheduleTap != null) {
                widget.onScheduleTap!(day.date, day.dayNumber);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시간 (null 체크 추가)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: $b2bToken.color.gray100.resolve(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.time != null 
                          ? '${schedule.time!.hour.toString().padLeft(2, '0')}:${schedule.time!.minute.toString().padLeft(2, '0')}'
                          : '--:--',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: $b2bToken.color.primary.resolve(context),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 장소 및 메모
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.location ?? '위치 미지정',  // null 체크 추가
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (schedule.memo != null && schedule.memo!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            schedule.memo!,
                            style: TextStyle(
                              color: $b2bToken.color.gray600.resolve(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 날짜 형식화 헬퍼 메서드
  String _formatDate(DateTime date) {
    if (date == null) return '날짜 미지정';
    
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    
    try {
      final weekday = weekdays[date.weekday - 1]; // 월요일이 1, 일요일이 7
      return '${date.year}년 ${months[date.month - 1]} ${date.day}일 ($weekday)';
    } catch (e) {
      // 날짜 형식화 중 오류 발생시 기본 포맷 사용
      return '${date.year}-${date.month}-${date.day}';
    }
  }
} 