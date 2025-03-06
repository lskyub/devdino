import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_picker/country_picker.dart';
import 'package:travelee/router.dart';
import 'package:travelee/screen/input/datescreen.dart';

final searchTextProvider = StateProvider<String>((ref) => '');
final destinationsProvider = StateProvider<List<String>>((ref) => []);

class DestinationScreen extends ConsumerStatefulWidget {
  static const routeName = 'destination';
  static const routePath = '/destination';

  const DestinationScreen({super.key});

  @override
  ConsumerState<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends ConsumerState<DestinationScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);

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
                  ref.read(destinationsProvider.notifier).state = [
                    ...destinations,
                    country.nameLocalized ?? country.name,
                  ];
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
                if (destinations.isEmpty) ...{
                  Center(
                    child: B2bText.regular(
                      type: B2bTextType.display,
                      text: '여행 목적지를 추가해주세요.',
                    ),
                  )
                },
                ListView.builder(
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          B2bText.regular(
                            type: B2bTextType.body4,
                            text: destination,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: $b2bToken.color.gray400.resolve(context),
                            ),
                            onPressed: () {
                              ref.read(destinationsProvider.notifier).state =
                                  destinations
                                      .where((d) => d != destination)
                                      .toList();
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
                  if (destinations.isEmpty) {
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
