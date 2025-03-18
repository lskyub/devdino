import 'package:flutter/material.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';

/// TravelInfoSummary
/// 
/// 여행 정보를 요약하여 표시하는 컴포넌트
/// - 여행 목적지 정보 표시
/// - 여행 시작일과 종료일 표시
/// - 정보를 시각적으로 구분된 카드 형태로 제공
class TravelInfoSummary extends StatelessWidget {
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final String Function(DateTime?) formatDate;

  const TravelInfoSummary({
    super.key,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: $b2bToken.color.gray100.resolve(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: $b2bToken.color.primary.resolve(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: B2bText.regular(
                  type: B2bTextType.body2,
                  text: destination,
                  color: $b2bToken.color.gray500.resolve(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: $b2bToken.color.primary.resolve(context),
              ),
              const SizedBox(width: 8),
              B2bText.regular(
                type: B2bTextType.body2,
                text: '${formatDate(startDate)} ~ ${formatDate(endDate)}',
                color: $b2bToken.color.gray500.resolve(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 