import 'dart:ffi';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travelee/data/models/location/country_info.dart';
import 'package:travelee/presentation/widgets/setting_item.dart';
import 'package:travelee/providers/travel_state_provider.dart';
import 'package:travelee/presentation/modal/edit_travel_dialog.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// TravelDialogManager
///
/// 여행 관련 다이얼로그를 관리하는 유틸리티 클래스
/// - 여행 일정 날짜 삭제 확인 다이얼로그
/// - 여행 정보 수정 다이얼로그 및 관련 로직 처리
/// - 국가 정보 백업 및 복원 기능 제공
class TravelDialogManager {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// 날짜 삭제 확인 다이얼로그 표시
  /// @param context 현재 빌드 컨텍스트
  /// @return 사용자 응답 (true: 삭제 승인, false: 취소)
  static Future<bool?> showDeleteDateConfirmDialog(BuildContext context) async {
    try {
      await _analytics.logEvent(
        name: 'show_delete_date_dialog',
        parameters: {'screen': 'travel_detail'},
      );

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: B2bText(
            type: DinoTextType.bodyXL,
            text: AppLocalizations.of(context)!.deleteDateTitle,
          ),
          content: B2bText(
            type: DinoTextType.bodyL,
            text: AppLocalizations.of(context)!.deleteDateMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: B2bText(
                type: DinoTextType.bodyL,
                text: AppLocalizations.of(context)!.cancel,
                color: $dinoToken.color.blingGray400.resolve(context),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: B2bText(
                type: DinoTextType.bodyXL,
                text: AppLocalizations.of(context)!.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );

      await _analytics.logEvent(
        name: 'delete_date_dialog_result',
        parameters: {
          'result': result == true ? 'confirmed' : 'cancelled',
          'screen': 'travel_detail',
        },
      );

      return result;
    } catch (e, stackTrace) {
      await _analytics.logEvent(
        name: 'delete_date_dialog_error',
        parameters: {
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
          'screen': 'travel_detail',
        },
      );
      rethrow;
    }
  }

  /// 여행 정보 수정 다이얼로그 표시 및 결과 처리
  /// @param context 현재 빌드 컨텍스트
  /// @param ref Provider 참조
  static Future<void> showEditTravelDialog(
      BuildContext context, WidgetRef ref) async {
    try {
      await _analytics.logEvent(
        name: 'show_edit_travel_dialog',
        parameters: {'screen': 'travel_detail'},
      );

      final currentTravel = ref.watch(currentTravelProvider);
      if (currentTravel == null) {
        await _analytics.logEvent(
          name: 'edit_travel_dialog_error',
          parameters: {
            'error': 'current_travel_not_found',
            'screen': 'travel_detail',
          },
        );
        return;
      }

      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          snap: true,
          snapSizes: const [0.5, 0.9],
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: EditTravelDialog(
                initialDestination: currentTravel.destination,
                initialCountryInfos: currentTravel.countryInfos,
                initialStartDate: currentTravel.startDate ?? DateTime.now(),
                initialEndDate: currentTravel.endDate ?? DateTime.now(),
              ),
            ),
          ),
        ),
      );

      if (result != null) {
        final updatedTravel = currentTravel.copyWith(
          destination: result['destination'] as List<String>,
          countryInfos: result['countryInfos'] as List<CountryInfo>,
          startDate: result['startDate'] as DateTime,
          endDate: result['endDate'] as DateTime,
        );
        ref.read(travelsProvider.notifier).updateTravel(updatedTravel);

        await _analytics.logEvent(
          name: 'edit_travel_success',
          parameters: {
            'screen': 'travel_detail',
            'has_destination': result['destination']?.isNotEmpty ?? false,
            'has_country_info': result['countryInfos']?.isNotEmpty ?? false,
          },
        );
      } else {
        await _analytics.logEvent(
          name: 'edit_travel_cancelled',
          parameters: {'screen': 'travel_detail'},
        );
      }
    } catch (e, stackTrace) {
      await _analytics.logEvent(
        name: 'edit_travel_dialog_error',
        parameters: {
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
          'screen': 'travel_detail',
        },
      );
      rethrow;
    }
  }

  /// 여행 정보 설정 다이얼로그 표시 및 결과 처리
  /// @param context 현재 빌드 컨텍스트
  /// @param ref Provider 참조
  static Future<int?> showSettingTravelDialog(
      BuildContext context, WidgetRef ref) async {
    try {
      await _analytics.logEvent(
        name: 'show_setting_travel_dialog',
        parameters: {'screen': 'travel_detail'},
      );

      final currentTravel = ref.watch(currentTravelProvider);
      if (currentTravel == null) {
        await _analytics.logEvent(
          name: 'setting_travel_dialog_error',
          parameters: {
            'error': 'current_travel_not_found',
            'screen': 'travel_detail',
          },
        );
        return null;
      }

      final result = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) => Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 28, bottom: 6, right: 16),
                  child: Row(
                    children: [
                      DinoText.custom(
                        text: AppLocalizations.of(context)!.editTravel,
                        fontSize: DinoTextSizeToken.text500,
                        fontWeight: FontWeight.w600,
                        color: $dinoToken.color.blingGray900,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.white,
                          child: SvgPicture.asset(
                            'assets/icons/popup_cancle.svg',
                            fit: BoxFit.none,
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SettingItem(
                    path: 'assets/icons/write.svg',
                    title: AppLocalizations.of(context)!.editTravelSchedule,
                    onTap: () {
                      Navigator.pop(context, 0);
                    }),
                SettingItem(
                    path: 'assets/icons/my_share_32.svg',
                    title: AppLocalizations.of(context)!.shareTravelSchedule,
                    onTap: () {
                      Navigator.pop(context, 1);
                    }),
                SettingItem(
                    path: 'assets/icons/Keylines_trash.svg',
                    title: AppLocalizations.of(context)!.deleteTravel,
                    onTap: () {
                      Navigator.pop(context, 2);
                    }),
              ],
            ),
          ),
        ),
      );

      if (result != null) {
        await _analytics.logEvent(
          name: 'setting_travel_action',
          parameters: {
            'action': result == 0
                ? 'edit_schedule'
                : result == 1
                    ? 'share_schedule'
                    : 'delete_travel',
            'screen': 'travel_detail',
          },
        );
      } else {
        await _analytics.logEvent(
          name: 'setting_travel_cancelled',
          parameters: {'screen': 'travel_detail'},
        );
      }

      return result;
    } catch (e, stackTrace) {
      await _analytics.logEvent(
        name: 'setting_travel_dialog_error',
        parameters: {
          'error': e.toString(),
          'stack_trace': stackTrace.toString(),
          'screen': 'travel_detail',
        },
      );
      rethrow;
    }
  }
}
