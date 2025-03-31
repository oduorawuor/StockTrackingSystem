import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBMrqXPSK16Hxj3ZoT_3RYKxcJQMllKn4o',
    appId: '1:428555188716:web:dad3b3f8739248667d68c9',
    messagingSenderId: '428555188716',
    projectId: 'stocktrackin-38110',
    authDomain: 'stocktrackin-38110.firebaseapp.com',
    storageBucket: 'stocktrackin-38110.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMrqXPSK16Hxj3ZoT_3RYKxcJQMllKn4o',
    appId: '1:428555188716:android:dad3b3f8739248667d68c9',
    messagingSenderId: '428555188716',
    projectId: 'stocktrackin-38110',
    storageBucket: 'stocktrackin-38110.firebasestorage.app',
  );
}
