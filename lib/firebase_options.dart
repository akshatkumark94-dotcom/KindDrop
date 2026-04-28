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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDK9jOmAriRydD2xbn-Y2xJjwhYgMpkXI0',
    appId: '1:874331667087:web:4ae3c50854b6555d258efa',
    messagingSenderId: '874331667087',
    projectId: 'food-app-9f7ac',
    authDomain: 'food-app-9f7ac.firebaseapp.com',
    storageBucket: 'food-app-9f7ac.firebasestorage.app',
    measurementId: 'G-NY6QH49YHS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtRJjhRGBDBtq7PupWLq59H6FrIRdBT8U',
    appId: '1:874331667087:android:de0bd0de34bdf2c7258efa',
    messagingSenderId: '874331667087',
    projectId: 'food-app-9f7ac',
    storageBucket: 'food-app-9f7ac.firebasestorage.app',
  );
}
