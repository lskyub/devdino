import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:design_systems/dino/foundations/token.typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/components/buttons/button.dino.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelee/presentation/screens/home/first_screen.dart';
import 'package:travelee/providers/travel_state_provider.dart';
import 'package:travelee/presentation/screens/travel_detail/date_screen.dart';
import 'package:travelee/presentation/widgets/saved_travel_item.dart';
import 'dart:developer' as dev;

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
      dev.log('SavedTravelsScreen - 임시 여행 데이터 삭제: ${tempTravels.length}개');

      // 임시 여행 삭제
      for (final travel in tempTravels) {
        dev.log(
            'SavedTravelsScreen - 임시 여행 삭제: ID=${travel.id}, 목적지=${travel.destination.join(", ")}');
        ref.read(travelsProvider.notifier).removeTravel(travel.id);
      }
    } else {
      dev.log('SavedTravelsScreen - 임시 여행 데이터 없음');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    await GoogleSignIn().signOut();
    if (!mounted) return;
    context.go(FirstScreen.routePath); // 또는 원하는 라우트로 이동
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
    dev.log(
        'SavedTravelsScreen - 저장된 여행 목록: ${savedTravels.length}개 (전체: ${allTravels.length}개)');
    if (savedTravels.isNotEmpty) {
      dev.log('------- 여행 목록 상세 정보 -------');
      for (int i = 0; i < savedTravels.length; i++) {
        final travel = savedTravels[i];
        dev.log(' • 여행[$i]:');
        dev.log('   - ID: ${travel.id}');
        dev.log('   - 목적지: ${travel.destination.join(", ")}');
        dev.log('   - 기간: ${travel.startDate} ~ ${travel.endDate}');
      }
      dev.log('--------------------------------');
    }

    // savedTravels 여행 정렬 변경 시작 종료 날짜와 오늘 날짜를 비교하여 오늘 날짜가 시작 종료 날짜 사이에 있으면 위로 오도록 정렬, 날짜가 지났으면 아래로 가도록 정렬
    savedTravels.sort((a, b) {
      final today = DateTime.now();
      final aStartDate = a.startDate!;
      final aEndDate = a.endDate!;
      final bStartDate = b.startDate!;
      final bEndDate = b.endDate!;

      if (today.isAfter(aStartDate) && today.isBefore(aEndDate)) {
        return -1;
      } else if (today.isAfter(bStartDate) && today.isBefore(bEndDate)) {
        return 1;
      }
      return 0;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: null,
        title: Align(
          alignment: Alignment.centerLeft,
          child: DinoText.custom(
            fontSize: 25.63,
            text: '트래블리 로고',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 로그인 정보 삭제 후 로그인 화면으로 이동
              signOut();
            },
            icon: const Icon(Icons.search),
          ),
        ],
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
                        SvgPicture.asset(
                          'assets/icons/airplane.svg',
                        ),
                        const SizedBox(height: 24),
                        DinoText.custom(
                          fontSize: 25.63,
                          text: '어디로 떠나시나요?',
                          color: $dinoToken.color.blingGray800,
                          fontWeight: FontWeight.w700,
                          textAlign: DinoTextAlign.center,
                        ),
                        DinoText.custom(
                          fontSize: 16,
                          text: '여행지를 추가하고 일정을 정리하여\n완벽한 휴가를 즐겨보세요. ',
                          color: $dinoToken.color.blingGray500,
                          textAlign: DinoTextAlign.center,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 24),
                        DinoButton.custom(
                          type: DinoButtonType.solid,
                          title: '여행 추가하기',
                          leading: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                              'assets/icons/add_schedule.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                $dinoToken.color.white.resolve(context),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          textSize: 16,
                          radius: 28,
                          textColor: $dinoToken.color.white,
                          backgroundColor: $dinoToken.color.primary,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5E9DEA),
                              Color(0xFFF189E0),
                            ],
                          ),
                          onTap: () {
                            ref.read(currentTravelIdProvider.notifier).state =
                                '';
                            context.push(DateScreen.routePath);
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DinoText.custom(
                          fontSize: DinoTextSizeToken.text600,
                          fontWeight: FontWeight.w700,
                          color: $dinoToken.color.blingGray800,
                          text: '즐거운 여행 되세요! 🥰',
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: savedTravels.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        itemBuilder: (context, index) {
                          final travel = savedTravels[index];
                          return SavedTravelItem(
                            travel: travel,
                            formatDate: _formatDate,
                          );
                        },
                      ))
                    ],
                  ),
          ),
          if (savedTravels.isNotEmpty) ...[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DinoButton.custom(
                  type: DinoButtonType.outline,
                  size: DinoButtonSize.full,
                  title: '여행 추가하기',
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: SvgPicture.asset(
                      'assets/icons/add_schedule.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        $dinoToken.color.blingGray500.resolve(context),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  textSize: 16,
                  radius: 12,
                  width: 1,
                  fontWeight: FontWeight.w600,
                  textColor: $dinoToken.color.blingGray800,
                  backgroundColor: $dinoToken.color.white,
                  pressedBorderColor: $dinoToken.color.blingGray200,
                  disabledBorderColor: $dinoToken.color.blingGray200,
                  borderColor: $dinoToken.color.blingGray200,
                  onTap: () {
                    ref.read(currentTravelIdProvider.notifier).state = '';
                    context.push(DateScreen.routePath);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
