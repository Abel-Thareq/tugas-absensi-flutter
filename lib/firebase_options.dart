import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDG2I2nQrNVe8DduUbZiMBegXDzJG2nAuo',
    appId: '1:617171741723:android:7f7506a1b782736a075cbe',
    messagingSenderId: '617171741723',
    projectId: 'absensitugas4-abel',
    storageBucket: 'absensitugas4-abel.firebasestorage.app',
  );
}
