// File generated for Liquid 2048 Firebase configuration
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC42Pt2Fk7EwFD-K9ufEAUuWOHC83u3RJI',
    appId: '1:1092240937434:web:888ec6c636f24c733870e3',
    messagingSenderId: '1092240937434',
    projectId: 'liquid-2048',
    authDomain: 'liquid-2048.firebaseapp.com',
    storageBucket: 'liquid-2048.firebasestorage.app',
    measurementId: 'G-42F8X239PJ',
  );

  // TODO: Add your Android Firebase configuration
  // Run: flutterfire configure --platforms=android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC42Pt2Fk7EwFD-K9ufEAUuWOHC83u3RJI',
    appId: '1:1092240937434:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '1092240937434',
    projectId: 'liquid-2048',
    storageBucket: 'liquid-2048.firebasestorage.app',
  );

  // TODO: Add your iOS Firebase configuration
  // Run: flutterfire configure --platforms=ios
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC42Pt2Fk7EwFD-K9ufEAUuWOHC83u3RJI',
    appId: '1:1092240937434:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '1092240937434',
    projectId: 'liquid-2048',
    storageBucket: 'liquid-2048.firebasestorage.app',
    iosBundleId: 'com.example.liquid2048Game',
  );

  // TODO: Add your macOS Firebase configuration
  // Run: flutterfire configure --platforms=macos
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC42Pt2Fk7EwFD-K9ufEAUuWOHC83u3RJI',
    appId: '1:1092240937434:macos:YOUR_MACOS_APP_ID',
    messagingSenderId: '1092240937434',
    projectId: 'liquid-2048',
    storageBucket: 'liquid-2048.firebasestorage.app',
    iosBundleId: 'com.example.liquid2048Game',
  );

  // TODO: Add your Windows Firebase configuration
  // Run: flutterfire configure --platforms=windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC42Pt2Fk7EwFD-K9ufEAUuWOHC83u3RJI',
    appId: '1:1092240937434:web:YOUR_WINDOWS_APP_ID',
    messagingSenderId: '1092240937434',
    projectId: 'liquid-2048',
    storageBucket: 'liquid-2048.firebasestorage.app',
  );
}

