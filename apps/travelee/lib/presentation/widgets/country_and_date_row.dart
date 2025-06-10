import 'package:flutter/material.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:travelee/domain/entities/country_info.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';

/// 나라정보와 날짜 정보를 한 줄에 노출하는 위젯
///
/// - 나라정보(깃발+이름)는 왼쪽 정렬, 날짜는 오른쪽 고정
/// - 나라정보가 길어지면 ellipsis(기본 '...')로 대체
/// - ellipsis는 커스텀 위젯으로 지정 가능
/// - TextPainter로 overflow 체크
class CountryAndDateRow extends StatelessWidget {
  final List<CountryInfo> countryInfos;
  final String dateText;
  final Widget? ellipsisWidget;
  final FontWeight? countryFontWeight;
  final TextStyle? dateTextStyle;

  const CountryAndDateRow({
    super.key,
    required this.countryInfos,
    required this.dateText,
    this.ellipsisWidget,
    this.countryFontWeight,
    this.dateTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 날짜 텍스트 width 측정
        final dateTextWidget = Text(
          dateText,
          style: dateTextStyle ??
              const TextStyle(fontSize: 13, color: Colors.grey),
        );
        final dateTextPainter = TextPainter(
          text: TextSpan(
              text: dateText,
              style: dateTextStyle ??
                  const TextStyle(fontSize: 13, color: Colors.grey)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final dateWidth = dateTextPainter.width;
        final availableWidth = constraints.maxWidth - dateWidth - 8;

        // 나라정보 위젯 리스트 생성 및 width 측정
        final List<Widget> countryWidgets = [];
        double totalWidth = 0;
        int showCount = 0;
        for (int i = 0; i < countryInfos.length; i++) {
          final info = countryInfos[i];
          // flag + name width 측정
          final flagPainter = TextPainter(
            text: TextSpan(
                text: info.flagEmoji,
                style: const TextStyle(fontSize: DinoTextSizeToken.text300)),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          final namePainter = TextPainter(
            text: TextSpan(
                text: info.name,
                style: const TextStyle(fontSize: DinoTextSizeToken.text100)),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          double itemWidth = flagPainter.width + 4 + namePainter.width;
          if (i != 0) itemWidth += 12; // '/' 구분자 padding
          if (totalWidth + itemWidth > availableWidth) break;
          // 위젯 추가
          if (i != 0) {
            countryWidgets.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: DinoText.custom(
                text: '/',
                fontSize: DinoTextSizeToken.text75,
                color: $dinoToken.color.blingGray500,
              ),
            ));
          }
          countryWidgets.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.flagEmoji,
                  style: const TextStyle(fontSize: DinoTextSizeToken.text300)),
              const SizedBox(width: 4),
              DinoText.custom(
                fontSize: DinoTextSizeToken.text100,
                text: info.name,
                color: $dinoToken.color.blingGray900,
                fontWeight: countryFontWeight,
              ),
            ],
          ));
          totalWidth += itemWidth;
          showCount++;
        }
        // overflow 시 ellipsis 추가
        final bool isOverflow = showCount < countryInfos.length;
        if (isOverflow) {
          countryWidgets.add(Padding(
            padding: const EdgeInsets.only(left: 3),
            child: ellipsisWidget ??
                DinoText.custom(
                  text: '..',
                  fontSize: DinoTextSizeToken.text100,
                  color: $dinoToken.color.blingGray900,
                ),
          ));
        }
        if (isOverflow) {
          // overflow: 날짜는 오른쪽 고정
          return Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: countryWidgets,
                ),
              ),
              const SizedBox(width: 8),
              dateTextWidget,
            ],
          );
        } else {
          // overflow 아님: 나라정보 바로 옆에 날짜
          countryWidgets.add(const SizedBox(width: 8));
          countryWidgets.add(dateTextWidget);
          return Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: countryWidgets,
              ),
            ],
          );
        }
      },
    );
  }
}
