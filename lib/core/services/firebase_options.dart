
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC5vDLEY9Oi1UorTsof0Jx6TZdt1wVRfsY',
    appId: '1:724928109914:web:363efbabeebd04fa5b2763',
    messagingSenderId: '724928109914',
    projectId: 'flutter-freebies',
    authDomain: 'flutter-freebies.firebaseapp.com',
    storageBucket: 'flutter-freebies.appspot.com',
    measurementId: 'G-2J3B19Q48B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA00kk1mEFrpbfxrKgt0WwcaviwyydyoTY',
    appId: '1:724928109914:android:8d659462d0783cdf5b2763',
    messagingSenderId: '724928109914',
    projectId: 'flutter-freebies',
    storageBucket: 'flutter-freebies.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYvI2RbbDbqzK3UmSIlPW7QmIHKb97K6c',
    appId: '1:724928109914:ios:c383c79f215bd1845b2763',
    messagingSenderId: '724928109914',
    projectId: 'flutter-freebies',
    storageBucket: 'flutter-freebies.appspot.com',
    iosClientId:
        '724928109914-1adjc73c1se3jr5shdiuntaujkqgvvre.apps.googleusercontent.com',
    iosBundleId: 'com.instaflutter.freeloginscreen',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBYvI2RbbDbqzK3UmSIlPW7QmIHKb97K6c',
    appId: '1:724928109914:ios:14570b773437fae25b2763',
    messagingSenderId: '724928109914',
    projectId: 'flutter-freebies',
    storageBucket: 'flutter-freebies.appspot.com',
    iosClientId:
        '724928109914-g3uv4qacao8h2u7an3sdtliqe18c19mc.apps.googleusercontent.com',
    iosBundleId: 'com.instaflutter.freeloginscreen.mac',
  );
}
