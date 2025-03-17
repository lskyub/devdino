import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/saved_travels_screen.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'dart:developer' as dev;

/// 여행 상세 화면의 하단 액션 버튼
class TravelActionButton extends ConsumerWidget {
  const TravelActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(travelDetailControllerProvider);
    final travelInfo = controller.currentTravel;
    
    if (travelInfo == null) {
      return const SizedBox.shrink(); // 여행 정보가 없으면 버튼 표시 안 함
    }
    
    // 신규 여행인지 확인
    final isNewTravel = controller.isNewTravel();
    
    // 디버깅용 더 상세한 로그
    dev.log('TravelActionButton - 버튼 로직: ID=${travelInfo.id}, isNewTravel=$isNewTravel');
    
    // 버튼 텍스트 설정
    final buttonText = isNewTravel ? '새 여행 저장하기' : '수정 완료';
    
    dev.log('TravelActionButton - 버튼 생성: isNewTravel=$isNewTravel, 버튼 텍스트=$buttonText');
    
    // 수정 완료일 때는 버튼 숨김
    if (!isNewTravel) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: B2bButton.medium(
          title: buttonText,
          type: B2bButtonType.primary,
          onTap: () => _handleButtonTap(context, ref),
        ),
      ),
    );
  }
  
  /// 버튼 탭 핸들러
  void _handleButtonTap(BuildContext context, WidgetRef ref) {
    final controller = ref.read(travelDetailControllerProvider);
    final travelInfo = controller.currentTravel;
    
    if (travelInfo == null) return;
    
    final isNewTravel = controller.isNewTravel();
    dev.log('TravelActionButton - 수정/저장 버튼 클릭: isNewTravel=$isNewTravel');
    
    if (isNewTravel) {
      dev.log('TravelActionButton - 새 여행 저장 시작: 목적지=${travelInfo.destination.join(", ")}, 기간=${travelInfo.startDate} ~ ${travelInfo.endDate}');
      
      // 임시 ID로 된 여행을 영구 저장하기
      final currentId = ref.read(currentTravelIdProvider);
      
      if (currentId.isNotEmpty && currentId.startsWith('temp_')) {
        // temp_ 접두사 제거하고 영구 저장
        final newId = controller.saveTempTravel(currentId);
        
        if (newId != null) {
          dev.log('TravelActionButton - 임시 여행 ID 변경됨: $currentId -> $newId');
          
          // 현재 ID 업데이트
          ref.read(currentTravelIdProvider.notifier).state = newId;
          
          // 백업 다시 생성
          controller.createBackup();
          
          // 변경 플래그 초기화
          controller.hasChanges = false;
          
          // 저장된 여행 화면으로 이동
          context.go(SavedTravelsScreen.routePath);
          return;
        }
      }
      
      // 기존 방식으로도 처리 (ID가 비어있는 경우 등)
      ref.read(travelsProvider.notifier).commitChanges();
      context.go(SavedTravelsScreen.routePath);
    } else {
      dev.log('TravelActionButton - 기존 여행 수정 완료: ID=${travelInfo.id}');
      
      // 변경 사항 저장
      ref.read(travelsProvider.notifier).commitChanges();
      
      // 새 백업 생성
      controller.createBackup();
      
      // 변경 사항 플래그 초기화
      controller.hasChanges = false;
      
      context.pop();
    }
  }
} 