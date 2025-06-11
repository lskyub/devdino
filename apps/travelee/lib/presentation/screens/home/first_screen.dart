import 'dart:io';

import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/core/config/supabase_config.dart';
import 'package:travelee/data/datasources/remote/travel_sync_service.dart';
import 'package:travelee/presentation/screens/home/saved_travels_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:travelee/gen/app_localizations.dart';
import 'package:travelee/presentation/providers/loading_state_provider.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart';

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
    ref.read(loadingStateProvider.notifier).startLoading(
          message: '구글 로그인 중...',
        );
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      print(response);
      return response.user != null;
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      ref.read(loadingStateProvider.notifier).stopLoading();
      return false;
    }
  }

  // 애플 로그인
  Future<bool> signInWithApple() async {
    ref.read(loadingStateProvider.notifier).startLoading(
          message: '애플 로그인 중...',
        );
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print(credential); // 실제 credential 값 확인

      if (credential.identityToken == null) {
        print('identityToken is null');
        return false;
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        // accessToken, authorizationCode 등 필요시 추가
      );
      print(response);
      return response.user != null;
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      ref.read(loadingStateProvider.notifier).stopLoading();
      return false;
    }
  }

  /// 사용자 여행 데이터 불러오기
  Future<void> _loadTravels() async {
    final travelSyncService = TravelSyncService(SupabaseConfig.client);
    final travels = await travelSyncService.loadAllTravels();
    print(travels);
    ref.read(travelsProvider.notifier).setTravels(travels);
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
    final local = AppLocalizations.of(context)!;
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
                  SvgPicture.asset(
                    local.localeName == 'ko'
                        ? 'assets/icons/logotype_travelee.svg'
                        : 'assets/icons/logotype_travelee_e.svg',
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  const SizedBox(height: 25),
                  DinoText.custom(
                    text: local.firstScreenTitle,
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
                        leading: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SvgPicture.asset(
                            'assets/icons/apple.svg',
                          ),
                        ),
                        title: local.continueWithApple,
                        radius: 12,
                        backgroundColor: $dinoToken.color.black,
                        onTap: () async {
                          final success = await signInWithApple();
                          if (!mounted) return;
                          if (success) {
                            if (context.mounted) {
                              /// 사용자 여행 데이터 불러오기 이후 여행 목록 화면으로 이동
                              _loadTravels().then((_) {
                                context.go(SavedTravelsScreen.routePath);
                              });
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(local.appleLoginFailed)),
                              );
                            }
                          }
                        },
                      ),
                    DinoButton.custom(
                      type: DinoButtonType.solid,
                      size: DinoButtonSize.full,
                      title: local.continueWithGoogle,
                      radius: 12,
                      backgroundColor: $dinoToken.color.brandBlingPurple600,
                      onTap: () async {
                        final success = await signInWithGoogle();
                        if (!mounted) return;
                        if (success) {
                          if (context.mounted) {
                            /// 사용자 여행 데이터 불러오기 이후 여행 목록 화면으로 이동
                            _loadTravels().then((_) {
                              context.go(SavedTravelsScreen.routePath);
                            });
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(local.googleLoginFailed)),
                            );
                          }
                        }
                      },
                    ),
                    // 디버깅 빌드 상태 여부
                    if (!kReleaseMode)
                      DinoButton.custom(
                        type: DinoButtonType.solid,
                        size: DinoButtonSize.full,
                        title: '임시 로그인',
                        onTap: () {
                          context.go(SavedTravelsScreen.routePath);
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
