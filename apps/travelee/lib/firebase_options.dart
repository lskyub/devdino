import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5vP5c9V7bTQVsCQFBwX9fWKvCMshxmdE',
    appId: '1:780787532259:android:c2ab758842738b9ce960d6',
    messagingSenderId: '780787532259',
    projectId: 'travelee-75e01',
    storageBucket: 'travelee-75e01.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5vP5c9V7bTQVsCQFBwX9fWKvCMshxmdE',
    appId: '1:780787532259:ios:d673c8108a72b6f4e960d6',
    messagingSenderId: '780787532259',
    projectId: 'travelee-75e01',
    storageBucket: 'travelee-75e01.appspot.com',
    iosClientId: '780787532259-u3h5k309oi3e6a6id45bj54tbuodsrhl.apps.googleusercontent.com',
    iosBundleId: 'com.devdino.travelee',
  );
} 