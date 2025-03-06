import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/components/dialog/dialog.dart';
import 'package:design_systems/b2b/components/dialog/dialog.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travelee/router.dart';
import 'package:travelee/screen/input/destinationscreen.dart';
import 'package:travelee/screen/schedulescreen.dart';
import 'package:travelee/screen/writescreen.dart';

class FirstScreen extends ConsumerWidget {
  static const routeName = 'inital';
  static const routePath = '/';

  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Stack(
      children: [
        Image.asset(
          'assets/images/bg.png',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          color: $b2bToken.color.toastSystem.resolve(context),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.5,
                child: SvgPicture.asset(
                  'assets/icons/icon.svg',
                  width: 44,
                ),
              ),
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 281,
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                '여행의 꿈에 뛰어들어\n오늘부터 계획을 세우세요!',
                style:
                    $b2bToken.textStyle.body1medium.resolve(context).copyWith(
                          color: $b2bToken.color.white.resolve(context),
                          decoration: TextDecoration.none,
                        ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 90,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: SafeArea(
            minimum: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: B2bButton.medium(
              type: B2bButtonType.primary,
              title: '여행 계획 만들기',
              onTap: () {
                ref.read(routerProvider).push(DestinationScreen.routePath);
              },
            ),
          ),
        )
      ],
    );
  }
}
