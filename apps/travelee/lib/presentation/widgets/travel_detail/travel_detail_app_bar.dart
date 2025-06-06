import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'package:travelee/core/utils/travel_dialog_manager.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';

/// 여행 상세 화면의 앱바 위젯
class TravelDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Function() onBackPressed;
  final VoidCallback? onRefresh;
  final TravelModel travelInfo;

  const TravelDetailAppBar({
    super.key,
    required this.onBackPressed,
    required this.travelInfo,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(travelDetailControllerProvider);

    return AppBar(
      surfaceTintColor: Colors.transparent, // 자동 색상 변
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          B2bText(
              type: DinoTextType.bodyM,
              text:
                  '${TravelDateFormatter.formatDate(travelInfo.startDate)} ~ ${TravelDateFormatter.formatDate(travelInfo.endDate)}'),
          Row(
            children: [
              B2bText(
                type: DinoTextType.detailL,
                text: travelInfo.destination.join(', '),
                color: $dinoToken.color.blingGray500.resolve(context),
              )
            ],
          )
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed,
        icon: SvgPicture.asset(
          'assets/icons/back.svg',
          width: 27,
          height: 27,
        ),
      ),
      actions: [
        if (onRefresh != null)
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        IconButton(
          onPressed: () async {
            await TravelDialogManager.showEditTravelDialog(context, ref);
            controller.setModified(); // 여행 정보 편집 후 수정 플래그 설정
          },
          icon: Icon(
            Icons.edit,
            color: $dinoToken.color.primary.resolve(context),
          ),
        ),
      ],
    );
  }
}
