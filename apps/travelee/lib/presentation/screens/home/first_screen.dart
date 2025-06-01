import 'dart:io';
import 'dart:ui';

import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/presentation/screens/home/saved_travels_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirstScreen extends ConsumerStatefulWidget {
  static const routeName = 'inital';
  static const routePath = '/';

  const FirstScreen({super.key});

  @override
  ConsumerState<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends ConsumerState<FirstScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return false;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final response = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
    return response.user != null;
  }

  // 애플 로그인
  Future<bool> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    ).then((AuthorizationCredentialAppleID user) {
      print(user);
    }).catchError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
    // webAuthenticationOptions: WebAuthenticationOptions(
    //   // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
    //   clientId: 'de.lunaone.flutter.signinwithappleexample.service',
    //   redirectUri:
    //       // For web your redirect URI needs to be the host of the "current page",
    //       // while for Android you will be using the API server that redirects back into your app via a deep link
    //       // NOTE(tp): For package local development use (as described in `Development.md`)
    //       // Uri.parse('https://siwa-flutter-plugin.dev/')
    //       kIsWeb
    //           ? Uri.parse('https://${Uri.base.host}/')
    //           : Uri.parse(
    //               'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
    //             ),
    // ),

//     talker.debug('''
// [로그인#애플] 로그인 결과
// 메일: ${credential.email}
// 이름: ${credential.familyName} ${credential.givenName}
// ''');

    final userNickname =
        '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
    String nickname = userNickname;

    // return (
    //   token: credential.authorizationCode,
    //   user: SocialUser(
    //     platform: 'apple',
    //     email: credential.email ?? '',
    //     nickname: nickname,
    //   ),
    // );
    return true;
  }

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(SavedTravelsScreen.routePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
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
            color: $dinoToken.color.black.resolve(context).withAlpha(
                  (0.5 * 255).toInt(),
                ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 25),
                  DinoText.custom(
                    text: '여행의 꿈에 뛰어들어\n오늘부터 계획을 세우세요!',
                    textAlign: DinoTextAlign.center,
                    color: $dinoToken.color.white,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (Platform.isIOS)
                      DinoButton.custom(
                        type: DinoButtonType.solid,
                        size: DinoButtonSize.full,
                        leading: SvgPicture.asset(
                          'assets/icons/apple.svg',
                        ),
                        title: 'Apple로 계속하기',
                        radius: 12,
                        backgroundColor: $dinoToken.color.black,
                        onTap: () async {
                          final success = await signInWithApple();
                          if (!mounted) return;
                          if (success) {
                            if (context.mounted) {
                              context.go(SavedTravelsScreen.routePath);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('애플 로그인에 실패했습니다.')),
                              );
                            }
                          }
                        },
                      ),
                    DinoButton.custom(
                      type: DinoButtonType.solid,
                      size: DinoButtonSize.full,
                      title: 'Google로 계속하기',
                      radius: 12,
                      backgroundColor: $dinoToken.color.brandBlingPurple600,
                      onTap: () async {
                        final success = await signInWithGoogle();
                        if (!mounted) return;
                        if (success) {
                          if (context.mounted) {
                            context.go(SavedTravelsScreen.routePath);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('구글 로그인에 실패했습니다.')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
