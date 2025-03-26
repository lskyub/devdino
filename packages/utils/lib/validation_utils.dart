
/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class ValidationUtils {
  static bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  static bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    return isEmailValid(email) ? null : '올바른 이메일 형식이 아닙니다.';
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    return isPasswordValid(password) ? null : '비밀번호는 6자리 이상이어야 합니다.';
  }
}
