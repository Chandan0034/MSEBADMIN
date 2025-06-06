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
    apiKey: 'AIzaSyCH58qLgKIsFonlYWzc6PkI6Bi2coTKesM',
    appId: '1:648386758877:web:a9767c1965e71d3ee0b334',
    messagingSenderId: '648386758877',
    projectId: 'garbage-c3c93',
    authDomain: 'garbage-c3c93.firebaseapp.com',
    databaseURL: 'https://garbage-c3c93-default-rtdb.firebaseio.com',
    storageBucket: 'garbage-c3c93.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCP40L2NEa4_gU6yaCrw2ermz0IqoNbVDs',
    appId: '1:648386758877:android:86de0b2c7108b1a3e0b334',
    messagingSenderId: '648386758877',
    projectId: 'garbage-c3c93',
    databaseURL: 'https://garbage-c3c93-default-rtdb.firebaseio.com',
    storageBucket: 'garbage-c3c93.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCX6eMcSqBv5_ZBqR0GBnhfW8WIgc54Ayo',
    appId: '1:648386758877:ios:00d0e96aad171b69e0b334',
    messagingSenderId: '648386758877',
    projectId: 'garbage-c3c93',
    databaseURL: 'https://garbage-c3c93-default-rtdb.firebaseio.com',
    storageBucket: 'garbage-c3c93.appspot.com',
    iosBundleId: 'com.example.admin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCX6eMcSqBv5_ZBqR0GBnhfW8WIgc54Ayo',
    appId: '1:648386758877:ios:00d0e96aad171b69e0b334',
    messagingSenderId: '648386758877',
    projectId: 'garbage-c3c93',
    databaseURL: 'https://garbage-c3c93-default-rtdb.firebaseio.com',
    storageBucket: 'garbage-c3c93.appspot.com',
    iosBundleId: 'com.example.admin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCH58qLgKIsFonlYWzc6PkI6Bi2coTKesM',
    appId: '1:648386758877:web:4a20ed543a593da4e0b334',
    messagingSenderId: '648386758877',
    projectId: 'garbage-c3c93',
    authDomain: 'garbage-c3c93.firebaseapp.com',
    databaseURL: 'https://garbage-c3c93-default-rtdb.firebaseio.com',
    storageBucket: 'garbage-c3c93.appspot.com',
  );

}