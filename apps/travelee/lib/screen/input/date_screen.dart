import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mix/mix.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:travelee/providers/travel_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/input/travel_detail_screen.dart';

class DateScreen extends ConsumerWidget {
  static const routeName = 'date';
  static const routePath = '/date';

  const DateScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelInfo = ref.watch(travelInfoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $b2bToken.color.primary.resolve(context),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: B2bText.medium(
              type: B2bTextType.body1,
              text: '여행 기간을 선택하세요.',
              color: $b2bToken.color.labelNomal.resolve(context),
            ),
          ),
          FlexBox(
            direction: Axis.vertical,
            children: [
              SfDateRangePicker(
                backgroundColor: Colors.white,
                minDate: DateTime(DateTime.now().year - 1),
                maxDate: DateTime(DateTime.now().year + 5),
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    ref.read(travelInfoProvider.notifier).setDates( 
                          args.value.startDate,
                          args.value.endDate,
                        );
                  }
                },
                selectionMode: DateRangePickerSelectionMode.range,
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle:
                      $b2bToken.textStyle.body4regular.resolve(context).merge(
                            TextStyle(
                              color: $b2bToken.color.gray500.resolve(context),
                            ),
                          ),
                  todayTextStyle:
                      $b2bToken.textStyle.body4regular.resolve(context).merge(
                            TextStyle(
                              color: $b2bToken.color.gray500.resolve(context),
                            ),
                          ),
                ),
                startRangeSelectionColor:
                    $b2bToken.color.violet200.resolve(context),
                endRangeSelectionColor:
                    $b2bToken.color.violet200.resolve(context),
                rangeSelectionColor: $b2bToken.color.violet200.resolve(context),
                selectionTextStyle:
                    $b2bToken.textStyle.body4regular.resolve(context).merge(
                          TextStyle(
                            color: $b2bToken.color.primary.resolve(context),
                          ),
                        ),
                rangeTextStyle:
                    $b2bToken.textStyle.body4regular.resolve(context).merge(
                          TextStyle(
                            color: $b2bToken.color.primary.resolve(context),
                          ),
                        ),
                todayHighlightColor: $b2bToken.color.primary.resolve(context),
                selectionColor: $b2bToken.color.primary.resolve(context),
                allowViewNavigation: false,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.end,
                  backgroundColor: Colors.white,
                  textStyle:
                      $b2bToken.textStyle.body1medium.resolve(context).merge(
                            TextStyle(
                              color: $b2bToken.color.primary.resolve(context),
                            ),
                          ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  enableSwipeSelection: false,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      B2bText.medium(
                        type: B2bTextType.body4,
                        text: '시작일',
                      ),
                      B2bText.regular(
                        type: B2bTextType.body2,
                        text: _formatDate(travelInfo.startDate),
                        color: $b2bToken.color.gray500.resolve(context),
                      ),
                      Divider(
                        color: $b2bToken.color.gray100.resolve(context),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      B2bText.medium(
                        type: B2bTextType.body4,
                        text: '종료일',
                      ),
                      B2bText.regular(
                        type: B2bTextType.body2,
                        text: _formatDate(travelInfo.endDate),
                        color: $b2bToken.color.gray500.resolve(context),
                      ),
                      Divider(
                        color: $b2bToken.color.gray100.resolve(context),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 85,
            ),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                title: '새 여행 만들기',
                type: B2bButtonType.primary,
                onTap: () {
                  GoRouter.of(context).push(TravelDetailScreen.routePath);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
