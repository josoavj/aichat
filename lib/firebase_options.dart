import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration Firebase pour toutes les plateformes
/// Généré avec FlutterFire CLI
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
          'Firebase n\'est pas configuré pour Linux',
        );
      default:
        throw UnsupportedError(
          'Platform Firebase non supportée',
        );
    }
  }

  // Configuration Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCiNGy60s8X3ORVToIK1F8OsnmS4dwY2ZI',
    appId: '1:189186346211:web:1eb37f5bc26d31b88449d6',
    messagingSenderId: '189186346211',
    projectId: 'ai-assistant-1d89a',
    authDomain: 'ai-assistant-1d89a.firebaseapp.com',
    storageBucket: 'ai-assistant-1d89a.firebasestorage.app',
  );

  // Configuration Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVDp8oG6WLzq3DXW5FUuHP30F1wjE8yC0',
    appId: '1:189186346211:android:4c5259198380de718449d6',
    messagingSenderId: '189186346211',
    projectId: 'ai-assistant-1d89a',
    storageBucket: 'ai-assistant-1d89a.firebasestorage.app',
  );

  // Configuration iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCokHqRhOam3yT94o8PzgRqCffrfvtpHcc',
    appId: '1:189186346211:ios:668cf71db5091e7c8449d6',
    messagingSenderId: '189186346211',
    projectId: 'ai-assistant-1d89a',
    storageBucket: 'ai-assistant-1d89a.firebasestorage.app',
    iosBundleId: 'com.example.ai_test',
  );

  // Configuration macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCokHqRhOam3yT94o8PzgRqCffrfvtpHcc',
    appId: '1:189186346211:ios:668cf71db5091e7c8449d6',
    messagingSenderId: '189186346211',
    projectId: 'ai-assistant-1d89a',
    storageBucket: 'ai-assistant-1d89a.firebasestorage.app',
    iosBundleId: 'com.example.ai_test',
  );

  // Configuration Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCiNGy60s8X3ORVToIK1F8OsnmS4dwY2ZI',
    appId: '1:189186346211:web:98856700e35c05b18449d6',
    messagingSenderId: '189186346211',
    projectId: 'ai-assistant-1d89a',
    storageBucket: 'ai-assistant-1d89a.firebasestorage.app',
  );
}
