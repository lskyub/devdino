import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_picker/country_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:travelee/models/country_info.dart';

class EditTravelDialog extends StatefulWidget {
  final List<String> initialDestination;
  final List<CountryInfo> initialCountryInfos;
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const EditTravelDialog({
    Key? key,
    required this.initialDestination,
    required this.initialCountryInfos,
    required this.initialStartDate,
    required this.initialEndDate,
  }) : super(key: key);

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required List<String> initialDestination,
    required List<CountryInfo> initialCountryInfos,
    required DateTime initialStartDate,
    required DateTime initialEndDate,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTravelDialog(
        initialDestination: initialDestination,
        initialCountryInfos: initialCountryInfos,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
  }

  @override
  State<EditTravelDialog> createState() => _EditTravelDialogState();
}

class _EditTravelDialogState extends State<EditTravelDialog> with SingleTickerProviderStateMixin {
  late List<String> _destination;
  late List<CountryInfo> _countryInfos;
  late DateTime _startDate;
  late DateTime _endDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _destination = List.from(widget.initialDestination);
    _countryInfos = List.from(widget.initialCountryInfos);
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDestinationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            B2bText.medium(
              type: B2bTextType.body1,
              text: '여행 목적지',
              color: $b2bToken.color.labelNomal.resolve(context),
            ),
            IconButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  exclude: ['KR', 'US'],
                  onSelect: (Country country) {
                    final countryName = country.nameLocalized ?? country.name;
                    
                    // 이미 선택된 국가라면 추가하지 않음
                    if (_destination.contains(countryName)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('이미 선택된 국가입니다'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    
                    setState(() {
                      _destination.add(countryName);
                      _countryInfos.add(
                        CountryInfo(
                          name: countryName,
                          countryCode: country.countryCode,
                          flagEmoji: country.flagEmoji,
                        ),
                      );
                    });
                  },
                  countryListTheme: CountryListThemeData(
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: $b2bToken.color.labelNomal.resolve(context),
                    ),
                    bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    inputDecoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Start typing to search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: $b2bToken.color.labelNomal.resolve(context),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: SvgPicture.asset(
                'assets/icons/bytesize_plus.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_destination.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: $b2bToken.color.gray200.resolve(context),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: B2bText.regular(
                type: B2bTextType.body3,
                text: '여행 목적지를 추가해주세요',
                color: $b2bToken.color.gray400.resolve(context),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: $b2bToken.color.gray200.resolve(context),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: List.generate(_destination.length, (index) {
                final country = _destination[index];
                final countryInfo = index < _countryInfos.length ? _countryInfos[index] : null;
                final flagEmoji = countryInfo?.flagEmoji ?? "🏳️";
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          B2bText.regular(
                            type: B2bTextType.body4,
                            text: country,
                          ),
                        ],
                      ),
                      if (_destination.length > 1)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: $b2bToken.color.gray400.resolve(context),
                          ),
                          onPressed: () {
                            setState(() {
                              _destination.removeAt(index);
                              if (index < _countryInfos.length) {
                                _countryInfos.removeAt(index);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        B2bText.medium(
          type: B2bTextType.body1,
          text: '여행 기간',
          color: $b2bToken.color.labelNomal.resolve(context),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: SfDateRangePicker(
            backgroundColor: Colors.white,
            minDate: DateTime(DateTime.now().year - 1),
            maxDate: DateTime(DateTime.now().year + 5),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is PickerDateRange) {
                setState(() {
                  _startDate = args.value.startDate ?? _startDate;
                  _endDate = args.value.endDate ?? _startDate;
                });
              }
            },
            selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange: PickerDateRange(_startDate, _endDate),
            view: DateRangePickerView.month,
            navigationDirection: DateRangePickerNavigationDirection.vertical,
            enableMultiView: true,
            viewSpacing: 0,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              enableSwipeSelection: false,
              numberOfWeeksInView: 6,
            ),
            monthFormat: 'MMM',
            monthCellStyle: DateRangePickerMonthCellStyle(
              textStyle: $b2bToken.textStyle.body4regular.resolve(context).merge(
                    TextStyle(
                      color: $b2bToken.color.gray500.resolve(context),
                    ),
                  ),
              todayTextStyle: $b2bToken.textStyle.body4regular.resolve(context).merge(
                    TextStyle(
                      color: $b2bToken.color.gray500.resolve(context),
                    ),
                  ),
            ),
            startRangeSelectionColor: $b2bToken.color.violet200.resolve(context),
            endRangeSelectionColor: $b2bToken.color.violet200.resolve(context),
            rangeSelectionColor: $b2bToken.color.violet200.resolve(context),
            selectionTextStyle: $b2bToken.textStyle.body4regular.resolve(context).merge(
                  TextStyle(
                    color: $b2bToken.color.primary.resolve(context),
                  ),
                ),
            rangeTextStyle: $b2bToken.textStyle.body4regular.resolve(context).merge(
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
              textStyle: $b2bToken.textStyle.body1medium.resolve(context).merge(
                    TextStyle(
                      color: $b2bToken.color.primary.resolve(context),
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: $b2bToken.color.gray300.resolve(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      B2bText.bold(
                        type: B2bTextType.title3,
                        text: '여행 정보 수정',
                        color: $b2bToken.color.labelNomal.resolve(context),
                      ),
                      const SizedBox(height: 24),
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: '여행지'),
                          Tab(text: '날짜'),
                        ],
                        labelColor: $b2bToken.color.primary.resolve(context),
                        unselectedLabelColor: $b2bToken.color.gray400.resolve(context),
                        indicatorColor: $b2bToken.color.primary.resolve(context),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(child: _buildDestinationTab()),
                            SingleChildScrollView(child: _buildDateTab()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: B2bButton.medium(
                              title: '취소',
                              type: B2bButtonType.secondary,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: B2bButton.medium(
                              title: '확인',
                              type: B2bButtonType.primary,
                              onTap: () {
                                Navigator.pop(context, {
                                  'destination': _destination,
                                  'countryInfos': _countryInfos,
                                  'startDate': _startDate,
                                  'endDate': _endDate,
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 