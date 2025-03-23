import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;
import 'package:travelee/core/config/supabase_config.dart';
import 'package:travelee/core/config/firebase_config.dart';
import 'package:travelee/presentation/screens/home/saved_travels_screen.dart';

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
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            color: $dinoToken.color.black.resolve(context),
          ),
          Center(
            child: SingleChildScrollView(
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
                  const SizedBox(height: 25),
                  DinoText(
                    type: DinoTextType.bodyL,
                    text: '여행의 꿈에 뛰어들어\n오늘부터 계획을 세우세요!',
                    color: $dinoToken.color.white.resolve(context),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          style: TextStyle(
                            color: $dinoToken.color.white.resolve(context),
                          ),
                          decoration: InputDecoration(
                            hintText: '이메일',
                            hintStyle: TextStyle(
                              color: $dinoToken.color.white.resolve(context).withAlpha(128),
                            ),
                            filled: true,
                            fillColor: $dinoToken.color.white.resolve(context).withAlpha(26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: $dinoToken.color.white.resolve(context).withAlpha(128),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(
                            color: $dinoToken.color.white.resolve(context),
                          ),
                          decoration: InputDecoration(
                            hintText: '비밀번호',
                            hintStyle: TextStyle(
                              color: $dinoToken.color.white.resolve(context).withAlpha(128),
                            ),
                            filled: true,
                            fillColor: $dinoToken.color.white.resolve(context).withAlpha(26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: $dinoToken.color.white.resolve(context).withAlpha(128),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: $dinoToken.color.white.resolve(context).withAlpha(128),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: B2bButton.medium(
                            type: B2bButtonType.primary,
                            title: '로그인',
                            onTap: () async {
                              try {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                
                                await SupabaseConfig.client.auth.signInWithPassword(
                                  email: email,
                                  password: password,
                                );
                                
                                if (context.mounted) {
                                  context.go(SavedTravelsScreen.routePath);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('로그인에 실패했습니다: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: $dinoToken.color.white.resolve(context).withAlpha(51),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '또는',
                                style: TextStyle(
                                  color: $dinoToken.color.white.resolve(context).withAlpha(128),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: $dinoToken.color.white.resolve(context).withAlpha(51),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: B2bButton.medium(
                            type: B2bButtonType.secondary,
                            title: 'Google로 계속하기',
                            onTap: () async {
                              try {
                                // final userCredential = await FirebaseConfig.signInWithGoogle();
                                
                                // if (userCredential != null && context.mounted) {
                                //   context.go(SavedTravelsScreen.routePath);
                                // }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('구글 로그인에 실패했습니다: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
