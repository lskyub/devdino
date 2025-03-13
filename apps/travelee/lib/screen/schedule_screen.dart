import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/textfield/textfield.dart';
import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mix/mix.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:design_systems/b2b/b2b.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static const routeName = 'schedule';
  static const routePath = '/schedule';

  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String start = '-';
  String end = '-';

  List<String> items = ['테스트 0'];

  @override
  void initState() {
    super.initState();
    // try {
    //   items = List.generate(int.parse(length), (index) => '$label $index');
    // } catch (e) {}
    // var visible = 3;
    // try {
    //   visible = int.parse(
    //       context.knobs.string(label: 'Max Visible Count', initialValue: '3'));
    // } catch (e) {}
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('새 여행 만들기'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlexBox(
            direction: Axis.vertical,
            children: [
              SfDateRangePicker(
                backgroundColor: Colors.white,
                minDate: DateTime(DateTime.now().year - 1),
                maxDate: DateTime(DateTime.now().year + 5),
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    if (args.value is PickerDateRange) {
                      start = _formatDate(args.value.startDate);
                      end = _formatDate(args.value.endDate);
                    }
                  });
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
                  backgroundColor: Colors.white,
                  textStyle:
                      $b2bToken.textStyle.title1bold.resolve(context).merge(
                            TextStyle(
                              color: $b2bToken.color.primary.resolve(context),
                            ),
                          ),
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  enableSwipeSelection: false,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          B2bText.bold(
                            type: B2bTextType.body4,
                            text: '시작일',
                          ),
                          B2bText.regular(
                            type: B2bTextType.body2,
                            text: start,
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
                          B2bText.bold(
                            type: B2bTextType.body4,
                            text: '종료일',
                          ),
                          B2bText.regular(
                            type: B2bTextType.body2,
                            text: end,
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
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: B2bTextField(
              status: B2bTextFieldStatus.before,
              size: B2bTextFieldSize.medium,
              hint: '여행 목적지 검색',
              isError: false,
              defaultColor: $b2bToken.color.gray100.resolve(context),
              writeColor: $b2bToken.color.primary.resolve(context),
            ),
          ),
          Flexible(
            flex: 1,
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: B2bText.regular(
                    type: B2bTextType.body4,
                    text: '테스트 $index',
                  ),
                );
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                title: '새 여행 만들기',
                type: B2bButtonType.primary,
                onTap: () {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
