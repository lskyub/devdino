import 'package:flutter/material.dart';
import 'package:travelee/components/travel_info_summary.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/utils/travel_date_formatter.dart';

/// 여행 상세 화면의 상단 여행 정보 섹션
class TravelInfoSection extends StatelessWidget {
  final TravelModel travelInfo;

  const TravelInfoSection({
    super.key,
    required this.travelInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TravelInfoSummary(
            destination: travelInfo.destination.join(', '),
            startDate: travelInfo.startDate,
            endDate: travelInfo.endDate,
            formatDate: TravelDateFormatter.formatDate,
          ),
        ],
      ),
    );
  }
} 