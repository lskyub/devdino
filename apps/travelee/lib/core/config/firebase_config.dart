import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 구글 로그인 진행
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) return null;

      // 구글 인증 정보 획득
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
} 