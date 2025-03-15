import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:travelee/utils/travel_dialog_manager.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'dart:developer' as dev;

/// 여행 상세 화면의 앱바 위젯
class TravelDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Function() onBackPressed;
  
  const TravelDetailAppBar({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(travelDetailControllerProvider);
    
    return AppBar(
      title: B2bText.bold(
        type: B2bTextType.title3,
        text: '세부 일정',
        color: $b2bToken.color.labelNomal.resolve(context),
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
        IconButton(
          onPressed: () async {
            await TravelDialogManager.showEditTravelDialog(context, ref);
            controller.setModified(); // 여행 정보 편집 후 수정 플래그 설정
          },
          icon: Icon(
            Icons.edit,
            color: $b2bToken.color.primary.resolve(context),
          ),
        ),
      ],
    );
  }
} 