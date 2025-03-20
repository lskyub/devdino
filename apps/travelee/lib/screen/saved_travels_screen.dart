import 'package:design_systems/dino/foundations/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/text/text.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/router.dart';
import 'package:travelee/screen/input/date_screen.dart';
import 'package:travelee/screen/components/saved_travel_item.dart';
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
    final tempTravels =
        allTravels.where((travel) => travel.id.startsWith('temp_')).toList();

    // 임시 여행 있으면 로그 출력
    if (tempTravels.isNotEmpty) {
      print('SavedTravelsScreen - 임시 여행 데이터 삭제: ${tempTravels.length}개');

      // 임시 여행 삭제
      for (final travel in tempTravels) {
        print(
            'SavedTravelsScreen - 임시 여행 삭제: ID=${travel.id}, 목적지=${travel.destination.join(", ")}');
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
    final savedTravels =
        allTravels.where((travel) => !travel.id.startsWith('temp_')).toList();

    // 생성일 기준으로 최신순 정렬
    savedTravels.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 저장된 여행 목록 로깅 (상세 정보 포함)
    print(
        'SavedTravelsScreen - 저장된 여행 목록: ${savedTravels.length}개 (전체: ${allTravels.length}개)');
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
        surfaceTintColor: Colors.transparent,
        leading: null,
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $dinoToken.color.primary.resolve(context),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: savedTravels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flight,
                          size: 48,
                          color: $dinoToken.color.blingGray400.resolve(context),
                        ),
                        const SizedBox(height: 16),
                        DinoText(
                          type: DinoTextType.bodyL,
                          text: '저장된 여행이 없습니다',
                          color: $dinoToken.color.blingGray400.resolve(context),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: savedTravels.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final travel = savedTravels[index];
                      return SavedTravelItem(
                        travel: travel,
                        formatDate: _formatDate,
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(currentTravelIdProvider.notifier).state = '';
                  context.push(DateScreen.routePath);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: $dinoToken.color.primary.resolve(context),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/bytesize_plus.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('여행 추가하기'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
