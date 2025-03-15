import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/screen/input/destination_screen.dart';
import 'package:travelee/screen/input/travel_detail_screen.dart' as input_screens;
import 'dart:math' as Math;

class SavedTravelsScreen extends ConsumerStatefulWidget {
  static const routeName = 'saved_travels';
  static const routePath = '/saved_travels';

  const SavedTravelsScreen({super.key});

  @override
  ConsumerState<SavedTravelsScreen> createState() => _SavedTravelsScreenState();
}

class _SavedTravelsScreenState extends ConsumerState<SavedTravelsScreen> {
  @override
  void initState() {
    super.initState();
    
    // 화면이 로드된 후 임시 여행 데이터 정리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cleanupTempTravels();
    });
  }
  
  /// 임시 여행 데이터 정리 (temp_로 시작하는 ID를 가진 여행 삭제)
  void _cleanupTempTravels() {
    final allTravels = ref.read(travelsProvider);
    
    // 임시 여행 필터링
    final tempTravels = allTravels.where((travel) => 
      travel.id.startsWith('temp_')).toList();
    
    // 임시 여행 있으면 로그 출력
    if (tempTravels.isNotEmpty) {
      print('SavedTravelsScreen - 임시 여행 데이터 삭제: ${tempTravels.length}개');
      
      // 임시 여행 삭제
      for (final travel in tempTravels) {
        print('SavedTravelsScreen - 임시 여행 삭제: ID=${travel.id}, 목적지=${travel.destination.join(", ")}');
        ref.read(travelsProvider.notifier).removeTravel(travel.id);
      }
    } else {
      print('SavedTravelsScreen - 임시 여행 데이터 없음');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 저장된 여행 불러오기
    final allTravels = ref.watch(travelsProvider);
    
    // 임시 여행 제외한 목록만 필터링
    final savedTravels = allTravels.where((travel) => 
      !travel.id.startsWith('temp_')).toList();
    
    // 저장된 여행 목록 로깅 (상세 정보 포함)
    print('SavedTravelsScreen - 저장된 여행 목록: ${savedTravels.length}개 (전체: ${allTravels.length}개)');
    if (savedTravels.isNotEmpty) {
      print('------- 여행 목록 상세 정보 -------');
      for (int i = 0; i < savedTravels.length; i++) {
        final travel = savedTravels[i];
        print(' • 여행[$i]:');
        print('   - ID: ${travel.id}');
        print('   - 목적지: ${travel.destination.join(", ")}');
        print('   - 기간: ${travel.startDate} ~ ${travel.endDate}');
      }
      print('--------------------------------');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $b2bToken.color.primary.resolve(context),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(currentTravelIdProvider.notifier).state = '';
          context.push(DestinationScreen.routePath);
        },
        backgroundColor: $b2bToken.color.primary.resolve(context),
        child: SvgPicture.asset(
          'assets/icons/bytesize_plus.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      body: savedTravels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flight,
                    size: 48,
                    color: $b2bToken.color.gray400.resolve(context),
                  ),
                  const SizedBox(height: 16),
                  B2bText.medium(
                    type: B2bTextType.body2,
                    text: '저장된 여행이 없습니다',
                    color: $b2bToken.color.gray400.resolve(context),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedTravels.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final travel = savedTravels[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: $b2bToken.color.gray200.resolve(context),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(currentTravelIdProvider.notifier).state = travel.id;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => input_screens.TravelDetailScreen(key: UniqueKey()),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: $b2bToken.color.primary
                                        .resolve(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: B2bText.medium(
                                      type: B2bTextType.body2,
                                      text: travel.destination.join(', '),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('여행 삭제'),
                                          content: const Text('이 여행을 삭제하시겠습니까?\n삭제된 여행은 복구할 수 없습니다.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                context.pop();
                                              },
                                              child: const Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref.read(travelsProvider.notifier).removeTravel(travel.id);
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
                                      color: $b2bToken.color.gray400.resolve(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: $b2bToken.color.primary
                                        .resolve(context),
                                  ),
                                  const SizedBox(width: 8),
                                  B2bText.regular(
                                    type: B2bTextType.body2,
                                    text:
                                        '${_formatDate(travel.startDate)} ~ ${_formatDate(travel.endDate)}',
                                    color: $b2bToken.color.gray500
                                        .resolve(context),
                                  ),
                                ],
                              ),
                              // 디버그용 ID 정보 표시
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: $b2bToken.color.gray400.resolve(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: B2bText.regular(
                                      type: B2bTextType.caption1,
                                      text: 'ID: ${travel.id.substring(0, Math.min(travel.id.length, 16))}...',
                                      color: $b2bToken.color.gray400.resolve(context),
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
              },
            ),
    );
  }
}
