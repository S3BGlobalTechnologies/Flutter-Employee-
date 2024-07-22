// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyCQ_ChFab6poU5ihl0z09vJptXMIKTRTZo',
    appId: '1:1033060565219:web:5ae46f530b7d88ea2945d6',
    messagingSenderId: '1033060565219',
    projectId: 'app-01-fcbae',
    authDomain: 'app-01-fcbae.firebaseapp.com',
    storageBucket: 'app-01-fcbae.appspot.com',
    measurementId: 'G-1LELZFJ8W9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGyrjD-Mgry1RWyO4eh4rgui6rBiL1VC8',
    appId: '1:1033060565219:android:56bfd79878e93a642945d6',
    messagingSenderId: '1033060565219',
    projectId: 'app-01-fcbae',
    storageBucket: 'app-01-fcbae.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9EJyS0zJaZ0UST7SKivGA9pOlVBXusaI',
    appId: '1:1033060565219:ios:7141bc50ce458e392945d6',
    messagingSenderId: '1033060565219',
    projectId: 'app-01-fcbae',
    storageBucket: 'app-01-fcbae.appspot.com',
    iosBundleId: 'com.example.employee',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9EJyS0zJaZ0UST7SKivGA9pOlVBXusaI',
    appId: '1:1033060565219:ios:7141bc50ce458e392945d6',
    messagingSenderId: '1033060565219',
    projectId: 'app-01-fcbae',
    storageBucket: 'app-01-fcbae.appspot.com',
    iosBundleId: 'com.example.employee',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQ_ChFab6poU5ihl0z09vJptXMIKTRTZo',
    appId: '1:1033060565219:web:eb1c4e44eeb370a42945d6',
    messagingSenderId: '1033060565219',
    projectId: 'app-01-fcbae',
    authDomain: 'app-01-fcbae.firebaseapp.com',
    storageBucket: 'app-01-fcbae.appspot.com',
    measurementId: 'G-7JMXEL08QQ',
  );
}
