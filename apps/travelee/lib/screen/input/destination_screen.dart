import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_picker/country_picker.dart';
import 'package:travelee/router.dart';
import 'package:travelee/screen/input/date_screen.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/models/country_info.dart';
import 'package:travelee/models/travel_model.dart';

final searchTextProvider = StateProvider<String>((ref) => '');

class DestinationScreen extends ConsumerWidget {
  static const routeName = 'destination';
  static const routePath = '/destination';

  const DestinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 여행 정보 확인
    final travelInfo = ref.watch(currentTravelProvider);
    
    // 여행 정보가 null이면 새 여행 생성 시작
    if (travelInfo == null) {
      // 일정 시간 후에 새 여행 생성 (UI 렌더링 후 실행)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 새 임시 ID 생성
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        
        // 빈 여행 객체 생성
        final newTravel = TravelModel(
          id: tempId,
          title: '새 여행',
          destination: [],
          startDate: null,
          endDate: null,
          countryInfos: [],
          schedules: [],
          dayDataMap: {},
        );
        
        // 새 여행 추가
        ref.read(travelsProvider.notifier).addTravel(newTravel);
        
        // 현재 여행 ID 설정
        ref.read(currentTravelIdProvider.notifier).state = tempId;
        
        // 임시 편집 모드 시작
        ref.read(travelsProvider.notifier).startTempEditing();
      });
      
      // 로딩 표시
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: $b2bToken.color.primary.resolve(context),
              ),
              const SizedBox(height: 16),
              B2bText.regular(
                type: B2bTextType.body2, 
                text: '새 여행 생성 중...',
              ),
            ],
          ),
        ),
      );
    }

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
        actions: [
          IconButton(
            onPressed: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                exclude: ['KR', 'US'],
                onSelect: (Country country) {
                  // Country 객체 정보와 함께 저장
                  final countryName = country.nameLocalized ?? country.name;
                  
                  // 이미 선택된 국가인지 확인
                  if (travelInfo.destination.contains(countryName)) {
                    // 이미 선택된 국가는 추가하지 않고 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이미 선택된 국가입니다'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  
                  final countryInfo = CountryInfo(
                    name: countryName,
                    countryCode: country.countryCode,
                    flagEmoji: country.flagEmoji,
                  );
                  
                  // 목적지와 국가 정보 추가
                  final destinations = List<String>.from(travelInfo.destination);
                  final countryInfos = List<CountryInfo>.from(travelInfo.countryInfos);
                  
                  destinations.add(countryInfo.name);
                  countryInfos.add(countryInfo);
                  
                  final updatedTravel = travelInfo.copyWith(
                    destination: destinations,
                    countryInfos: countryInfos,
                  );
                  
                  ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
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
          )
        ],
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
              text: '여행 목적지들을 추가 하세요.',
              color: $b2bToken.color.labelNomal.resolve(context),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (travelInfo.destination.isEmpty) ...{},
                ListView.builder(
                  itemCount: travelInfo.destination.length,
                  itemBuilder: (context, index) {
                    final data = travelInfo.destination[index];
                    final countryInfo = travelInfo.countryInfos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // 국기 이모지 표시
                              Text(
                                countryInfo.flagEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              B2bText.regular(
                                type: B2bTextType.body4,
                                text: data,
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: $b2bToken.color.gray400.resolve(context),
                            ),
                            onPressed: () {
                              // 목적지와 국가 정보 제거
                              final destinations = List<String>.from(travelInfo.destination);
                              final countryInfos = List<CountryInfo>.from(travelInfo.countryInfos);
                              
                              final index = destinations.indexOf(data);
                              if (index != -1) {
                                destinations.removeAt(index);
                                if (index < countryInfos.length) {
                                  countryInfos.removeAt(index);
                                }
                              }
                              
                              final updatedTravel = travelInfo.copyWith(
                                destination: destinations,
                                countryInfos: countryInfos,
                              );
                              
                              ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
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
                title: '다음',
                type: B2bButtonType.primary,
                onTap: () {
                  if (travelInfo.destination.isEmpty) {
                    return;
                  }
                  ref.read(routerProvider).push(DateScreen.routePath);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
