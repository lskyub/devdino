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
import 'package:travelee/core/config/supabase_config.dart';
import 'package:travelee/data/services/travel_sync_service.dart';
import 'package:travelee/data/services/ad_tracking_service.dart';
import 'package:travelee/presentation/screens/home/first_screen.dart';
import 'package:travelee/providers/loading_state_provider.dart';
import 'package:travelee/providers/travel_state_provider.dart';
import 'package:travelee/presentation/screens/travel_detail/date_screen.dart';
import 'package:travelee/presentation/widgets/saved_travel_item.dart';
import 'package:travelee/presentation/screens/settings/settings_screen.dart';
import 'package:travelee/presentation/widgets/ad_banner_widget.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'dart:developer' as dev;
import 'package:travelee/providers/ad_provider.dart';

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
      ref.read(loadingStateProvider.notifier).stopLoading();
    });

    // 광고 추적 권한 요청 및 광고 표시 상태 설정
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 광고 추적 권한 요청
      await AdTrackingService.requestTrackingAuthorization();
      // 광고 표시 상태를 true로 설정
      ref.read(adProvider.notifier).setBannerAdVisibility(true);
    });
  }

  /// 임시 여행 데이터 정리 (temp_로 시작하는 ID를 가진 여행 삭제)
  void _cleanupTempTravels() {
    final allTravels = ref.read(travelsProvider);
    final l10n = AppLocalizations.of(context)!;

    // 임시 여행 필터링
    final tempTravels =
        allTravels.where((travel) => travel.id.startsWith('temp_')).toList();

    // 임시 여행 있으면 로그 출력
    if (tempTravels.isNotEmpty) {
      dev.log(l10n.tempTravelDeleted(tempTravels.length));

      // 임시 여행 삭제
      for (final travel in tempTravels) {
        dev.log(l10n.tempTravelDeleteDetail(
            travel.id, travel.destination.join(", ")));
        ref.read(travelsProvider.notifier).removeTravel(travel.id);
      }
    } else {
      dev.log(l10n.noTempTravel);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String getTravelStatus(travel) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
        travel.startDate!.year, travel.startDate!.month, travel.startDate!.day);
    final end = DateTime(
        travel.endDate!.year, travel.endDate!.month, travel.endDate!.day);
    if (!today.isBefore(start) && !today.isAfter(end)) {
      return l10n.travelStatusOngoing;
    } else if (today.isBefore(start)) {
      return l10n.travelStatusUpcoming;
    } else {
      return l10n.travelStatusCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    // 저장된 여행 불러오기
    final allTravels = ref.watch(travelsProvider);

    // 임시 여행 제외한 목록만 필터링
    final savedTravels =
        allTravels.where((travel) => !travel.id.startsWith('temp_')).toList();

    // 생성일 기준으로 최신순 정렬
    savedTravels.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 여행 상태 기준 정렬: 여행 중 > 여행 예정 > 여행 완료
    int statusOrder(String status) {
      if (status == '여행 중') return 0;
      if (status == '여행 예정') return 1;
      return 2; // 여행 완료
    }

    savedTravels.sort((a, b) {
      final aStatus = getTravelStatus(a);
      final bStatus = getTravelStatus(b);
      final cmp = statusOrder(aStatus).compareTo(statusOrder(bStatus));
      if (cmp != 0) return cmp;
      // 같은 상태 내 정렬
      if (aStatus == '여행 예정' && bStatus == '여행 예정') {
        // 가까운 시작일이 위로
        return a.startDate!.compareTo(b.startDate!);
      }
      // 그 외(여행중/완료)는 최신순
      return b.startDate!.compareTo(a.startDate!);
    });

    // 저장된 여행 목록 로깅 (상세 정보 포함)
    final l10n = AppLocalizations.of(context)!;
    dev.log(l10n.savedTravelList(savedTravels.length, allTravels.length));
    if (savedTravels.isNotEmpty) {
      dev.log('------- ${l10n.travelListDetail} -------');
      for (int i = 0; i < savedTravels.length; i++) {
        final travel = savedTravels[i];
        dev.log(' • 여행[$i]:');
        dev.log('   - ID: ${travel.id}');
        dev.log('   - 목적지: ${travel.destination.join(", ")}');
        dev.log('   - 기간: ${travel.startDate} ~ ${travel.endDate}');
      }
      dev.log('--------------------------------');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: null,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SvgPicture.asset(
                local.localeName == 'ko'
                    ? 'assets/icons/logotype_travelee.svg'
                    : 'assets/icons/logotype_travelee_e.svg',
                width: 72,
                height: 18,
                colorFilter: ColorFilter.mode(
                  $dinoToken.color.blingGray800.resolve(context),
                  BlendMode.srcIn,
                ),
              ),
              Image.asset(
                'assets/images/travelee_airplain.png',
                width: 32,
                height: 32,
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.push(SettingsScreen.routePath);
            },
            child: SvgPicture.asset(
              'assets/icons/home_mysetting.svg',
            ),
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
                        Image.asset(
                          'assets/images/travel_carrier.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 24),
                        DinoText.custom(
                          fontSize: 25.63,
                          text: AppLocalizations.of(context)!.whereToGo,
                          color: $dinoToken.color.blingGray800,
                          fontWeight: FontWeight.w700,
                          textAlign: DinoTextAlign.center,
                        ),
                        DinoText.custom(
                          fontSize: 16,
                          text: AppLocalizations.of(context)!
                              .organizeTravelMessage,
                          color: $dinoToken.color.blingGray500,
                          textAlign: DinoTextAlign.center,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 24),
                        DinoButton.custom(
                          type: DinoButtonType.solid,
                          title: AppLocalizations.of(context)!.addTravelButton,
                          leading: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                              'assets/icons/add_schedule.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                $dinoToken.color.white.resolve(context),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          verticalPadding: 20,
                          horizontalPadding: 32,
                          textSize: 16,
                          radius: 40,
                          textColor: $dinoToken.color.white,
                          fontWeight: FontWeight.w700,
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
                          text: AppLocalizations.of(context)!
                              .enjoyYourTripMessage,
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
          if (savedTravels.isEmpty) const SafeArea(child: AdBannerWidget()),
          if (savedTravels.isNotEmpty) ...[
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DinoButton.custom(
                      type: DinoButtonType.outline,
                      size: DinoButtonSize.full,
                      title: AppLocalizations.of(context)!.addTravelButton,
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
                  const AdBannerWidget(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
