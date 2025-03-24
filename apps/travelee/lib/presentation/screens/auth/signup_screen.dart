import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:travelee/core/utils/validation_utils.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const routeName = 'signup';
  static const routePath = '/signup';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isVerificationSent = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  // 이메일 인증번호 전송
  Future<void> _sendVerificationCode() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    
    setState(() {
      _emailError = ValidationUtils.validateEmail(email);
      _passwordError = ValidationUtils.validatePassword(password);
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    // TODO: 이메일 인증번호 전송 로직 구현
    setState(() {
      _isVerificationSent = true;
    });
  }

  // 인증번호 확인 및 회원가입
  Future<void> _verifyAndSignUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    
    // 최종 확인을 위해 유효성 검사 한번 더 실행
    if (!ValidationUtils.isEmailValid(email) || !ValidationUtils.isPasswordValid(password)) {
      return;
    }

    // TODO: 인증번호 확인 및 회원가입 로직 구현
  }

  @override
  Widget build(BuildContext context) {
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: $dinoToken.color.white.resolve(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DinoText(
                    type: DinoTextType.headingXL,
                    text: '회원가입',
                    color: $dinoToken.color.white.resolve(context),
                  ),
                  const SizedBox(height: 40),
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
                      errorText: _emailError,
                      errorStyle: const TextStyle(
                        color: Colors.redAccent,
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
                      hintText: '비밀번호 (6자리 이상)',
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
                      errorText: _passwordError,
                      errorStyle: const TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isVerificationSent)
                    SizedBox(
                      width: double.infinity,
                      child: B2bButton.medium(
                        type: B2bButtonType.primary,
                        title: '인증번호 전송',
                        onTap: _sendVerificationCode,
                      ),
                    )
                  else ...[
                    TextField(
                      controller: _verificationCodeController,
                      style: TextStyle(
                        color: $dinoToken.color.white.resolve(context),
                      ),
                      decoration: InputDecoration(
                        hintText: '인증번호 입력',
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
                          Icons.verified_user_outlined,
                          color: $dinoToken.color.white.resolve(context).withAlpha(128),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: B2bButton.medium(
                        type: B2bButtonType.primary,
                        title: '가입하기',
                        onTap: _verifyAndSignUp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 